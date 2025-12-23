import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/components/city_filter_item.dart';
import 'package:saudiexim_mobile_app/models/city.dart';
import 'package:saudiexim_mobile_app/components/services/city_chips_skeleton.dart';

class CitySelector extends StatelessWidget {
  const CitySelector({
    super.key,
    required this.allLabel,
    required this.allImage,
    required this.cities,
    required this.selectedIndex,
    required this.indexForCityId,
    required this.onSelect,
    required this.isAr,
    this.loading = false,
    this.skeletonCount = 6,
  });

  final String allLabel;
  final String allImage;
  final List<City> cities;
  final int selectedIndex;
  final int? Function(int cityId) indexForCityId;
  final ValueChanged<int> onSelect;
  final bool isAr;
  final bool loading;
  final int skeletonCount;

  @override
  Widget build(BuildContext context) {
    if (loading && cities.isEmpty) {
      return CityChipsSkeleton(count: skeletonCount);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CityFilterItem(
            label: allLabel,
            image: allImage,
            selected: selectedIndex == 0,
            onTap: () => onSelect(0),
          ),
          Container(
            width: 1,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFFDFDFDF),
          ),
          for (final c in cities)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: CityFilterItem(
                label: _localizedCityName(c, isAr),
                image: c.photoUrl ?? '',
                selected: selectedIndex == (indexForCityId(c.id) ?? 0),
                onTap: () => onSelect(indexForCityId(c.id) ?? 0),
              ),
            ),
        ],
      ),
    );
  }

  static String _localizedCityName(City c, bool isAr) {
    String fallback(String primary, String alt) => primary.isNotEmpty ? primary : alt;
    return isAr ? fallback(c.nameAr, c.nameEn) : fallback(c.nameEn, c.nameAr);
  }
}
