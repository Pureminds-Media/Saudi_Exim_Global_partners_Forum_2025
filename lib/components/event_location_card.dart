import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.latitude,
    required this.longitude, // title text shown under the map
    required this.date,
    required this.location,
    required this.address,
    this.onRegister,
    this.mapAssetPath, // optional: grayscale Riyadh map image
  });

  final double latitude;
  final double longitude;
  final String date;
  final String location;
  final String address;
  final VoidCallback? onRegister;
  final String? mapAssetPath;

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    bool isRtl = currentLocale.languageCode == 'ar';

    // Colors tuned to match the visual:
    final Color divider = const Color(0xFFEDEEF0);

    return Card(
      elevation: 24,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: divider, width: 1.5), // ← added border
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location row
                Text(
                  isRtl ? 'موقع الحدث' : "Location",
                  style: TextStyle(
                    color: const Color(0xFF03B2AE),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  location,
                  style: TextStyle(
                    color: const Color(0xFF174B86),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),

                // Date row
                Text(
                  isRtl ? 'تاريخ الحدث' : "Date",
                  style: TextStyle(
                    color: const Color(0xFF03B2AE),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: TextStyle(
                    color: const Color(0xFF174B86),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),

                // Address row
                Text(
                  isRtl ? 'العنوان' : "Address",
                  style: TextStyle(
                    color: const Color(0xFF03B2AE),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  address,
                  style: TextStyle(
                    color: const Color(0xFF174B86),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Map header with pin overlay
          // Container(
          //   height: 200, // You can adjust the height as needed
          //   child: GoogleMap(
          //     initialCameraPosition: CameraPosition(
          //       target: LatLng(
          //         24.7136,
          //         46.6753,
          //       ), // Coordinates for Riyadh, Saudi Arabia
          //       zoom: 14,
          //     ),
          //     markers: {
          //       Marker(
          //         markerId: MarkerId('event_location'),
          //         position: LatLng(
          //           24.7136,
          //           46.6753,
          //         ), // Event location coordinates
          //         infoWindow: InfoWindow(title: 'Event Location'),
          //       ),
          //     },
          //   ),
          // ),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Stack(
              children: [
                // Background image
                Image.asset(
                  'assets/venue.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                // Text overlay
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: const Color(0xFFDEDEDE),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                shadowColor: WidgetStateProperty.all(
                                  Color(0x19000000),
                                ),
                                elevation: WidgetStateProperty.all(4),
                              ),
                              onPressed: () {
                                launch(
                                  "https://www.google.com/maps?q=Hilton+Riyadh,+Riyadh,+Saudi+Arabia+6623+Eastern+Ring+Road,+Granada,+Riyadh+13241",
                                ); // Google Maps link
                              },
                              child: Text(
                                isRtl ? 'خرائط جوجل' : "Google Maps",
                                style: TextStyle(
                                  color: const Color(0xFF03B2AE),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
