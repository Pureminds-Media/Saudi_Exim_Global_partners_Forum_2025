import 'package:flutter/material.dart';

import 'agenda_card.dart';

/// A reusable agenda section widget that displays speakers, panels,
/// and workshops in a two‑column grid.
class AgendaSection extends StatefulWidget {
  const AgendaSection({super.key});

  @override
  State<AgendaSection> createState() => _AgendaSectionState();
}

class _AgendaSectionState extends State<AgendaSection> {
  /// Currently selected tab index.
  /// 0: speakers, 1: panels, 2: workshops.
  int _tab = 0;

  // Static data to populate the grid. This mirrors the temporary data
  // used on the home page.
  static const _speakers = [
    {'t': 'احمد عبدالرحمن', 's': 'المنسي'},
    {'t': 'سارة الحربي', 's': 'المحتوى'},
    {'t': 'يوسف الشهري', 's': 'الاستراتيجية'},
    {'t': 'مها الدوسري', 's': 'الشراكات'},
  ];

  static const _panels = [
    {'t': 'الجلسة 1', 's': 'التحول والتصدير'},
    {'t': 'الجلسة 2', 's': 'سلاسل الإمداد'},
  ];

  static const _workshops = [
    {'t': 'ورشة 1', 's': 'تمويل المصدرين'},
    {'t': 'ورشة 2', 's': 'إدارة المخاطر'},
  ];

  List<Map<String, String>> get _items => switch (_tab) {
    0 => _speakers,
    1 => _panels,
    _ => _workshops,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('أجندة المنتدى', style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _TabChip(
                label: 'المتحدثين',
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              _TabChip(
                label: 'الجلسات الحوارية',
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemBuilder: (_, i) =>
                AgendaCard(title: _items[i]['t']!, subtitle: _items[i]['s']!),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.onSurface.withAlpha(30)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withAlpha(89)),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
