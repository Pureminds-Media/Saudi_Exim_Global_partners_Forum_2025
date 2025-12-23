import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';
import 'package:saudiexim_mobile_app/components/cached_url_image.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';
import 'package:saudiexim_mobile_app/components/cached_svg.dart';
import 'package:saudiexim_mobile_app/utils/haptic_feedback_helper.dart';
import 'package:saudiexim_mobile_app/components/services/category_choice_chip.dart';
import 'package:saudiexim_mobile_app/components/ui/no_network_placeholder.dart';
import 'package:saudiexim_mobile_app/utils/network_error_classifier.dart';

import '../../viewmodels/cities_view_model.dart';
import '../../viewmodels/service_catalog_view_model.dart';
import '../../repositories/service_repository.dart';
import '../../models/service.dart';
import '../../models/city.dart';
import '../../gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/utils/hero_utils.dart';
import 'package:saudiexim_mobile_app/views/services/widgets/city_dropdown.dart';
import 'package:saudiexim_mobile_app/views/services/widgets/city_title_header.dart';
import 'package:saudiexim_mobile_app/views/services/widgets/city_description.dart';
import 'package:saudiexim_mobile_app/views/services/widgets/services_horizontal_list.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String? _selectedCategoryId;
  List<Service> _categoryServices = const [];
  bool _loadingServices = false;
  String? _servicesError;
  final _defaultRepo = ServiceRepository();
  ServiceCatalogViewModel? _vmListener;
  bool _autoSelectScheduled = false;
  bool _autoSelectPendingReset = false;
  bool _defaultCityApplied = false;

  // Simple in-memory cache: key = 'categoryId|cityId-or-all'
  final Map<String, List<Service>> _servicesCache = {};
  String _cacheKey(String catId, String? cityId) => '$catId|${cityId ?? 'all'}';

  int _loadToken = 0; // guards against out-of-order async responses

  @override
  void initState() {
    super.initState();
    _scheduleAutoSelect();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<ServiceCatalogViewModel>();
    if (!identical(_vmListener, vm)) {
      _vmListener?.removeListener(_onVmChanged);
      _vmListener = vm;
      _vmListener?.addListener(_onVmChanged);
    }
    _scheduleAutoSelect();
  }

  @override
  void dispose() {
    _vmListener?.removeListener(_onVmChanged);
    super.dispose();
  }

  Future<void> _loadServices(ServiceCatalogViewModel vm) async {
    final catId = _selectedCategoryId;
    if (catId == null) return;

    // Resolve repository (injected or default)
    late ServiceRepository repo;
    try {
      repo = Provider.of<ServiceRepository>(context, listen: false);
    } catch (_) {
      repo = _defaultRepo;
    }

    // Determine city filter and cache key
    final cityId = vm.selectedCityIndex == 0
        ? null
        : await repo.cityIdForName(vm.selectedCity);
    final key = _cacheKey(catId, cityId?.toString());

    // Serve instantly from cache if present (no spinner)
    final cached = _servicesCache[key];
    if (cached != null) {
      // keep VM in sync when serving from cache
      vm.replaceServicesForCategory(catId, cached);
      if (mounted) {
        setState(() {
          _categoryServices = cached;
          _loadingServices = false;
          _servicesError = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _loadingServices = true;
        _servicesError = null;
      });
    }

    final int token = ++_loadToken;
    try {
      final results = await repo.fetchServicesByCategory(catId, cityId: cityId);
      if (token != _loadToken) return; // superseded by a newer request

      // Cache & persist in VM so details screens can read
      _servicesCache[key] = results;
      vm.replaceServicesForCategory(catId, results);

      if (mounted) {
        setState(() {
          _categoryServices = results;
          _servicesError = null;
        });
      }
    } catch (error) {
      if (token != _loadToken) return;
      if (mounted) {
        setState(() {
          _categoryServices = const [];
          _servicesError = error.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _loadingServices = false);
    }
  }

  void _onVmChanged() {
    if (!mounted) return;
    _scheduleAutoSelect();
  }

  void _maybeApplyDefaultCity(
    ServiceCatalogViewModel vm,
    List<City> backendCities,
  ) {
    if (_defaultCityApplied) return;
    if (vm.selectedCityIndex != 0) {
      _defaultCityApplied = true;
      return;
    }

    int? targetIndex = vm.indexForCityName('الرياض') ?? vm.indexForCityName('Riyadh');
    if (targetIndex == null && backendCities.isNotEmpty) {
      try {
        final match = backendCities.firstWhere(
          (c) => c.nameAr == 'الرياض' || c.nameEn == 'Riyadh',
        );
        targetIndex = vm.indexForCityId(match.id);
      } catch (_) {
        // ignore if not found
      }
    }

    if (targetIndex != null && targetIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _defaultCityApplied) return;
        setState(() {
          vm.selectCity(targetIndex!);
          _selectedCategoryId = null;
          _categoryServices = const [];
          _servicesError = null;
          _loadingServices = false;
          _loadToken++;
          _defaultCityApplied = true;
        });
        _scheduleAutoSelect(reset: true);
      });
    }
  }

  void _scheduleAutoSelect({bool reset = false}) {
    if (_autoSelectScheduled) {
      _autoSelectPendingReset = _autoSelectPendingReset || reset;
      return;
    }
    _autoSelectScheduled = true;
    _autoSelectPendingReset = reset;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSelectScheduled = false;
      final shouldReset = _autoSelectPendingReset;
      _autoSelectPendingReset = false;
      if (!mounted) return;
      _performAutoSelect(reset: shouldReset);
    });
  }

  void _performAutoSelect({required bool reset}) {
    final vm = context.read<ServiceCatalogViewModel>();
    final categories = vm.categories;

    if (categories.isEmpty) {
      if (_selectedCategoryId != null || _categoryServices.isNotEmpty) {
        setState(() {
          _selectedCategoryId = null;
          _categoryServices = const [];
          _loadingServices = false;
        });
      }
      return;
    }

    final bool selectedStillValid = _selectedCategoryId != null &&
        categories.any((c) => c.id == _selectedCategoryId);

    if (!reset && selectedStillValid) {
      final updated = vm.servicesForCategory(_selectedCategoryId!);
      if (updated.isNotEmpty) {
        final key = _cacheKey(
          _selectedCategoryId!,
          _currentCityCacheKey(vm),
        );
        _servicesCache[key] = updated;
      }
      if (!_servicesListsEqual(_categoryServices, updated) ||
          (updated.isNotEmpty && _servicesError != null)) {
        setState(() {
          _categoryServices = updated;
          if (updated.isNotEmpty) {
            _servicesError = null;
            _loadingServices = false;
          }
        });
      }
      return;
    }

    final first = categories.first;
    final services = vm.servicesForCategory(first.id);
    final cacheKey = _cacheKey(first.id, _currentCityCacheKey(vm));
    if (services.isNotEmpty) {
      _servicesCache[cacheKey] = services;
    }

    setState(() {
      _selectedCategoryId = first.id;
      _categoryServices = services;
      _servicesError = null;
      _loadingServices = services.isEmpty;
    });

    if (services.isEmpty) {
      _loadServices(vm);
    }
  }

  String? _currentCityCacheKey(ServiceCatalogViewModel vm) {
    if (vm.selectedCityIndex == 0) return null;
    final city = vm.selectedCityModel;
    if (city == null) return null;
    return city.id.toString();
  }

  bool _servicesListsEqual(List<Service> a, List<Service> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i]) && a[i].id != b[i].id) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiceCatalogViewModel>();
    return Scaffold(
      body: SafeArea(
        child: _withCitiesVm(
          child: Consumer<CitiesViewModel>(
            builder: (context, citiesVm, _) {
              final cache = context.read<SecureImageCache>();
              final s = AppLocalizations.of(context);
              final langCode = Localizations.localeOf(context).languageCode;
              final isAr = langCode == 'ar';

              final cities = citiesVm.cities;
              final selectedCityModel = vm.selectedCityModel;
              _maybeApplyDefaultCity(vm, cities);
              final City cityObj = _resolveCity(selectedCityModel, cities);

              final bool isInitialDataMissing =
                  vm.categories.isEmpty && cities.isEmpty;
              // Do not return early with a full-screen spinner; instead, render the
              // page scaffolding and show skeleton chips at the top via CitySelector.

              final errorMessage = vm.error ?? citiesVm.error;
              if (errorMessage != null && isInitialDataMissing) {
                if (isNetworkErrorMessage(errorMessage)) {
                  return NoNetworkPlaceholder(
                    useSafeArea: false,
                    onRetry: () {
                      context.read<ServiceCatalogViewModel>().init();
                      context.read<CitiesViewModel>().load();
                    },
                  );
                }
                final fallback = isAr
                    ? 'حدث خطأ أثناء تحميل البيانات.'
                    : 'Something went wrong while loading data.';
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      fallback,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }

              final cityDesc = _cityDescriptionForLocale(
                context,
                cityObj.desAr,
                cityObj.desEn,
              );
              final hasCityDesc =
                  vm.selectedCityIndex != 0 && cityDesc.isNotEmpty;

              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  CityTitleHeader(
                    selectedIndex: 0,
                    title: s?.servicesNearby ?? 'Nearby Services',
                    heroTag: 'city-title-nearby',
                    titleColor: AppColors.black,
                  ),

                  // City selection dropdown (replaces chips row)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: CityDropdown(
                        cities: cities,
                        selectedIndex: vm.selectedCityIndex,
                        isAr: isAr,
                        loading: citiesVm.loading && cities.isEmpty,
                        onChanged: (index) {
                          setState(() {
                            vm.selectCity(index);
                            _selectedCategoryId = null;
                            _categoryServices = const [];
                            _servicesError = null;
                            _loadingServices = false;
                            _loadToken++;
                            _defaultCityApplied = true;
                          });
                          _scheduleAutoSelect(reset: true);
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: Divider(thickness: 1, color: Color(0xFFDFDFDF)),
                  ),

                  // Category chips
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          for (final cat in vm.categories)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 8,
                              ),
                              child: CategoryChoiceChip(
                                cat: cat,
                                isSelected: _selectedCategoryId == cat.id,
                                isAr: isAr,
                                cache: cache,
                                onSelected: (sel) async {
                                  await triggerSelectionHaptic();
                                  setState(() {
                                    _selectedCategoryId = sel ? cat.id : null;
                                    _categoryServices = const [];
                                    _loadingServices =
                                        sel; // show spinner immediately
                                    _servicesError = null;
                                  });
                                  if (sel) await _loadServices(vm);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Pinned city name header (only if description exists)
                  if (hasCityDesc)
                    CityTitleHeader(
                      selectedIndex: vm.selectedCityIndex,
                      title: vm.selectedCityIndex == 0
                          ? (s?.cityAllSaudia ??
                                (vm.cities.isNotEmpty
                                    ? vm.cities[0]
                                    : 'Saudi Arabia'))
                          : _localizedCityName(cityObj, isAr),
                      heroTag: 'city-name-${_localizedCityName(cityObj, isAr)}',
                    )
                  else
                    const SliverToBoxAdapter(child: SizedBox.shrink()),

                  // City description copy
                  CityDescription(description: cityDesc),

                  // Parallax hero image
                  if (hasCityDesc)
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      pinned: false,
                      floating: false,
                      expandedHeight: 220,
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final slideAnimation = Tween<Offset>(
                                  begin: const Offset(0, 0.08),
                                  end: Offset.zero,
                                ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: slideAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Hero(
                                key: ValueKey<int>(vm.selectedCityIndex),
                                tag:
                                    'city-img-${cityObj.nameEn.isNotEmpty ? cityObj.nameEn : (cityObj.nameAr.isNotEmpty ? cityObj.nameAr : selectedCityModel?.nameAr ?? 'unknown')}',
                                flightShuttleBuilder: shapedHeroFlight(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if ((cityObj.photoUrl ?? '').isNotEmpty)
                                        Semantics(
                                          label:
                                              'City image: ${_localizedCityName(cityObj, isAr)}',
                                          image: true,
                                          child: CachedUrlImage(
                                            cityObj.photoUrl!,
                                            cache: cache,
                                            height: 180,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      else
                                        Container(
                                          color: const Color(0xFFD9D9D9),
                                        ),
                                      Positioned.fill(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.0),
                                                Colors.black.withOpacity(0.12),
                                                Colors.black.withOpacity(0.22),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SliverToBoxAdapter(child: SizedBox.shrink()),

                  // Category description box
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: (_selectedCategoryId == null)
                          ? const SizedBox.shrink()
                          : Padding(
                              key: ValueKey(
                                'cat-desc-${_selectedCategoryId ?? 'none'}',
                              ),
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                              child: Builder(
                                builder: (context) {
                                  final cat = vm.categoryById(
                                    _selectedCategoryId!,
                                  );
                                  if (cat == null) {
                                    return const SizedBox.shrink();
                                  }

                                  final desc = _localizedCategorySubtitle(
                                    cat,
                                    isAr,
                                  );
                                  if (desc.isEmpty) {
                                    final title = _localizedCategoryLabel(
                                      cat,
                                      isAr,
                                    );
                                    final hasIcon =
                                        ((cat.iconUrl)?.trim().isNotEmpty ??
                                            false) ||
                                        ((cat.icon).trim().isNotEmpty);
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        4,
                                        4,
                                        20,
                                        8,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (hasIcon) ...[
                                            _buildCategoryIcon(
                                              cat,
                                              AppColors.textPrimary,
                                              cache: cache,
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE5EEF5),
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            _buildCategoryIcon(
                                              cat,
                                              AppColors.textPrimary,
                                              cache: cache,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _localizedCategoryLabel(
                                                  cat,
                                                  isAr,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Color(0xFFDFDFDF),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          desc,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.6,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ),

                  // Services list for selected category
                  if (_servicesError != null && _selectedCategoryId != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                        child: isNetworkErrorMessage(_servicesError)
                            ? NoNetworkPlaceholder(
                                useSafeArea: false,
                                onRetry: () => _loadServices(vm),
                              )
                            : _buildInlineErrorMessage(
                                message: isAr
                                    ? 'تعذر تحميل الخدمات. حاول مرة أخرى لاحقًا.'
                                    : 'Unable to load services. Please try again later.',
                              ),
                      ),
                    )
                  else
                    ServicesHorizontalList(
                      loading: _loadingServices,
                      selectedCategoryId: _selectedCategoryId,
                      services: _categoryServices,
                      isAr: isAr,
                      noServicesText:
                          s?.noServicesAvailable ?? 'No services available',
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Helpers --------------------------------------------------------------

  String _cityDescriptionForLocale(
    BuildContext context,
    String? ar,
    String? en,
  ) {
    String clean(String? s) {
      final v = (s ?? '').trim();
      if (v.toLowerCase() == 'n/a') return '';
      return v;
    }

    final lang = Localizations.localeOf(context).languageCode;
    final a = clean(ar);
    final e = clean(en);
    if (lang == 'ar') return a.isNotEmpty ? a : e;
    return e.isNotEmpty ? e : a;
  }

  City _resolveCity(City? selectedCity, List<City> backendCities) {
    if (selectedCity != null) {
      for (final city in backendCities) {
        if (city.id == selectedCity.id) return city;
      }
      return selectedCity;
    }
    if (backendCities.isNotEmpty) return backendCities.first;
    return const City(id: 0, nameAr: '', nameEn: '');
  }

  String _localizedCityName(City c, bool isAr) {
    String fallback(String primary, String alt) =>
        primary.isNotEmpty ? primary : alt;
    return isAr ? fallback(c.nameAr, c.nameEn) : fallback(c.nameEn, c.nameAr);
  }

  String _localizedCategoryLabel(dynamic cat, bool isAr) {
    String asString(Object? v) => (v ?? '').toString();
    final label = asString(cat.label);
    final labelAr = asString(cat.labelAr);
    final labelEn = asString(cat.labelEn);
    if (isAr) {
      return labelAr.isNotEmpty
          ? labelAr
          : label.isNotEmpty
          ? label
          : labelEn;
    }
    return labelEn.isNotEmpty
        ? labelEn
        : label.isNotEmpty
        ? label
        : labelAr;
  }

  String _localizedCategorySubtitle(dynamic cat, bool isAr) {
    String clean(String? s) {
      final v = (s ?? '').trim();
      if (v.toLowerCase() == 'n/a') return '';
      return v;
    }

    final subtitle = clean(cat.subtitle);
    final subtitleAr = clean(cat.subtitleAr);
    final subtitleEn = clean(cat.subtitleEn);

    if (isAr) {
      return subtitleAr.isNotEmpty
          ? subtitleAr
          : subtitle.isNotEmpty
          ? subtitle
          : subtitleEn;
    }
    return subtitleEn.isNotEmpty
        ? subtitleEn
        : subtitle.isNotEmpty
        ? subtitle
        : subtitleAr;
  }

  Widget _buildCategoryIcon(
    dynamic cat,
    Color color, {
    double size = 24,
    SecureImageCache? cache,
  }) {
    final iconUrl = (cat.iconUrl ?? '').toString().trim();
    if (iconUrl.isNotEmpty) {
      final imgCache = cache ?? context.read<SecureImageCache>();
      if (iconUrl.toLowerCase().endsWith('.svg')) {
        return CachedSvg(
          iconUrl,
          cache: imgCache,
          width: size,
          height: size,
          color: color,
          shimmerEnabled: false,
        );
      }
      return CachedUrlImage(
        iconUrl,
        cache: imgCache,
        width: size,
        height: size,
        fit: BoxFit.contain,
        color: color,
        shimmerEnabled: false,
      );
    }

    final assetIcon = (cat.icon as String? ?? '').trim();
    if (assetIcon.isNotEmpty) {
      return Image.asset(
        assetIcon,
        width: size,
        height: size,
        color: color,
        errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
      );
    }
    return SizedBox(width: size, height: size);
  }

  /// Compact inline error copy for non-network failures.
  Widget _buildInlineErrorMessage({required String message}) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Wraps [child] with a CitiesViewModel provider only if one is not already present.
  Widget _withCitiesVm({required Widget child}) {
    return Builder(
      builder: (context) {
        try {
          Provider.of<CitiesViewModel>(context, listen: false);
          return child;
        } catch (_) {
          return ChangeNotifierProvider(
            create: (_) => CitiesViewModel()..load(),
            child: child,
          );
        }
      },
    );
  }
}
