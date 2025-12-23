import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/menuPages/about_view_model.dart';
import 'ui/placeholder_image.dart';
import 'accordion/accordion_section.dart';

class AboutHomeSection extends StatelessWidget {
  const AboutHomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AboutViewModel(),
      child: Consumer<AboutViewModel>(
        builder: (context, vm, _) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👇 Title INSIDE the box
                const Text(
                  'من نحن ؟',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

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

                AccordionSection(
                  index: 1,
                  title: 'الرسالة والرؤية',
                  initiallyExpanded: true,
                  body: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Text(
                          vm.missionVision,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: Color(0xFF616161),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const PlaceholderImage(),
                    ],
                  ),
                ),

                AccordionSection(
                  index: 2,
                  title: 'أهداف المنتدى',
                  initiallyExpanded: true,
                  body: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Text(
                          vm.forumGoals,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: Color(0xFF616161),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const PlaceholderImage(),
                    ],
                  ),
                ),

                AccordionSection(
                  index: 3,
                  title: 'الفئات المستهدفة',
                  initiallyExpanded: false,
                  body: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Text(
                          vm.targetAudience,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: Color(0xFF616161),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const PlaceholderImage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
