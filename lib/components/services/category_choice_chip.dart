import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';
import 'package:saudiexim_mobile_app/components/cached_url_image.dart';
import 'package:saudiexim_mobile_app/components/cached_svg.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';

class CategoryChoiceChip extends StatelessWidget {
  const CategoryChoiceChip({
    super.key,
    required this.cat,
    required this.isSelected,
    required this.isAr,
    required this.cache,
    required this.onSelected,
  });

  final dynamic cat;
  final bool isSelected;
  final bool isAr;
  final SecureImageCache cache;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedColor = isSelected ? Colors.white : const Color(0xFF737373);

    final iconUrl = (cat.iconUrl ?? '').toString().trim();
    Widget? iconWidget;
    if (iconUrl.isNotEmpty) {
      if (iconUrl.toLowerCase().endsWith('.svg')) {
        iconWidget = CachedSvg(
          iconUrl,
          cache: cache,
          width: 18,
          height: 18,
          color: selectedColor,
          shimmerEnabled: false,
        );
      } else {
        iconWidget = CachedUrlImage(
          iconUrl,
          cache: cache,
          width: 18,
          height: 18,
          fit: BoxFit.contain,
          color: selectedColor,
          shimmerEnabled: false,
        );
      }
    } else if ((cat.icon as String? ?? '').isNotEmpty) {
      iconWidget = Image.asset(
        cat.icon as String,
        width: 18,
        height: 18,
        color: selectedColor,
        errorBuilder: (_, __, ___) => const SizedBox(width: 18, height: 18),
      );
    }

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconWidget != null) ...[iconWidget, const SizedBox(width: 6)],
          Text(
            _localizedCategoryLabel(cat, isAr),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selectedColor,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.teal,
      backgroundColor: Colors.white,
      side: isSelected
          ? BorderSide.none
          : const BorderSide(color: Color(0xFFDFDFDF), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      showCheckmark: false,
      elevation: isSelected ? 4 : 0,
    );
  }

  static String _localizedCategoryLabel(dynamic cat, bool isAr) {
    String asString(Object? v) => (v ?? '').toString();
    final label = asString(cat.label);
    final labelAr = asString(cat.labelAr);
    final labelEn = asString(cat.labelEn);
    if (isAr) {
      return labelAr.isNotEmpty
          ? labelAr
          : label.isNotEmpty
              ? label
              : labelEn;
    }
    return labelEn.isNotEmpty
        ? labelEn
        : label.isNotEmpty
            ? label
            : labelAr;
  }
}

