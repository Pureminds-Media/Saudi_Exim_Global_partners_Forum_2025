import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/components/homepage/home_header_section.dart';
import '../theme/responsive_tokens.dart';
import '../viewmodels/home_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.watch<HomeViewModel>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = responsivePagePadding(constraints.maxWidth);

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // Header texts
                HomeHeaderSection(
                  hideTitle: false,
                  introTitle:
                      "19 – 20 November 2025 | Hilton Riyadh Hotel & Residences | Riyadh, Saudi Arabia",
                  introBody:
                      "The Saudi EXIM Global Partners Forum will be held in Riyadh on 19 – 20 November 2025. It is an international, high-level convening hosted by Saudi EXIM to advance strategic dialogue on the future of global trade and export finance. It will bring together senior decision-makers from governments, export credit agencies, EXIM banks, development finance institutions, multilateral organisations, commercial banks, and the private sector to explore the future of trade, finance, and economic transformation. Anchored in the Kingdom's Vision 2030, the Forum is designed to advance strategic dialogue, strengthen cross-border partnerships, and promote innovation in export finance. Across two days, participants will gain insights into the changing global trade landscape, the opportunities in the Saudi economy, and the transformative potential of innovation, AI, and digitalisation, while fostering collaboration between advanced economies and the Global South. The Saudi EXIM Global Partners Forum promises an excellent opportunity for networking, knowledge-sharing, and building actionable partnerships to promote diversified, resilient, and sustainable trade ecosystems.",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
