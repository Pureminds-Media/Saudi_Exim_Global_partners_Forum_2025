import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';

/// A cleaned-up, DRY implementation of the original page.
///
/// - No duplicated Arabic/English widget trees; content is data-driven.
/// - Clear building blocks (_HeroHeader, _InfoCard, _FeaturesCard).
/// - Consistent spacing/typography and minimal Containers.
/// - Preserves the original look & text.
class HomeHeaderSection extends StatelessWidget {
  final bool
  hideTitle; // (kept for API compatibility; not used in original layout)
  final String introTitle; // (kept for future use)
  final String introBody; // (kept for future use)

  const HomeHeaderSection({
    super.key,
    this.hideTitle = false,
    required this.introTitle,
    required this.introBody,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final c = _pageContent(isRtl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroHeader(
          backgroundAsset: c.heroAsset,
          headline: c.heroHeadline,
          subHeadline: c.heroSubHeadline,
          align: isRtl ? Alignment.centerRight : Alignment.centerLeft,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _InfoCard(
            dateLine: c.dateLine,
            paragraphs: c.introParagraphs,
            isRtl: isRtl,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _FeaturesCard(
            title: c.featuresTitle,
            bullets: c.featuresBullets,
            isRtl: isRtl,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ------------------------------ CONTENT MODEL ------------------------------

class _Content {
  final String heroAsset;
  final String heroHeadline;
  final String heroSubHeadline;
  final String dateLine;
  final String featuresTitle;
  final List<InlineSpan>
  introParagraphs; // multiple paragraphs as InlineSpan each
  final List<String> featuresBullets;

  const _Content({
    required this.heroAsset,
    required this.heroHeadline,
    required this.heroSubHeadline,
    required this.dateLine,
    required this.featuresTitle,
    required this.introParagraphs,
    required this.featuresBullets,
  });
}

_Content _pageContent(bool isRtl) {
  if (isRtl) {
    // Arabic content
    const bodyColor = AppColors.textPrimary;
    TextStyle reg(double fs) => const TextStyle(
      color: bodyColor,
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1.78,
    );

    TextStyle eximExtra(double fs) => const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.78,
      fontFamily: 'Alexandria',
    );

    return _Content(
      heroAsset: 'assets/homePage/ArLandingBg.png',
      heroHeadline: 'تمكين التجارة العالمية',
      heroSubHeadline:
          'معاً لبناء جسور التعاون نحو مستقبل اقتصادي متنوع ومستدام',
      dateLine:
          '19 – 20 نوفمبر 2025م | فندق وشقق هيلتون الرياض | الرياض، المملكة العربية السعودية',
      featuresTitle: 'مزايا المنتدى',
      introParagraphs: [
        TextSpan(
          text: 'تحتضن العاصمة الرياض ',
          style: reg(18),
          children: [
            TextSpan(
              text: 'المنتدى العالمي لشركاء بنك التصدير والاستيراد السعودي ',
              style: eximExtra(18),
            ),
            TextSpan(
              text:
                  'خلال يومين من 19 – 20 نوفمبر 2025م، وهو منصة دولية تناقش مستقبل التجارة العالمية وتمويل الصادرات، بمشاركة نخبة من قيادات القطاعين الحكومي والخاص في مختلف أنحاء العالم، يمثلون المؤسسات الحكومية، ووكالات ائتمان الصادرات، وبنوك التصدير والاستيراد، ومؤسسات التمويل الإنمائي، والمنظمات متعددة الأطراف، والبنوك التجارية.',
              style: reg(18),
            ),
          ],
        ),
        const TextSpan(
          text:
              'ويهدف المنتدى إلى تعزيز الحوار الإستراتيجي، وتقوية الشراكات، ودعم الابتكار في تمويل الصادرات، في ظل التحول الاقتصادي العالمي.',
          style: TextStyle(
            color: bodyColor,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.78,
          ),
        ),
        const TextSpan(
          text:
              'وسيتعرف المشاركون في المنتدى على أحدث تحولات التجارة العالمية، والفرص المتاحة في الاقتصاد السعودي في ظل رؤية 2030، إلى جانب تمكينهم من مناقشة المختصين في مجالات الابتكار والذكاء الاصطناعي والرقمنة.',
          style: TextStyle(
            color: bodyColor,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.78,
          ),
        ),
        TextSpan(
          text: 'ويُعد ',
          style: reg(18),
          children: [
            TextSpan(
              text: 'المنتدى العالمي لشركاء بنك التصدير والاستيراد السعودي، ',
              style: eximExtra(18),
            ),
            TextSpan(
              text:
                  'فرصة لبناء العلاقات، وتبادل المعرفة، وإقامة شراكات تسهم في تعزيز التنوع والاستدامة في المنظومات التجارية.',
              style: TextStyle(
                color: bodyColor,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 1.78,
              ),
            ),
          ],
        ),
      ],
      featuresBullets: const [
        'منصة تجمع أكثر من 300 من صناع القرار في مجالات التجارة وتمويل الصادرات يمثلون 70 دولة حول العالم للتواصل وتبادل الخبرات.',
        'أكثر من 40 متحدثًا بارزًا من جهات حكومية وصناعية ومالية.',
        'إسهامات صناع القرار في رسم ملامح مستقبل الابتكار في التجارة وتمويل الصادرات.',
        'جلسات نقاشية حول الاقتصاد السعودي، والذكاء الاصطناعي والرقمنة، والتجارة بين الدول، ومنظومات التصدير المستدامة.',
        'فرص لعقد الاجتماعات وتوسيع شبكات العلاقات الدولية.',
        'عرض الابتكارات في ائتمان الصادرات والتأمين وصادرات الخدمات.',
      ],
    );
  }

  // English content
  final textColor = AppColors.textPrimary;
  TextStyle reg(double fs) => TextStyle(
    color: textColor,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.78,
  );

  TextStyle eximExtra(double fs) => const TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.78,
    fontFamily: 'Alexandria',
  );

  return _Content(
    heroAsset: 'assets/homePage/EnLandingBg.png',
    heroHeadline: 'EMPOWERING GLOBAL TRADE',
    heroSubHeadline: 'Partnerships for a Sustainable and Diversified Future',
    dateLine: '19 – 20 November 2025 | Hilton Riyadh | Riyadh, Saudi Arabia',
    featuresTitle: 'Key Event Features',
    introParagraphs: [
      TextSpan(
        text: 'The ',
        style: reg(18),
        children: [
          TextSpan(text: 'Saudi EXIM', style: eximExtra(18)),
          TextSpan(
            text:
                ' Global Partners Forum will be held in Riyadh on 19 – 20 November 2025. It is an international, high-level convening hosted by ',
            style: reg(18),
          ),
          TextSpan(text: 'Saudi EXIM', style: eximExtra(18)),
          TextSpan(
            text:
                ' to advance strategic dialogue on the future of global trade and export finance. It will bring together senior decision-makers from governments, export credit agencies, EXIM banks, development finance institutions, multilateral organisations, commercial banks, and the private sector to explore the future of trade, finance, and economic transformation.',
            style: reg(18),
          ),
        ],
      ),
      TextSpan(
        text:
            "Anchored in the Kingdom's Vision 2030, the Forum is designed to advance strategic dialogue, strengthen cross-border partnerships, and promote innovation in export finance. Across two days, participants will gain insights into the changing global trade landscape, the opportunities in the Saudi economy, and the transformative potential of innovation, AI, and digitalisation, while fostering collaboration between advanced economies and the Global South.",
        style: reg(18),
      ),
      TextSpan(
        text: 'The ',
        style: reg(18),
        children: [
          TextSpan(text: 'Saudi EXIM', style: eximExtra(18)),
          TextSpan(
            text:
                ' Global Partners Forum promises an excellent opportunity for networking, knowledge-sharing, and building actionable partnerships to promote diversified, resilient, and sustainable trade ecosystems.',
            style: reg(18),
          ),
        ],
      ),
    ],
    featuresBullets: const [
      'A platform uniting more than 300 global decision-makers in trade and export finance from 70 countries, fostering meaningful connections and knowledge exchange.',
      'Over 40 distinguished speakers representing government, industry, and finance.',
      'Strategic insights from leaders driving the future of innovation in trade and export finance.',
      'In-depth discussions on the Saudi economy, AI and digitalization, global trade dynamics, and sustainable export ecosystems.',
      'Outstanding opportunities to network, forge partnerships, and expand international reach.',
      'A showcase of cutting-edge practices in export credit, insurance, and service exports.',
    ],
  );
}

// ------------------------------ BUILDING BLOCKS -----------------------------

class _HeroHeader extends StatelessWidget {
  final String backgroundAsset;
  final String headline;
  final String subHeadline;
  final Alignment align;

  const _HeroHeader({
    required this.backgroundAsset,
    required this.headline,
    required this.subHeadline,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: SizedBox(
        height: 280,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(backgroundAsset, fit: BoxFit.cover),
            // Optional readability gradient (kept off by default):
            // Positioned.fill(
            //   child: DecoratedBox(
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.centerLeft,
            //         end: Alignment.centerRight,
            //         colors: [Colors.black.withOpacity(0.25), Colors.transparent],
            //       ),
            //     ),
            //   ),
            // ),
            Positioned.fill(
              child: Align(
                alignment: align,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth.isFinite
                            ? constraints.maxWidth
                            : MediaQuery.of(context).size.width;
                        final logoWidth = math.min(availableWidth * 0.5, 280.0);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Image.asset(
                                'assets/logo-white.png',
                                width: logoWidth,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              headline,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              textScaler: const TextScaler.linear(1.1),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subHeadline,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              textScaler: const TextScaler.linear(1.05),
                            ),
                          ],
                        );
                      },
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

class _InfoCard extends StatelessWidget {
  final String dateLine;
  final List<InlineSpan> paragraphs;
  final bool isRtl;

  const _InfoCard({
    required this.dateLine,
    required this.paragraphs,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFDEDEDE);

    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C161616),
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateLine,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                color: Color(0xFF174B86),
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 2, thickness: 2, color: borderColor),
            const SizedBox(height: 24),
            // Intro paragraphs
            for (int i = 0; i < paragraphs.length; i++) ...[
              Text.rich(
                paragraphs[i],
                textScaler: const TextScaler.linear(1.05),
              ),
              if (i != paragraphs.length - 1) const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeaturesCard extends StatelessWidget {
  final String title;
  final List<String> bullets;
  final bool isRtl;

  const _FeaturesCard({
    required this.title,
    required this.bullets,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFDEDEDE);

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C161616),
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: isRtl ? const Color(0xFF174B86) : AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 21),
            DecoratedBox(
              decoration: ShapeDecoration(
                color: const Color(0xFFF8F8F8),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: borderColor),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < bullets.length; i++) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              color: isRtl
                                  ? const Color(0xFF174B86)
                                  : AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              bullets[i],
                              textAlign: isRtl
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: TextStyle(
                                color: isRtl
                                    ? const Color(0xFF174B86)
                                    : AppColors.textPrimary,
                                fontSize: isRtl ? 18 : 17,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (i != bullets.length - 1) const SizedBox(height: 8),
                    ],
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
