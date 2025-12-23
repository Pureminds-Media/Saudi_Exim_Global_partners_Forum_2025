import 'package:flutter/material.dart';

/// Row with expand/collapse icon and numbered title.
class AccordionHeader extends StatelessWidget {
  final int index;
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;

  const AccordionHeader({
    super.key,
    required this.index,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // This makes sure text is on the left, icon is on the right
        children: [
          Text(
            '$index- $title',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 20,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
