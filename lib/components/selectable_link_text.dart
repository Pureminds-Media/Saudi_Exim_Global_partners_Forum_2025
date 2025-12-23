import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Underlined URL that can be tapped & copied.
class SelectableLinkText extends StatelessWidget {
  final String url;
  const SelectableLinkText({super.key, required this.url});

  Future<void> _launch() async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _launch,
      child: SelectableText(
        url,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1A0DAB),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
