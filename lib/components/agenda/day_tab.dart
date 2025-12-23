import 'package:flutter/material.dart';

/// Card-style day toggle used on the Agenda page.
/// Selected: teal background, white text.
/// Unselected: white background, teal text, border #DFDFDF.
class DayTab extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

  const DayTab({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = const Color(0xFFDFDFDF);
    final Color bg = selected ? activeColor : Colors.white;
    final Color fg = selected ? Colors.white : activeColor;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w800, color: fg),
        ),
      ),
    );
  }
}
