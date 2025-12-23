import 'package:flutter/material.dart';

/// Standard divider between sections.
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 48, thickness: 1, color: Color(0xFFDFDFDF));
  }
}
