import 'package:flutter/material.dart';

import 'accordion_body.dart';
import 'accordion_header.dart';

/// Expandable/collapsible section containing header and body.
class AccordionSection extends StatefulWidget {
  final int index;
  final String title;
  final Widget body;
  final bool initiallyExpanded;

  const AccordionSection({
    super.key,
    required this.index,
    required this.title,
    required this.body,
    this.initiallyExpanded = false,
  });

  @override
  State<AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<AccordionSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggle() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AccordionHeader(
          index: widget.index,
          title: widget.title,
          isExpanded: _isExpanded,
          onToggle: _toggle,
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: AccordionBody(child: widget.body),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const Divider(thickness: 0.5, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}
