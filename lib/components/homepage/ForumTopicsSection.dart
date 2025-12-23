import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ForumTopicsSection extends StatelessWidget {
  final String title;
  final List<String> topics;

  const ForumTopicsSection({
    super.key,
    required this.topics,
    this.title = ' محاور المنتدى',
    required String imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background, // White background for the container
          borderRadius: BorderRadius.circular(16), // Rounded container
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.16),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // full width children
          children: [
            // Title
            Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.black, // Dark blue color for the title
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            // Topic pills (each pill with different text color)
            ...topics.map((t) => _TopicPill(text: t)).toList(),
          ],
        ),
      ),
    );
  }
}

class _TopicPill extends StatelessWidget {
  final String text;
  const _TopicPill({required this.text});

  @override
  Widget build(BuildContext context) {
    // Set the text color based on the content of the topic
    Color textColor;

    if (text.contains('التحديات')) {
      textColor = AppColors.darkBlue; // Dark blue text for this topic
    } else if (text.contains('الذكاء')) {
      textColor = AppColors.teal; // Teal text for this topic
    } else {
      textColor = AppColors.green; // Green text for this topic
    }

    return Container(
      width: double.infinity, // full width
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background, // White background for the pill (no color)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1), // Rounded edges
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: textColor, // Text color will change based on the topic
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
