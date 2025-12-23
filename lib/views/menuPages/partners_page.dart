// lib/views/menuPages/partners_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:saudiexim_mobile_app/components/ui/title_back_top_bar.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/partners_view_model.dart';

class PartnersPage extends StatefulWidget {
  const PartnersPage({super.key});

  @override
  State<PartnersPage> createState() => _PartnersPageState();
}

class _PartnersPageState extends State<PartnersPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PartnersViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<PartnersViewModel>(
            builder: (context, vm, _) {
              final list = vm.currentList;

              return Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    const BackTitleBar(title: 'شراكات ملهمة'),
                    const SizedBox(height: 8),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE8E8E8),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEAEAEA),
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final animation = CurvedAnimation(
                            parent: _controller,
                            curve: Interval(
                              (index * 0.08).clamp(0, 1).toDouble(),
                              1,
                              curve: Curves.easeOutCubic,
                            ),
                          );

                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - animation.value)),
                                child: Opacity(
                                  opacity: animation.value,
                                  child: child,
                                ),
                              );
                            },
                            // in itemBuilder -> child:
                            child: _PartnerListItem(
                              title: list[index].name,
                              description: list[index].description,
                              logo: list[index].companyLogo.isNotEmpty
                                  ? Image.asset(
                                      list[index].companyLogo,
                                      fit: BoxFit.cover,
                                    )
                                  : const SizedBox.shrink(), // or a placeholder
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PartnerListItem extends StatelessWidget {
  const _PartnerListItem({
    required this.title,
    required this.description,
    required this.logo,
  });

  final String title;
  final String description;
  final Widget logo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title "اسم الشريك"
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D1D1D),
          ),
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF6C6C6C),
          ),
        ),
        const SizedBox(height: 10),

        // Rounded logo card (full width with grey border)
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ), // grey border
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: logo,
            ),
          ),
        ),
      ],
    );
  }
}
