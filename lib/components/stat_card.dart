import 'package:flutter/material.dart';

/// Bordered rectangle displaying a numerical statistic and its label.
class StatCard extends StatelessWidget {
  final String value;
  final String label;

  const StatCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ), // ✅ added
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ lets height shrink-wrap content
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 22, color: Color(0xFF616161)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
