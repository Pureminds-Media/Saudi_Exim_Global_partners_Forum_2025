import '../utils/api_endpoints.dart';

class Speaker {
  final int? id; // ✅ add id for dedup
  final String initials;
  final String name_en;
  final String name_ar;
  final String title_en;
  final String title_ar;
  final String country;
  final String? photoAsset;
  final String? photoUrl;
  final bool isModerator;

  Speaker({
    required this.id,
    required this.initials,
    required this.name_en,
    required this.name_ar,
    required this.title_en,
    required this.title_ar,
    required this.country,
    this.photoAsset,
    this.photoUrl,
    this.isModerator = false,
  });

  Speaker copyWith({bool? isModerator}) => Speaker(
    id: id,
    initials: initials,
    name_en: name_en,
    name_ar: name_ar,
    title_en: title_en,
    title_ar: title_ar,
    photoAsset: photoAsset,
    photoUrl: photoUrl,
    country: country,
    isModerator: isModerator ?? this.isModerator,
  );

  factory Speaker.fromJson(Map<String, dynamic> json) {
    final rawName = (json['name'] as String? ?? '').split('.');
    final fullName = rawName.length > 1 ? rawName[1].trim() : rawName[0].trim();
    final nameParts = fullName
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    String initials = '';
    if (nameParts.isNotEmpty) {
      final first = nameParts.first[0];
      final second = nameParts.length > 1 ? nameParts[1][0] : '';
      initials = (first + second).toUpperCase();
    }

    final String? photoPath = json['photo_path'] as String?;
    String? resolvedPhotoUrl;
    if (photoPath != null) {
      final trimmed = photoPath.trim();
      if (trimmed.isNotEmpty) {
        final normalized = trimmed.startsWith('/')
            ? trimmed.substring(1)
            : trimmed;
        if (normalized.isNotEmpty) {
          final isAbsolute = normalized.startsWith('http://') ||
              normalized.startsWith('https://');
          if (isAbsolute) {
            resolvedPhotoUrl = normalized;
          } else {
            final base = speakersStorageBaseUrl.endsWith('/')
                ? speakersStorageBaseUrl.substring(
                    0,
                    speakersStorageBaseUrl.length - 1,
                  )
                : speakersStorageBaseUrl;
            resolvedPhotoUrl = '$base/$normalized';
          }
        }
      }
    }

    return Speaker(
      id: json['id'] as int?,
      initials: initials,
      name_en: json['name'] ?? '',
      name_ar: json['name_ar'] ?? '',
      title_en: json['title_en'] ?? '',
      title_ar: json['title_ar'] ?? '',
      country: (json['country_id']?.toString() ?? ''),
      photoAsset: null,
      photoUrl: resolvedPhotoUrl,
      isModerator: false,
    );
  }
}
