import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Arrow + label pair for back navigation.
class BackHeader extends StatelessWidget {
  final VoidCallback? onTap;
  const BackHeader({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 28),
          color: Colors.black,
          onPressed: onTap ?? () => context.pop(),
        ),
        const Text(
          'العودة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6E6E6E),
          ),
        ),
      ],
    );
  }
}
