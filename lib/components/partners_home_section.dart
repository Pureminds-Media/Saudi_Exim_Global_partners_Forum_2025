import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/buttons/segment_button.dart';
import '../components/company_card.dart';
import '../viewmodels/menuPages/partners_view_model.dart';

class PartnersHomeSection extends StatefulWidget {
  const PartnersHomeSection({super.key});

  @override
  State<PartnersHomeSection> createState() => _PartnersHomeSectionState();
}

class _PartnersHomeSectionState extends State<PartnersHomeSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _restartAnimation() => _controller.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PartnersViewModel(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Consumer<PartnersViewModel>(
          builder: (context, vm, _) {
            final list = vm.currentList;

            // ✅ Fixed: 4 columns × 2 rows = 8 items max
            const int cols = 4;
            const int rows = 2;
            final int visibleCount = math.min(list.length, cols * rows); // 8

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'المشاركين',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Segmented buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SegmentButton(
                        label: 'مشاركين',
                        isSelected: vm.showParticipants,
                        onTap: () {
                          if (!vm.showParticipants) {
                            vm.toggleShowParticipants();
                            _restartAnimation();
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      SegmentButton(
                        label: 'رعاة',
                        isSelected: !vm.showParticipants,
                        onTap: () {
                          if (vm.showParticipants) {
                            vm.toggleShowParticipants();
                            _restartAnimation();
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Grid: always 4 columns, only 2 rows (first 8 items)
                GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols, // 4 columns
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: visibleCount, // up to 8
                  itemBuilder: (context, index) {
                    final anim = CurvedAnimation(
                      parent: _controller,
                      curve: Interval(index * 0.05, 1, curve: Curves.easeOut),
                    );
                    return AnimatedBuilder(
                      animation: anim,
                      child: CompanyCard(name: list[index].name),
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, 40 * (1 - anim.value)),
                        child: Opacity(opacity: anim.value, child: child),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
