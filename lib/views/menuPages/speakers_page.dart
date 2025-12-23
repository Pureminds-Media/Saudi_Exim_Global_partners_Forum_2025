import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';

import '../../viewmodels/menuPages/speakers_view_model.dart';
import '../../components/ui/title_back_top_bar.dart';
import '../../components/speaker_box.dart';
import '../../components/ui/no_network_placeholder.dart';
import '../../utils/network_error_classifier.dart';

class SpeakersPage extends StatefulWidget {
  static const String routeName = '/speakers';

  const SpeakersPage({super.key});

  @override
  State<SpeakersPage> createState() => _SpeakersPageState();
}

class _SpeakersPageState extends State<SpeakersPage> {
  int selectedButtonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    final s = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (_) => SpeakersViewModel()..fetchSpeakers(),
      // ⬇️ new context that can see the provider
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 4)),
                  SliverToBoxAdapter(
                    child: BackTitleBar(title: s.menuSpeakers),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _buildButton(
                            context,
                            isRtl ? "اليوم الأول" : "Day One",
                            0,
                          ),
                          _buildButton(
                            context,
                            isRtl ? "اليوم الثاني" : "Day Two",
                            1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: DayTitle(isRtl: isRtl)),
                  const _SpeakersSliver(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, int index) {
    final isSelected = selectedButtonIndex == index;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              isSelected ? const Color(0xFF03B2AE) : Colors.white,
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  width: 2,
                  color: isSelected
                      ? const Color(0xFF03B2AE)
                      : const Color(0xFFDEDEDE),
                ),
              ),
            ),
            shadowColor: WidgetStateProperty.all(const Color(0x19161616)),
            elevation: WidgetStateProperty.all(4),
          ),
          onPressed: () {
            setState(() => selectedButtonIndex = index);
            // ✅ this context is under the provider now
            context.read<SpeakersViewModel>().setSelectedDay(index);
          },
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF03B2AE),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class DayTitle extends StatelessWidget {
  const DayTitle({super.key, required this.isRtl});
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final selectedDay = context.watch<SpeakersViewModel>().selectedDay;

    // Headline per day
    final headlineAr = selectedDay == 0
        ? 'التحولات العالمية وفرص الاقتصاد السعودي'
        : 'الابتكار والتمويل في الجنوب العالمي';
    final headlineEn = selectedDay == 0
        ? 'Global Transitions and Opportunities in the Saudi Economy'
        : 'Innovation and Finance in the Global South';

    // Date line per day
    final dateAr = selectedDay == 0
        ? 'الأربعاء، 19 نوفمبر 2025'
        : 'الخميس، 20 نوفمبر 2025';
    final dateEn = selectedDay == 0
        ? 'Wednesday, 19 November 2025'
        : 'Thursday, 20 November 2025';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRtl ? headlineAr : headlineEn,
            style: const TextStyle(
              color: Color(0xFF174B86),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRtl ? dateAr : dateEn,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Color(0xFF03B2AE),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeakersSliver extends StatelessWidget {
  const _SpeakersSliver();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SpeakersViewModel>();
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    const itemWidth = 200.0;
    const itemHeight = 250.0;

    if (vm.isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final groups = vm.currentGroups;
    if (vm.error != null && groups.isEmpty) {
      final message = vm.error!;
      if (isNetworkErrorMessage(message)) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: NoNetworkPlaceholder(
            onRetry: () => context.read<SpeakersViewModel>().fetchSpeakers(),
          ),
        );
      }
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            isRtl ? 'حدث خطأ أثناء تحميل المتحدثين' : 'Failed to load speakers',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    if (groups.isEmpty) {
      // If the API succeeded but nothing matched the selected day
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            isRtl ? 'لا يوجد متحدثون لهذا اليوم' : 'No speakers for this day',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, i) {
          final g = groups[i];

          return Padding(
            padding: EdgeInsets.only(bottom: i == groups.length - 1 ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    isRtl ? g.titleAr : g.title,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Color(0xFF02548C),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // One horizontal row per session
                SizedBox(
                  height: itemHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: g.speakers.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, j) {
                      final sp = g.speakers[j];
                      return SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: SpeakerBox(
                          speaker: sp,
                          isActive: false,
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }, childCount: groups.length),
      ),
    );
  }
}
