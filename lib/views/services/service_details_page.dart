import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/components/cached_url_image.dart';
import 'package:saudiexim_mobile_app/components/ui/title_back_top_bar.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';

import '../../components/buttons/app_outlined_button.dart';
import '../../components/section_divider.dart';
import '../../components/section_header.dart';
import '../../components/selectable_link_text.dart';
import '../../models/service.dart';
import '../../viewmodels/service_catalog_view_model.dart';
import '../../viewmodels/service_details_view_model.dart';

// ==============================
// Helpers: localization & tokens
// ==============================
extension LocaleX on Locale {
  bool get isAr => languageCode == 'ar';
}

String pickLang(Locale locale, {String? ar, String? en, String fallback = ''}) {
  String clean(String? s) {
    final v = (s ?? '').trim();
    if (v.toLowerCase() == 'n/a') return '';
    return v;
  }

  final a = clean(ar);
  final e = clean(en);
  final f = clean(fallback);
  if (locale.isAr) return a.isNotEmpty ? a : (e.isNotEmpty ? e : f);
  return e.isNotEmpty ? e : (a.isNotEmpty ? a : f);
}

const kHeroHeight = 300.0;
const kPageHPad = 24.0;

/// Full-detail Service page displaying optional sections resolved by `serviceId`.
class ServiceDetailsPage extends StatelessWidget {
  final String serviceId;
  const ServiceDetailsPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ServiceCatalogViewModel>();
    final service = catalog.serviceById(serviceId);

    final t = AppLocalizations.of(context)!;

    if (service == null || service.id.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 48),
                const SizedBox(height: 12),
                Text(
                  t.notFound,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(t.back),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ServiceDetailsViewModel(service: service),
      child: _ServiceDetailsScaffold(service: service),
    );
  }
}

class _ServiceDetailsScaffold extends StatelessWidget {
  final Service service;
  const _ServiceDetailsScaffold({required this.service});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = AppLocalizations.of(context)!;

    final title = pickLang(
      locale,
      ar: service.nameAr,
      en: service.nameEn,
      fallback: service.name,
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: kHeroHeight,
              backgroundColor: Colors.black,
              surfaceTintColor: Colors.black,
              automaticallyImplyLeading: false,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              flexibleSpace: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'hero-service-${service.id}',
                    child: ServiceHeroImage(service: service),
                  ),
                  const _HeroGradientOverlay(),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: BackTitleBar(
                      title: title,
                      overrideBackRoute: true,
                      iconColor: Colors.white,
                      labelColor: Colors.white,
                      titleColor: Colors.white,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  kPageHPad,
                  24,
                  kPageHPad,
                  32,
                ),
                child: _ServiceDetailsBody(service: service, t: t),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceHeroImage extends StatelessWidget {
  final Service service;
  const ServiceHeroImage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final cache = context.read<SecureImageCache>();
    final full = (service.photoUrl ?? '').trim();
    final img = (service.image).trim();

    if (full.isNotEmpty) {
      final label = pickLang(
        Localizations.localeOf(context),
        ar: service.nameAr,
        en: service.nameEn,
        fallback: service.name,
      );
      return Semantics(
        label: '$label image',
        image: true,
        child: CachedUrlImage(
          full,
          cache: cache,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    if (img.isNotEmpty) {
      final label = pickLang(
        Localizations.localeOf(context),
        ar: service.nameAr,
        en: service.nameEn,
        fallback: service.name,
      );
      if (img.startsWith('http')) {
        return Semantics(
          label: '$label image',
          image: true,
          child: CachedUrlImage(
            img,
            cache: cache,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      }
      return Semantics(
        label: '$label image',
        image: true,
        child: Image.asset(
          img,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    return const ColoredBox(color: Color(0xFFD9D9D9));
  }
}

class _HeroGradientOverlay extends StatelessWidget {
  const _HeroGradientOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Color(0xCC000000), Color(0x00000000)],
        ),
      ),
    );
  }
}

class _ServiceDetailsBody extends StatelessWidget {
  final Service service;
  final AppLocalizations t;
  const _ServiceDetailsBody({required this.service, required this.t});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    final cityText = pickLang(
      locale,
      ar: service.cityAr,
      en: service.cityEn,
      fallback: service.city,
    );
    final shortText = pickLang(
      locale,
      ar: service.subtitleAr,
      en: service.subtitleEn,
      fallback: service.subtitle,
    );
    final bodyText = pickLang(
      locale,
      ar: service.descriptionAr,
      en: service.descriptionEn,
      fallback: service.description,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Location row (auto LTR/RTL)
        // Row(
        //   textDirection: Directionality.of(context),
        //   children: [
        //     const Icon(Icons.location_on, size: 20),
        //     const SizedBox(width: 6),
        //     Expanded(
        //       child: Text(
        //         cityText,
        //         style: Theme.of(context).textTheme.titleSmall?.copyWith(
        //           fontWeight: FontWeight.w500,
        //           color: Theme.of(context).colorScheme.onSurface,
        //         ),
        //         overflow: TextOverflow.ellipsis,
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 16),
        if (shortText.isNotEmpty) ...[
          Text(
            shortText,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
        ],

        if (bodyText.isNotEmpty) ...[
          SectionHeader(text: t.serviceInfoTitle),
          Text(
            bodyText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.start,
          ),
          const SectionDivider(),
        ],

        if ((service.website ?? '').isNotEmpty) ...[
          SectionHeader(text: t.websiteTitle),
          SelectableLinkText(url: service.website!),
          const SectionDivider(),
        ],

        Consumer<ServiceDetailsViewModel>(
          builder: (_, vm, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (vm.hasMap) ...[
                SectionHeader(text: t.googleMaps),
                AppOutlinedButton(
                  label: t.openMap,
                  onPressed: vm.openMap,
                  size: const Size(180, 56),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
