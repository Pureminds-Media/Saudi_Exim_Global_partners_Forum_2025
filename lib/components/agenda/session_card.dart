import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/models/lecture.dart';

import '../../theme/app_colors.dart';

/// Card displaying information about a single session (lecture).
class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.item});

  final Lecture item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final s = AppLocalizations.of(context)!;

    final title = isAr && item.titleAr.isNotEmpty ? item.titleAr : item.titleEn;
    final summary = isAr && item.summaryAr.isNotEmpty
        ? item.summaryAr
        : item.summaryEn;
    final topics = isAr ? item.topicsAr : item.topicsEn;

    return LayoutBuilder(
      builder: (ctx, c) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: .25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Time gutter
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 70),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.agendaTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Color(0xffC4C4C4),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.startTime,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.teal,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            width: 22,
                            height: 3,
                            color: AppColors.teal,
                          ),
                        ),
                        Text(
                          item.endTime,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider between gutter and content
                  const VerticalDivider(
                    width: 24,
                    thickness: 2,
                    color: Color(0xFFD9D9D9),
                    indent: 8,
                    endIndent: 8,
                  ),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (summary.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            summary,
                            textAlign: isAr ? TextAlign.right : TextAlign.left,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: .85,
                              ),
                            ),
                          ),
                        ],
                        if (topics.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            s.agendaSessionTopics,
                            textAlign: isAr ? TextAlign.right : TextAlign.left,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: topics
                                .map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('• '),
                                        Expanded(
                                          child: Text(
                                            e,
                                            textAlign: isAr
                                                ? TextAlign.right
                                                : TextAlign.left,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(height: 1.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
