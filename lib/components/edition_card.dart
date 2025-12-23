import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/models/edition.dart';

/// Card displaying a single forum edition with placeholder imagery and
/// interactive animations.
class EditionCard extends StatefulWidget {
  const EditionCard({super.key, required this.edition, this.enableTap = true});

  /// Edition data to render inside the card.
  final Edition edition;

  /// Whether tapping the card triggers navigation and feedback.
  final bool enableTap;

  @override
  State<EditionCard> createState() => _EditionCardState();
}

class _EditionCardState extends State<EditionCard> {
  bool _pressed = false;

  // void _handleTap() {
  //   context.pushNamed('edition', extra: widget.edition);
  // }

  void _onTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
  }

  void _onTapEnd([TapUpDetails? details]) {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: null,
      onTapDown: widget.enableTap ? _onTapDown : null,
      onTapUp: widget.enableTap ? _onTapEnd : null,
      onTapCancel: widget.enableTap ? _onTapEnd : null,
      child: Hero(
        tag: widget.edition.title,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.all(_pressed ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                if (_pressed)
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
              ],
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _pressed ? 0.85 : 1,
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final edition = widget.edition;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          edition.title,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF121212),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          edition.date,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 16, color: Color(0xFF121100)),
        ),
        const SizedBox(height: 12),
        for (final line in edition.descriptionLines)
          Text(
            line,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF505050),
              height: 1.3,
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 140,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(edition.mainPhoto, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          physics: const NeverScrollableScrollPhysics(),
          children: edition.minorPhotos.map((photoPath) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(photoPath, fit: BoxFit.cover),
            );
          }).toList(),
        ),
      ],
    );
  }
}
