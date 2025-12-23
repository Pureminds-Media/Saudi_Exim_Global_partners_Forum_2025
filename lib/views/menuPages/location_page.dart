import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';

import '../../components/event_location_card.dart';
import '../../components/section_header.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/location_view_model.dart';

/// Page displaying event location and date details with registration CTA.
class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    bool isRtl = currentLocale.languageCode == 'ar';
    final s = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (_) => LocationViewModel(),
      child: Scaffold(
        // subtle light bg like the shot
        body: Column(
          children: [
            const SizedBox(height: 4),
            // Title header (no back button)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SectionHeader(text: s.locationTitle),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Consumer<LocationViewModel>(
                    builder: (context, vm, _) => EventCard(
                      latitude: vm.latitude,
                      longitude: vm.longitude,
                      date: isRtl ? vm.date_ar : vm.date_en,
                      location: isRtl ? vm.location_ar : vm.location_en,
                      address: isRtl ? vm.address_ar : vm.address_en,
                      // Optional: provide a local asset map to match the image exactly
                      mapAssetPath: 'assets/maps.png',
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
