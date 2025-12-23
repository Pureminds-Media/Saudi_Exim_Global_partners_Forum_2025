import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:saudiexim_mobile_app/utils/hero_utils.dart';
import 'package:saudiexim_mobile_app/utils/haptic_feedback_helper.dart';

import '../../viewmodels/cities_view_model.dart';
import '../../viewmodels/service_catalog_view_model.dart';
import '../../components/city_filter_item.dart';
import '../../gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/components/cached_url_image.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';
import 'package:saudiexim_mobile_app/components/ui/no_network_placeholder.dart';
import 'package:saudiexim_mobile_app/utils/network_error_classifier.dart';
import 'package:saudiexim_mobile_app/components/services/city_chips_skeleton.dart';
import 'package:saudiexim_mobile_app/views/services/widgets/city_title_header.dart';
import 'package:saudiexim_mobile_app/components/services/city_list_skeleton.dart';

class CitiesPage extends StatelessWidget {
  const CitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiceCatalogViewModel>();
    return Scaffold(
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (_) => CitiesViewModel()..load(),
          child: Consumer<CitiesViewModel>(
            builder: (context, citiesVm, _) {
              final isLoading = citiesVm.loading;
              final cities = citiesVm.cities;
              final s = AppLocalizations.of(context);

              // Show offline placeholder if a network error occurred and no data is available
              final error = citiesVm.error;
              if (error != null && cities.isEmpty && isNetworkErrorMessage(error)) {
                return NoNetworkPlaceholder(
                  useSafeArea: false,
                  onRetry: () => context.read<CitiesViewModel>().load(),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CityTitleHeaderBox(
                    selectedIndex: 0,
                    title: s?.servicesNearby ?? 'Nearby Services',
                    heroTag: 'city-title-nearby',
                    height: 52,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    backgroundColor: Colors.white,
                    titleColor: AppColors.black,
                  ),
                  const SizedBox(height: 12),
                  // City Chips row (DRY: CityFilterItem) or skeletons when loading
                  if (isLoading && cities.isEmpty)
                    const CityChipsSkeleton()
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // All Saudia
                          CityFilterItem(
                            key: const ValueKey('all-saudi'),
                            label:
                                s?.cityAllSaudia ??
                                (vm.cities.isNotEmpty
                                    ? vm.cities[0]
                                    : 'Saudi Arabia'),
                            image: vm.cityImages.isNotEmpty
                                ? vm.cityImages[0]
                                : '',
                            // On CitiesPage, do not show any pre-selected chip
                            selected: false,
                            onTap: () {
                              vm.selectCity(0);
                              context.pushNamed('services_categories');
                            },
                          ),
                          Container(
                            width: 1,
                            height: 48,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: const Color(0xFFDFDFDF),
                          ),
                          for (final c in cities)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 12,
                              ),
                              child: Builder(
                                builder: (context) {
                                  final lang = Localizations.localeOf(
                                    context,
                                  ).languageCode;
                                  final label = lang == 'ar'
                                      ? (c.nameAr.isNotEmpty
                                            ? c.nameAr
                                            : c.nameEn)
                                      : (c.nameEn.isNotEmpty
                                            ? c.nameEn
                                            : c.nameAr);
                                  final idx = vm.indexForCityId(c.id) ?? 0;

                                  return CityFilterItem(
                                    key: ValueKey('city-${c.id}-$label'),
                                    label: label,
                                    image: c.photoUrl ?? '',
                                    // On CitiesPage, chips should appear unselected
                                    selected: false,
                                    onTap: () {
                                      vm.selectCity(idx);
                                      context.pushNamed('services_categories');
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Divider(thickness: 1, color: Color(0xFFDFDFDF)),
                  const SizedBox(height: 12),
                  // City cards (skeleton while loading)
                  Expanded(
                    child: (isLoading && cities.isEmpty)
                        ? const CityListSkeleton()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemBuilder: (context, index) {
                              final c = cities[index];
                              final locale = Localizations.localeOf(
                                context,
                              ).languageCode;
                              final name = locale == 'ar' && c.nameAr.isNotEmpty
                                  ? c.nameAr
                                  : c.nameEn;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Hero(
                                    tag: 'city-name-$name',
                                    child: Text(
                                      name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0A3A67),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () async {
                                      await triggerSelectionHaptic();
                                      // Best-effort mapping to VM city index by English/Arabic name
                                      final idx = vm.indexForCityId(c.id) ?? 0;
                                      vm.selectCity(idx);
                                      context.pushNamed('services_categories');
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.08,
                                            ),
                                            blurRadius: 14,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Hero(
                                        tag:
                                            'city-img-${c.nameEn.isNotEmpty ? c.nameEn : c.nameAr}',
                                        flightShuttleBuilder: shapedHeroFlight(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child:
                                            c.photoUrl != null &&
                                                c.photoUrl!.isNotEmpty
                                            ? Semantics(
                                                label: '$name image',
                                                image: true,
                                                child: CachedUrlImage(
                                                  c.photoUrl!,
                                                  cache: context
                                                      .read<SecureImageCache>(),
                                                  height: 180,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Container(
                                                height: 180,
                                                color: const Color(0xFFD9D9D9),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFFDFDFDF),
                              ),
                            ),
                            itemCount: cities.length,
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
