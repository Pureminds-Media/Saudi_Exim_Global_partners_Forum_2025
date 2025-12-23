import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';

class BackTitleBar extends StatelessWidget implements PreferredSizeWidget {
  const BackTitleBar({
    super.key,
    required this.title,
    this.overrideBackRoute = false,
    this.iconColor = Colors.black,
    this.labelColor = const Color(0xFF9E9E9E),
    this.titleColor = Colors.black,
    this.backgroundColor,
    this.titleWordLimit = 10,
    this.minTitleFontSize = 12,
    this.maxTitleFontSize = 22,
    this.titleStepGranularity = 0.5,
  });

  final String title;
  final bool overrideBackRoute;
  final Color iconColor;
  final Color labelColor;
  final Color titleColor;
  final Color? backgroundColor;
  final int titleWordLimit;
  final double minTitleFontSize;
  final double maxTitleFontSize;
  final double titleStepGranularity;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    void handleBack() =>
        overrideBackRoute ? context.pop() : context.go('/menu');

    final textDirection = Directionality.of(context);
    final isLtr = textDirection == TextDirection.ltr;
    final s = AppLocalizations.of(context);
    final backLabel = s?.back ?? (isLtr ? 'Back' : 'Ø§Ù„Ø¹ÙˆØ¯Ø©');

    String clampWords(String input, int maxWords) {
      if (maxWords <= 0) return '';
      final parts = input.trim().split(RegExp(r'\s+'));
      if (parts.length <= maxWords) return input.trim();
      return parts.take(maxWords).join(' ') + '...';
    }

    final displayTitle = clampWords(title, titleWordLimit);

    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title expands to fill remaining space and scales down if needed.
            Expanded(
              child: AutoSizeText(
                displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                minFontSize: minTitleFontSize,
                maxFontSize: maxTitleFontSize,
                stepGranularity: titleStepGranularity,
                style: TextStyle(
                  fontSize: maxTitleFontSize,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Back action pinned to the end, with stable tap target.
            InkWell(
              onTap: handleBack,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      backLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Icon(
                        isLtr
                            ? Icons.arrow_forward_ios_rounded
                            : Icons.arrow_back_ios_new,
                        size: 16,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

