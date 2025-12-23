import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/models/city.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';

class CityDropdown extends StatelessWidget {
  const CityDropdown({
    super.key,
    required this.cities,
    required this.selectedIndex,
    required this.onChanged,
    required this.isAr,
    this.loading = false,
  });

  final List<City> cities;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool isAr;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    // Build list with only actual cities (no "All Saudi" option)
    final List<DropdownMenuItem<int>> items = <DropdownMenuItem<int>>[
      for (int i = 0; i < cities.length; i++)
        DropdownMenuItem<int>(
          // Keep VM indexing compatibility: city indices start at 1
          value: i + 1,
          child: _buildItemLabel(
            isAr && cities[i].nameAr.isNotEmpty
                ? cities[i].nameAr
                : cities[i].nameEn,
          ),
        ),
    ];

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return IgnorePointer(
      ignoring: loading,
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            // If VM is still at index 0 ("All"), display first city if available
            value: (
                      selectedIndex >= 1 &&
                      selectedIndex <= cities.length
                   )
                ? selectedIndex
                : (cities.isNotEmpty ? 1 : null),
            items: items,
            onChanged: (val) {
              if (val == null) return;
              onChanged(val);
            },
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
            dropdownColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildItemLabel(String text) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
