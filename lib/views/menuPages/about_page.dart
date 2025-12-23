// lib/views/menuPages/about_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/components/ui/title_back_top_bar.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/about_view_model.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AboutViewModel(),
      child: Scaffold(
        body: Column(
          children: [
            const BackTitleBar(title: 'من نحن ؟'),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer<AboutViewModel>(
                    builder: (context, vm, _) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            vm.aboutText,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: Color(0xFF616161),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(height: 2, color: Color(0xFFE0E0E0)),
                          const SizedBox(height: 20),
                          _SectionBlock(
                            index: 1,
                            title: 'الرؤية',
                            body: vm.missionVision,
                            imageAsset: vm.visionImage, // set your asset path
                          ),
                          const _SectionDivider(),

                          // Section 2 — الرسالة
                          _SectionBlock(
                            index: 2,
                            title: 'الرسالة',
                            body: vm.message,
                            imageAsset: vm.messageImage,
                          ),
                          const _SectionDivider(),

                          // Section 3 — أهداف المنتدى
                          _SectionBlock(
                            index: 3,
                            title: 'أهداف المنتدى',
                            body: vm.forumGoals,
                            imageAsset: vm.goalsImage,
                          ),
                        ],
                      ),
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

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
    );
  }
}

// ⬇️ Update _SectionBlock signature and field
class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.index,
    required this.title,
    required this.body,
    required this.imageAsset, // ← added
  });

  final int index;
  final String title;
  final String body;
  final String imageAsset; // ← added

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numbered heading like: "1- الرؤية"
        Text(
          '$index- $title',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D1D1D),
          ),
        ),
        const SizedBox(height: 10),

        // Rounded image card with soft shadow
        Container(
          width: double.infinity, // ✅ added to take full width
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(imageAsset, fit: BoxFit.fill),
          ),
        ),

        const SizedBox(height: 10),

        // Body paragraph
        Text(
          body,
          style: const TextStyle(
            fontSize: 13,
            height: 1.7,
            color: Color(0xFF5F5F5F),
          ),
        ),
      ],
    );
  }
}
