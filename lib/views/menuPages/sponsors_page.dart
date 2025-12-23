import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/components/cached_url_image.dart';
import 'package:saudiexim_mobile_app/components/ui/title_back_top_bar.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/sponsors_view_model.dart';

class SponsorsPage extends StatefulWidget {
  const SponsorsPage({super.key});

  @override
  State<SponsorsPage> createState() => _SponsorsPageState();
}

class _SponsorsPageState extends State<SponsorsPage> {
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final cache = Provider.of<SecureImageCache>(context, listen: false);
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    return ChangeNotifierProvider(
      create: (_) => SponsorsViewModel()..load(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<SponsorsViewModel>(
            builder: (context, vm, _) {
              final selected = vm.selected;
              final selectedIndex = {
                SponsorTier.strategic: 0,
                SponsorTier.diamond: 1,
                SponsorTier.gold: 2,
              }[selected]!;

              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const SizedBox(height: 4),
                  BackTitleBar(title: s.menuSponsorship),

                  // Top pillars (three types)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        _PillarButton(
                          label: s.sponsorTypeStrategic,
                          selected: selectedIndex == 0,
                          onTap: () => vm.selectTier(SponsorTier.strategic),
                        ),
                        _PillarButton(
                          label: s.sponsorTypeDiamond,
                          selected: selectedIndex == 1,
                          onTap: () => vm.selectTier(SponsorTier.diamond),
                        ),
                        _PillarButton(
                          label: s.sponsorTypeGold,
                          selected: selectedIndex == 2,
                          onTap: () => vm.selectTier(SponsorTier.gold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (vm.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (vm.error != null)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            isRtl
                                ? 'تعذر تحميل الرعاة'
                                : 'Failed to load sponsors',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFFB00020),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            vm.error!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: vm.load,
                            child: Text(isRtl ? 'إعادة المحاولة' : 'Retry'),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        // Show the selected pillar title above the grid
                        selected == SponsorTier.strategic
                            ? s.sponsorTypeStrategic
                            : selected == SponsorTier.diamond
                            ? s.sponsorTypeDiamond
                            : s.sponsorTypeGold,
                        style: const TextStyle(
                          color: Color(0xFF174B86),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.95,
                          ),
                      itemCount: vm.currentList.length,
                      itemBuilder: (context, index) {
                        final sp = vm.currentList[index];
                        final imgUrl = vm.imageUrlFor(sp);
                        final title = isRtl ? sp.nameAr : sp.nameEn;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: CachedUrlImage(
                                  imgUrl,
                                  cache: cache,
                                  fit: BoxFit.contain,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF174B86),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PillarButton extends StatelessWidget {
  const _PillarButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            selected ? const Color(0xFF03B2AE) : Colors.white,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                width: 1,
                color: selected
                    ? const Color(0xFF03B2AE)
                    : const Color(0xFFDEDEDE),
              ),
            ),
          ),
          shadowColor: WidgetStateProperty.all(const Color(0x19161616)),
          elevation: WidgetStateProperty.all(4),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF03B2AE),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
