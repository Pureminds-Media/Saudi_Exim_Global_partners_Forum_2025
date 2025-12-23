import 'package:flutter/material.dart';

/// Two-option segmented control used to switch between speakers and sessions.
class SegmentedTabs extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final int selected;
  final ValueChanged<int> onSelect;

  const SegmentedTabs({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surface;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
              child: _ChipButton(
                label: leftLabel,
                selected: selected == 0,
                onTap: () => onSelect(0),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
              child: _ChipButton(
                label: rightLabel,
                selected: selected == 1,
                onTap: () => onSelect(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.primary : c.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: c.primary.withOpacity(.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          border: Border.all(color: c.outline.withOpacity(.15)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            color: selected ? c.onPrimary : c.onSurface,
          ),
        ),
      ),
    );
  }
}
