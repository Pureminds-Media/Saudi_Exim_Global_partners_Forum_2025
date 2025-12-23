// lib/views/menuPages/image_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/components/ui/title_back_top_bar.dart';
import 'package:saudiexim_mobile_app/components/stat_card.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/image_view_model.dart';

import '../../components/homepage/home_header_section.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImageViewModel(),
      child: Scaffold(
        body: Column(
          children: [
            const BackTitleBar(title: 'الشعار اللفظي'),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Consumer<ImageViewModel>(
                    builder: (context, vm, _) => Column(
                      children: [
                        const HomeHeaderSection(
                          hideTitle: true,
                          introTitle: 'نبذة عن المنتدى',
                          introBody:
                              'انطلاقاً من الرؤية الطموحة التي صنعت إحدى أعظم قصص النجاح في القرن الحادي والعشرين، يأتي تنظيم المنتدى العالمي للشركاء بنك التصدير والاستيراد السعودي في مدينة الرياض تحت رعاية معالي وزير الصناعة والثروة المعدنية الأستاذ بندر بن إبراهيم الخريف، حيث يجتمع القادة وصناع القرار والمستثمرين من مختلف أنحاء العالم.',
                        ),
                        const SizedBox(height: 24),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            const gap = 16.0;
                            const cols = 2;
                            final tileWidth =
                                (constraints.maxWidth - gap * (cols - 1)) /
                                cols;

                            return Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: vm.stats.map((stat) {
                                return SizedBox(
                                  width:
                                      tileWidth, // only width fixed, height wraps content
                                  child: StatCard(
                                    value: stat.value,
                                    label: stat.label,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 36),
                      ],
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
