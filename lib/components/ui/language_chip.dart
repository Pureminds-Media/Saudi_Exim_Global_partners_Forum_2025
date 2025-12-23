import 'package:flutter/material.dart';

/// A decorative language switcher chip for the AppBar.
/// UI only — no functionality wired yet.
class LanguageChip extends StatelessWidget {
  const LanguageChip({super.key, this.label = 'EN', this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed, // wired by parent
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE6E6E6), width: 1.5),
            // boxShadow: const [
            //   BoxShadow(
            //     color: Color.fromRGBO(0, 0, 0, 0.10),
            //     blurRadius: 12,
            //     offset: Offset(0, 2),
            //   ),
            // ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_outlined,
                size: 20,
                color: const Color(0xFF797979),
              ),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF797979),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
