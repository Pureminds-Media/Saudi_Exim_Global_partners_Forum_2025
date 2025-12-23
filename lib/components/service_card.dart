import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/components/cached_url_image.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';
import 'package:saudiexim_mobile_app/utils/hero_utils.dart';
import '../models/service.dart';

/// Compact, tidy version of the service card.
///
/// Goals
/// - Shrink card height when subtitle is empty (no wasted vertical space)
/// - Make subtitle smaller and truly optional (no ghost spacing)
/// - Keep the "Details" button close to text (no lonely button at the bottom)
/// - Avoid Expanded in the text area so the content shrink-wraps naturally
class ServiceCard extends StatelessWidget {
  final Service service;
  final bool emphasized;
  final VoidCallback? onDetails;

  const ServiceCard({
    super.key,
    required this.service,
    this.emphasized = false,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isEmphasized = emphasized || service.emphasized;
    final borderColor = const Color(0xFFE6E6E6);
    final boxShadow = isEmphasized
        ? [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.12),
            ),
          ]
        : [
            BoxShadow(
              blurRadius: 6,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(0.06),
            ),
          ];

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final detailsLabel = isRtl ? 'التفاصيل' : 'Details';

    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final displayName = isAr
        ? ((service.nameAr ?? '').isNotEmpty ? service.nameAr! : service.name)
        : ((service.nameEn ?? '').isNotEmpty ? service.nameEn! : service.name);
    final displaySubtitle = isAr
        ? ((service.subtitleAr ?? '').isNotEmpty
              ? service.subtitleAr!
              : (service.subtitle))
        : ((service.subtitleEn ?? '').isNotEmpty
              ? service.subtitleEn!
              : (service.subtitle));

    final hasSubtitle = displaySubtitle.trim().isNotEmpty;

    // Typography — smaller subtitle, tighter leading.
    final titleStyle = TextStyle(
      fontSize: 18,
      height: 1.15,
      fontWeight: FontWeight.w800,
      color: AppColors.primary,
    );
    final subtitleStyle = const TextStyle(
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w500,
      color: Color(0xFF737373),
    );
    final detailsTextStyle =
        theme.textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0A3A67),
        );

    // Slightly smaller image when there is a subtitle, and overall smaller than before
    // so the whole card reads compact.
    // Increase overall card height by allocating more space to the photo.
    // Taller image makes the card feel more visual without changing text layout.
    final double imageHeight = hasSubtitle ? 170 : 160;

    return InkWell(
      onTap: onDetails ?? () => _goToDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: boxShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image (fixed height) with Hero to details page
            Container(
              height: imageHeight,
              color: const Color(0xFFF5F6F7),
              alignment: Alignment.center,
              child: Hero(
                tag: 'hero-service-${service.id}',
                flightShuttleBuilder: shapedHeroFlight(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildImage(
                  context,
                  (service.photoUrl != null && service.photoUrl!.isNotEmpty)
                      ? service.photoUrl!
                      : service.image,
                  max: imageHeight,
                ),
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),

            // Content — shrink-wraps (no Expanded), so card height adapts to content.
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Estimate if the title wraps to two lines at this width
                  final painter = TextPainter(
                    text: TextSpan(text: displayName, style: titleStyle),
                    maxLines: 2,
                    textDirection: Directionality.of(context),
                  )..layout(maxWidth: constraints.maxWidth);
                  final titleLines = painter.computeLineMetrics().length;
                  final bool titleWraps =
                      titleLines > 1 || painter.didExceedMaxLines;
                  final double spacingAboveButton = hasSubtitle
                      ? 8
                      : (titleWraps ? 12 : 8);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      AutoSizeText(
                        displayName,
                        style: titleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),

                      // Subtitle (only renders when present; no ghost newlines)
                      Visibility(
                        visible: hasSubtitle,
                        maintainState: false,
                        maintainSize: false,
                        maintainAnimation: false,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            displaySubtitle,
                            style: subtitleStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),

                      SizedBox(height: spacingAboveButton),

                      // Button sits right under the text (not pinned to the bottom).
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 120),
                          child: OutlinedButton(
                            onPressed: onDetails ?? () => _goToDetails(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              minimumSize: const Size(0, 36),
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0A3A67),
                              side: const BorderSide(
                                color: Color(0xFFDFDFDF),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: detailsTextStyle,
                            ),
                            child: Text(detailsLabel, style: detailsTextStyle),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToDetails(BuildContext context) {
    context.pushNamed(
      'service_details',
      pathParameters: {
        'categoryId': service.categoryId,
        'serviceId': service.id,
      },
    );
  }
}

Widget _buildImage(BuildContext context, String image, {double max = 150}) {
  final isNetwork = image.startsWith('http://') || image.startsWith('https://');
  if (isNetwork) {
    SecureImageCache? cache;
    try {
      cache = context.read<SecureImageCache>();
    } catch (_) {
      cache = null;
    }
    if (cache == null) {
      return const Icon(
        Icons.image_outlined,
        size: 48,
        color: Color(0xFFB0B0B0),
      );
    }
    return CachedUrlImage(
      image,
      cache: cache,
      fit: BoxFit.cover,
      height: max,
      shimmerEnabled: true,
    );
  }
  if (image.isEmpty) {
    return const Icon(
      Icons.image_not_supported_outlined,
      size: 48,
      color: Color(0xFFB0B0B0),
    );
  }
  return Image.asset(image, fit: BoxFit.contain, height: max);
}
