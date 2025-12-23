import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/components/buttons/primary_button.dart';
import '../theme/app_colors.dart';

class EventInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateRange;
  final String venueName;
  final String mapAsset;
  final VoidCallback onRegister;

  const EventInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dateRange,
    required this.venueName,
    required this.mapAsset,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          // borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title (right aligned like the original)
            Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle (right aligned, lighter)
            Text(
              subtitle,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textBody,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // Meta row: flat link-style (icon + text), no filled chips
            Wrap(
              spacing: 18,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                _MetaLink(
                  icon: Icons.location_on_outlined,
                  text: 'فندق هيلتون الرياض',
                ),
                _MetaLink(
                  icon: Icons.calendar_month_outlined,
                  text: '19 - 20 نوفمبر 2025',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Map image (rounded corners)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                mapAsset,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 150,
              ),
            ),

            const SizedBox(height: 12),

            // Full-width primary button (your component)
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 200,
                height: 31,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: PrimaryButton(
                    label: 'سجل الان',
                    onPressed: () {}, // your handler
                    // width: 12,
                    // height: 36,
                    backgroundColor: AppColors.primary,
                    borderRadius: BorderRadius.circular(52),
                    padding: const EdgeInsets.symmetric(
                      // keep tiny so it fits
                      horizontal: 8,
                      vertical: 0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaLink extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaLink({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // small circular icon background (very subtle)
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.backgroundAlt,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
