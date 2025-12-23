import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';

class CityDescription extends StatelessWidget {
  const CityDescription({super.key, required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: description.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
    );
  }
}

