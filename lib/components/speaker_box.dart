import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/components/cached_url_image.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';

import '../models/speaker.dart';

class SpeakerBox extends StatelessWidget {
  final Speaker speaker;
  final bool isActive;
  final VoidCallback onTap;

  const SpeakerBox({
    super.key,
    required this.speaker,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final isRtl = locale.languageCode == 'ar';

    const teal = AppColors.teal;
    const textDark = Color(0xFF1C1F1F);

    final rawTitle = (isRtl ? speaker.title_ar : speaker.title_en);
    final split = _splitTitle(rawTitle);
    final jobTitle = split.item1;
    final company = split.item2;

    // NOTE: removed the shared AutoSizeGroup so job & company scale independently

    final hasJob = jobTitle.isNotEmpty;
    final hasCompany = company.isNotEmpty;

    // Dynamic header/body split: if there's little text, give more room to the header,
    // otherwise give more to the body.
    double headerFraction() {
      if (hasJob && hasCompany) return 0.48;
      if (hasJob || hasCompany) return 0.52;
      return 0.60; // name only → taller header looks balanced
    }

    // Dynamic flex so we don't leave empty vertical space when some fields are missing.
    final nameFlex = (hasJob || hasCompany) ? 40 : 100;
    final jobFlex = hasJob ? (hasCompany ? 34 : 60) : 0;
    final companyFlex = hasCompany ? (hasJob ? 26 : 40) : 0;

    // Name can use more lines (and grow) when it's the only thing we have.
    final nameMaxLines = (hasJob || hasCompany) ? 2 : 4;

    return InkWell(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? const Color(0xFF33AAA6) : Colors.transparent,
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardH = constraints.maxHeight;
              final headerH = cardH * headerFraction();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Header (photo or initials) =====
                  SizedBox(
                    height: headerH,
                    width: double.infinity,
                    child: _Header(
                      photoAsset: speaker.photoAsset,
                      photoUrl: speaker.photoUrl,
                      initials: speaker.initials,
                    ),
                  ),

                  // ===== Moderator Strip =====
                  if (speaker.isModerator)
                    Container(
                      width: 308,
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(color: const Color(0xFF03B2AE)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Text(
                            isRtl ? 'مدير الجلسة' : 'Moderator',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Alexandria',
                              fontWeight: FontWeight.w700,
                              height: 1.43,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ===== Body (name, job, company) =====
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NAME (Expanded so it participates in the height distribution)
                          Expanded(
                            flex: nameFlex,
                            child: AutoSizeText(
                              isRtl ? speaker.name_ar : speaker.name_en,
                              textAlign: isRtl
                                  ? TextAlign.right
                                  : TextAlign.left,
                              maxLines: nameMaxLines,
                              // allow growth to use extra space
                              maxFontSize: 20,
                              minFontSize: 12,
                              stepGranularity: 0.5,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: teal,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                height: 1.38,
                              ),
                            ),
                          ),

                          if (hasJob) const SizedBox(height: 4),

                          // JOB TITLE — scales independently; keep it more prominent
                          if (hasJob)
                            Flexible(
                              flex: jobFlex,
                              child: AutoSizeText(
                                jobTitle,
                                textAlign: isRtl
                                    ? TextAlign.right
                                    : TextAlign.left,
                                maxLines: 2,
                                // let job stay bigger than company when both are long
                                maxFontSize: 16,
                                minFontSize: 11,
                                stepGranularity: 0.5,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  height: 1.32,
                                ),
                              ),
                            ),

                          if (hasCompany) const SizedBox(height: 3),

                          // COMPANY — can shrink a bit more than job
                          if (hasCompany)
                            Expanded(
                              flex: companyFlex,
                              child: AutoSizeText(
                                company,
                                textAlign: isRtl
                                    ? TextAlign.right
                                    : TextAlign.left,
                                maxLines: 2,
                                maxFontSize: 14,
                                minFontSize: 9,
                                stepGranularity: 0.5,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textDark,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13,
                                  height: 1.32,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? photoAsset;
  final String? photoUrl;
  final String initials;

  const _Header({
    required this.photoAsset,
    required this.photoUrl,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    const bg = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF2F4F5), Color(0xFFE7EAEC), Color(0xFFDADFE2)],
      stops: [0.0, 0.55, 1.0],
    );

    Widget buildInitials() => Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          initials,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            color: Color(0x26000000),
          ),
        ),
      ),
    );

    Widget? buildPhoto() {
      if (photoUrl != null && photoUrl!.isNotEmpty) {
        final cache = context.read<SecureImageCache>();
        return Transform.scale(
          scale: 1,
          child: CachedUrlImage(
            photoUrl!,
            cache: cache,
            fit: BoxFit.contain,
            shimmerBaseColor: const Color(0xFFE7EAEC),
            shimmerHighlightColor: const Color(0xFFF4F6F7),
            placeholder: buildInitials(),
          ),
        );
      }
      if (photoAsset != null && photoAsset!.isNotEmpty) {
        return Transform.scale(
          scale: 1,
          child: Image.asset(
            photoAsset!,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        );
      }
      return null;
    }

    return Container(
      decoration: const BoxDecoration(gradient: bg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          buildPhoto() ?? buildInitials(),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 18,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x55FFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Minister ... - Egypt" -> (job, company)
({String item1, String item2}) _splitTitle(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return (item1: '', item2: '');
  final parts = t.split(RegExp(r'\s*[-–—]\s*'));
  if (parts.length >= 2) {
    return (
      item1: parts.first.trim(),
      item2: parts.sublist(1).join(' - ').trim(),
    );
  }
  return (item1: t, item2: '');
}
