import 'package:flutter/material.dart';

import '../../gen/l10n/app_localizations.dart';
import '../../theme/app_colors.dart';

/// A reusable offline state with bilingual messaging and subtle styling.
class NoNetworkPlaceholder extends StatelessWidget {
  const NoNetworkPlaceholder({
    super.key,
    this.onRetry,
    this.useSafeArea = true,
  });

  final VoidCallback? onRetry;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.brandVerticalGradient,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14303030),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                s.noNetworkTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ) ??
                    const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                s.noNetworkSubtitle,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ) ??
                    const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                s.noNetworkDescription,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textBody,
                      height: 1.6,
                    ) ??
                    const TextStyle(
                      fontSize: 15,
                      color: AppColors.textBody,
                      height: 1.6,
                    ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    s.noNetworkRetry,
                    style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ) ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!useSafeArea) return content;
    return SafeArea(child: content);
  }
}
