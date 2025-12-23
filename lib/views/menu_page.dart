import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';


class MenuItem {
  final String text;
  final IconData icon;
  final String? badge;
  final bool? isImportant;
  const MenuItem(this.text, this.icon, {this.badge, this.isImportant});
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final List<MenuItem> items = [
      MenuItem(s.menuOverview, Icons.help_outline),
      MenuItem(s.menuSupportServices, Icons.help_outline),
      MenuItem(s.menuAgenda, Icons.event_note),
      MenuItem(s.menuSpeakers, Icons.record_voice_over),
      MenuItem(s.menuSponsorship, Icons.location_on),
      MenuItem(s.menuLocationDate, Icons.location_on),
      // Removed the regulatory info page per App Review feedback
    ];
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              s.menuHeader,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF05020D),
              ),
            ),
          ),
          // ✅ Divider under title
          const Divider(
            height: 2,
            color: Color(0xFFD9D9D9),
            indent: 16, // Add space before the divider (left side)
            endIndent: 16, // Add space after the divider (right side)
          ),

          Expanded(
            child: ListView.separated(
              itemCount: items.length + 1,
              separatorBuilder: (_, __) =>
                  const Divider(color: Color(0xFFD9D9D9), thickness: 2.0),
              itemBuilder: (context, index) {
                if (index < items.length) {
                  final item = items[index];
                  return ListTile(
                    title: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              item.text,
                              style: const TextStyle(
                                color: Color(0xFF1C1F1F),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (item.isImportant == true)
                              Text(
                                " *",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.teal,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: item.badge != null
                        ? TextButton(onPressed: () {}, child: Text(item.badge!))
                        : null,
                    onTap: () {
                      switch (index) {
                        case 0:
                          context.go('/home');
                          break;
                        case 1:
                          context.go('/services');
                          break;
                        case 2:
                          context.go('/agenda');
                          break;
                        case 3:
                          context.go('/speakers');
                          break;
                        case 4:
                          context.go('/sponsors');
                          break;
                        case 5:
                          context.go('/location');
                          break;
                        // case 6 removed: regulatory info page
                      }
                    },
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        final uri = Uri.parse("https://segpr.saudiexim.gov.sa/#/register");
                        // Review mode: keep auth/registration strictly in-app
                        // via SFSafariViewController (no external browser fallback).
                        final ok = await launchUrl(
                          uri,
                          mode: LaunchMode.inAppBrowserView,
                        );
                        if (!ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.cameraPermissionLaunchFailed)),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDFDFDF)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.menuRegisterNow,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
