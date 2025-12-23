import 'package:flutter/material.dart';

/// Icon + label pair (date, location).
class InfoItem extends StatelessWidget {
  final String text;
  final IconData icon;
  const InfoItem({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF616161)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
