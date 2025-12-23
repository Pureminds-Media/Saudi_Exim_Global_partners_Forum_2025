import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';

/// Bold right-aligned section title used on detail pages.
class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    String display = text;
    // Normalize a couple of legacy hardcoded strings to proper localizations
    if (text.contains('U.O1U') || text.contains('معلومات')) {
      display = s?.serviceInfoTitle ?? text;
    } else if (text.contains('O\u0015U,U.U^U,O1') || text.contains('الموقع')) {
      display = s?.websiteTitle ?? text;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        display,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );
  }
}
