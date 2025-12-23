import 'package:flutter/material.dart';
import '../buttons/secondary_button.dart';

class ExpandableIntroCard extends StatefulWidget {
  final String title;
  final String body;

  /// Fires with the current state: true when expanded, false when collapsed.
  final ValueChanged<bool>? onToggle;

  /// How many lines to show when collapsed.
  final int collapsedLines;

  const ExpandableIntroCard({
    super.key,
    required this.title,
    required this.body,
    this.onToggle,
    this.collapsedLines = 5,
  });

  @override
  State<ExpandableIntroCard> createState() => _ExpandableIntroCardState();
}

class _ExpandableIntroCardState extends State<ExpandableIntroCard> {
  bool _expanded = false;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onToggle?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Align(
              alignment:
                  Alignment.centerRight, // RTL start, use .centerLeft for LTR
              child: Text(
                widget.title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D1D1D),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Divider
            Container(height: 1, color: const Color(0xFFE6E6E6)),
            const SizedBox(height: 12),

            // Body (tap to collapse when expanded)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: InkWell(
                onTap: _expanded ? _toggle : null,
                child: Text(
                  widget.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.7,
                  ),
                  maxLines: _expanded ? null : widget.collapsedLines,
                  overflow: _expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // "المزيد" / "إخفاء"
            GestureDetector(
              onTap: _toggle,
              child: Text(
                _expanded ? '' : 'المزيد',
                style: const TextStyle(
                  color: Color(0xFF0B4B73),
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // CTA with your component
            SecondaryButton(label: 'سجل الان', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
