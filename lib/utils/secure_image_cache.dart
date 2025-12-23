import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/io.dart';

class SecureImageCache {
  SecureImageCache._(this._dio);

  /// Construct with optional pinned certificates (DER bytes).
  /// If you pass [pinnedCerts], only those roots/leaf certs will be trusted.
  factory SecureImageCache({
    List<Uint8List>? pinnedCerts,
    bool trustSystemRoots = true,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 20),
  }) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        followRedirects: false, // avoid auto-following to non-HTTPS by mistake
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    dio.httpClientAdapter = IOHttpClientAdapter(
      // Build a custom HttpClient with a SecurityContext.
      createHttpClient: () {
        // If you want hard pinning only, set trustSystemRoots=false.
        final ctx = SecurityContext(withTrustedRoots: trustSystemRoots);
        if (pinnedCerts != null && pinnedCerts.isNotEmpty) {
          for (final c in pinnedCerts) {
            // Trust ONLY these (root/leaf) certs. (DER-encoded)
            ctx.setTrustedCertificatesBytes(c); // pinning via trust store
          }
        }
        final client = HttpClient(context: ctx);
        client.badCertificateCallback = (cert, host, port) =>
            false; // never bypass
        return client;
      },

      // Note: this callback runs after the TLS handshake; prefer SecurityContext for pinning.
      // See: https://github.com/cfug/dio/issues/2418
      validateCertificate: null,
    );

    return SecureImageCache._(dio);
  }

  final Dio _dio;
  Directory? _root;

  // ---------- Paths & helpers ----------
  Future<Directory> _dir() async {
    if (_root != null) return _root!;
    final base = await getApplicationSupportDirectory(); // app-private
    final media = Directory('${base.path}/media');
    if (!await media.exists()) await media.create(recursive: true);
    _root = media;
    return media;
  }

  String _nameFor(String url) => sha1.convert(utf8.encode(url)).toString();
  Future<File> _imgFile(String url) async =>
      File('${(await _dir()).path}/${_nameFor(url)}.img');
  Future<File> _metaFile(String url) async =>
      File('${(await _dir()).path}/${_nameFor(url)}.json');

  // Separate storage for SVGs to avoid collisions with raster cache.
  Future<File> _svgFile(String url) async =>
      File('${(await _dir()).path}/${_nameFor(url)}.svg');
  Future<File> _svgMetaFile(String url) async =>
      File('${(await _dir()).path}/${_nameFor(url)}.svg.json');

  Future<void> _atomicWrite(File target, List<int> bytes) async {
    // Ensure parent directory exists (defensive; usually created in _dir()).
    try {
      await target.parent.create(recursive: true);
    } catch (_) {}

    // Use a unique temp name to avoid races when multiple listeners write
    // the same target concurrently (e.g., repeated widgets with same URL).
    final unique = DateTime.now().microsecondsSinceEpoch ^ Random().nextInt(1 << 31);
    final tmp = File('${target.path}.$unique.tmp');
    await tmp.writeAsBytes(bytes, flush: true);

    // Try atomic replace: on some iOS/macOS filesystems, rename won't
    // overwrite existing files. Handle both cases gracefully.
    try {
      // If destination exists, remove it first to avoid rename failures.
      if (await target.exists()) {
        try {
          await target.delete();
        } catch (_) {}
      }
      await tmp.rename(target.path);
    } on FileSystemException catch (_) {
      // Fallback: copy then delete temp. If temp somehow vanished due to race,
      // treat it as already handled by a parallel writer.
      try {
        if (await tmp.exists()) {
          await tmp.copy(target.path);
          await tmp.delete();
        }
      } catch (_) {}
    }
  }

  /// Cached-first stream: emits cached image immediately (if any),
  /// then emits a fresh image if server returns 200 (changed).
  Stream<ImageProvider> imageStream(String url, {bool refresh = true}) async* {
    final uri = Uri.parse(url);
    if (uri.scheme != 'https') {
      throw ArgumentError('Only https:// URLs are allowed for images.');
    }

    final img = await _imgFile(url);
    final meta = await _metaFile(url);

    // 1) Show cached immediately (offline friendly)
    if (await img.exists()) {
      yield FileImage(img); // renders from local storage
    }

    // 2) Build conditional headers from previous ETag/Last-Modified
    String? etag, lastModified;
    if (await meta.exists()) {
      try {
        final m = jsonDecode(await meta.readAsString()) as Map<String, dynamic>;
        etag = (m['etag'] as String?)?.trim();
        lastModified = (m['lastModified'] as String?)?.trim();
      } catch (_) {}
    }

    final headers = <String, String>{
      'Accept': 'image/*',
      if (etag?.isNotEmpty ?? false) 'If-None-Match': etag!,
      if (lastModified?.isNotEmpty ?? false) 'If-Modified-Since': lastModified!,
    };

    // If caller requested cached-only, do not attempt network
    if (!refresh) {
      return;
    }

    // 3) Conditional GET with Dio
    Response<List<int>> res;
    try {
      res = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes, headers: headers),
      );
    } catch (_) {
      return; // network error: keep cached image
    }

    if (res.statusCode == 304) return; // unchanged

    if (res.statusCode == 200 && res.data != null && res.data!.isNotEmpty) {
      final ct = res.headers.value('content-type') ?? '';
      if (!ct.startsWith('image/')) return; // safety: ignore non-images

      // Optional: basic size cap (e.g., 15MB)
      final contentLenHeader = res.headers.value('content-length');
      final contentLen = int.tryParse(contentLenHeader ?? '');
      if (contentLen != null && contentLen > 15 * 1024 * 1024) return;

      // 4) Save atomically, then write metadata
      await _atomicWrite(img, res.data!);

      final newMeta = <String, dynamic>{
        'url': url,
        'etag': res.headers.value('etag'),
        'lastModified': res.headers.value('last-modified'),
        'contentType': ct,
        'sha256': base64Encode(sha256.convert(res.data!).bytes), // integrity
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
      await meta.writeAsString(jsonEncode(newMeta), flush: true);

      // 5) Emit updated image
      yield FileImage(img);
    }
  }

  /// Cached-first bytes stream for SVG content.
  /// Ensures HTTPS, validates content-type starts with image/svg.
  Stream<Uint8List> svgBytesStream(String url, {bool refresh = true}) async* {
    final uri = Uri.parse(url);
    if (uri.scheme != 'https') {
      throw ArgumentError('Only https:// URLs are allowed for SVGs.');
    }

    final file = await _svgFile(url);
    final meta = await _svgMetaFile(url);

    // 1) Emit cached bytes immediately if present
    if (await file.exists()) {
      try {
        yield await file.readAsBytes();
      } catch (_) {}
    }

    // 2) Conditional headers based on existing metadata
    String? etag, lastModified;
    if (await meta.exists()) {
      try {
        final m = jsonDecode(await meta.readAsString()) as Map<String, dynamic>;
        etag = (m['etag'] as String?)?.trim();
        lastModified = (m['lastModified'] as String?)?.trim();
      } catch (_) {}
    }

    // If caller requested cached-only, do not attempt network
    if (!refresh) {
      return;
    }

    final headers = <String, String>{
      'Accept': 'image/svg+xml',
      if (etag?.isNotEmpty ?? false) 'If-None-Match': etag!,
      if (lastModified?.isNotEmpty ?? false) 'If-Modified-Since': lastModified!,
    };

    // 3) Conditional GET with Dio
    Response<List<int>> res;
    try {
      res = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes, headers: headers),
      );
    } catch (_) {
      return; // network error: keep cached bytes if any
    }

    if (res.statusCode == 304) return; // unchanged

    if (res.statusCode == 200 && res.data != null && res.data!.isNotEmpty) {
      final ct = res.headers.value('content-type')?.toLowerCase() ?? '';
      if (!ct.startsWith('image/svg')) return; // enforce svg

      // Basic size cap (e.g., 5MB for SVG text)
      final contentLenHeader = res.headers.value('content-length');
      final contentLen = int.tryParse(contentLenHeader ?? '');
      if (contentLen != null && contentLen > 5 * 1024 * 1024) return;

      final data = Uint8List.fromList(res.data!);

      // 4) Save atomically and metadata
      await _atomicWrite(file, data);

      final newMeta = <String, dynamic>{
        'url': url,
        'etag': res.headers.value('etag'),
        'lastModified': res.headers.value('last-modified'),
        'contentType': ct,
        'sha256': base64Encode(sha256.convert(data).bytes),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
      await meta.writeAsString(jsonEncode(newMeta), flush: true);

      // 5) Emit updated bytes
      yield data;
    }
  }

  /// Returns cached SVG bytes if present; otherwise null.
  Future<Uint8List?> getCachedSvgBytes(String url) async {
    final f = await _svgFile(url);
    if (await f.exists()) {
      try {
        return await f.readAsBytes();
      } catch (_) {}
    }
    return null;
  }

  /// Returns a cached ImageProvider if the file exists; otherwise null.
  Future<ImageProvider?> getCached(String url) async {
    final f = await _imgFile(url);
    if (await f.exists()) return FileImage(f);
    return null;
  }

  /// Clear cache (e.g., on logout)
  Future<void> clear() async {
    final d = await _dir();
    if (await d.exists()) {
      await for (final e in d.list()) {
        try {
          await e.delete(recursive: true);
        } catch (_) {}
      }
    }
  }
}
