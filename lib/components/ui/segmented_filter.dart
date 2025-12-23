import 'package:flutter/material.dart';

/// A flexible segmented control for filtering services.
///
/// Renders a row of [SegmentPill] widgets with consistent
/// styling that adapts to content size. The currently selected
/// option is highlighted and the callback [onSelected] is invoked
/// when a pill is tapped.
class SegmentedFilter extends StatelessWidget {
  /// Labels for each segment.
  final List<String> options;

  /// Currently selected label.
  final String selected;

  /// Called when the user selects a different option.
  final ValueChanged<String> onSelected;

  /// Spacing between segments.
  final double spacing;

  /// Whether segments should expand to fill available space.
  final bool expandSegments;

  const SegmentedFilter({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.spacing = 4.0,
    this.expandSegments = false,
  });

  @override
  Widget build(BuildContext context) {
    if (expandSegments) {
      // Equal width segments that fill the container
      return Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            Expanded(
              child: SegmentPill(
                label: options[i],
                selected: options[i] == selected,
                onTap: () => onSelected(options[i]),
              ),
            ),
            if (i < options.length - 1) SizedBox(width: spacing),
          ],
        ],
      );
    } else {
      // Content-sized segments with flexible spacing
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final option in options)
            Flexible(
              child: SegmentPill(
                label: option,
                selected: option == selected,
                onTap: () => onSelected(option),
              ),
            ),
        ],
      );
    }
  }
}

/// Rounded pill button used within [SegmentedFilter].
class SegmentPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SegmentPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  // Constants for better maintainability
  static const double _minHeight = 48.0;
  static const double _borderRadius = 10.0;
  static const double _fontSize = 16.0;
  static const double _horizontalPadding = 20.0;
  static const double _verticalPadding = 12.0;
  static const Color _selectedColor = Color(0xFF0A3A67);
  static const Color _unselectedColor = Colors.white;
  static const Color _borderColor = Color(0xFFDFDFDF);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: _minHeight,
            // minWidth: 80, // Reduced minimum width
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: _verticalPadding,
          ),
          decoration: BoxDecoration(
            color: selected ? _selectedColor : _unselectedColor,
            borderRadius: BorderRadius.circular(_borderRadius),
            border: selected
                ? null
                : Border.all(color: _borderColor, width: 1.5),
            boxShadow: selected
                ? [
                    BoxShadow(
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      color: _selectedColor.withOpacity(0.25),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : _selectedColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to provide SegmentedFilter variants
extension SegmentedFilterVariants on SegmentedFilter {
  /// Creates a compact variant with smaller pills
  SegmentedFilter compact() {
    return SegmentedFilter(
      key: key,
      options: options,
      selected: selected,
      onSelected: onSelected,
      spacing: 4.0,
      expandSegments: expandSegments,
    );
  }

  /// Creates an expanded variant where segments fill the container
  SegmentedFilter expanded({double spacing = 12.0}) {
    return SegmentedFilter(
      key: key,
      options: options,
      selected: selected,
      onSelected: onSelected,
      spacing: spacing,
      expandSegments: true,
    );
  }
}
