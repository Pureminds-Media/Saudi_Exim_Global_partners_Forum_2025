import 'package:flutter/material.dart';

/// Inner content shown when section is expanded.
class AccordionBody extends StatelessWidget {
  final Widget child;
  const AccordionBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
