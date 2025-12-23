import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../utils/secure_image_cache.dart';
import 'cached_svg.dart';
import 'cached_url_image.dart';

/// Tile representing a service category with an icon and label.
class CategoryCard extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback? onTap;
  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDFDFDF), width: 1),
              ),
              alignment: Alignment.center,
              child: _buildIcon(context, icon),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8A8A8A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildIcon(BuildContext context, String icon) {
  final src = icon.trim();
  if (src.isEmpty) {
    return const Icon(
      Icons.category_outlined,
      size: 32,
      color: Color(0xFF9B9B9B),
    );
  }
  if (src.startsWith('http://') || src.startsWith('https://')) {
    SecureImageCache? cache;
    try {
      cache = context.read<SecureImageCache>();
    } catch (_) {
      cache = null;
    }
    if (cache == null) {
      return const Icon(
        Icons.category_outlined,
        size: 32,
        color: Color(0xFF9B9B9B),
      );
    }
    if (src.toLowerCase().endsWith('.svg')) {
      return CachedSvg(
        src,
        cache: cache,
        width: 32,
        height: 32,
        color: const Color(0xFF9B9B9B),
        shimmerEnabled: false,
      );
    }
    return CachedUrlImage(
      src,
      cache: cache,
      width: 32,
      height: 32,
      fit: BoxFit.contain,
      color: const Color(0xFF9B9B9B),
      shimmerEnabled: false,
    );
  }
  return SvgPicture.asset(
    src,
    width: 32,
    height: 32,
    colorFilter: const ColorFilter.mode(Color(0xFF9B9B9B), BlendMode.srcIn),
  );
}
