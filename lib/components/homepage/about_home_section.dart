// lib/components/homepage/about_home_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/about_view_model.dart';

class AboutHomeSection extends StatelessWidget {
  const AboutHomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AboutViewModel(),
      child: Consumer<AboutViewModel>(
        builder: (context, vm, _) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _AboutContent(
                aboutText: vm.aboutText,
                missionVision: vm.missionVision,
                forumGoals: vm.forumGoals,
                targetAudience: vm.targetAudience,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AboutContent extends StatefulWidget {
  final String aboutText;
  final String missionVision;
  final String forumGoals;
  final String targetAudience;

  const _AboutContent({
    required this.aboutText,
    required this.missionVision,
    required this.forumGoals,
    required this.targetAudience,
  });

  @override
  State<_AboutContent> createState() => _AboutContentState();
}

class _AboutContentState extends State<_AboutContent> {
  int _openIndex = -1; // all closed initially

  void _toggle(int i) {
    setState(() => _openIndex = _openIndex == i ? -1 : i);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'من نحن ؟',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.aboutText,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.textBody,
            fontSize: 14,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 14),
        const Divider(color: AppColors.border, height: 24, thickness: 1),

        // Flat accordion rows
        _PlainTile(
          title: '1- الرؤية',
          expanded: _openIndex == 0,
          onTap: () => _toggle(0),
          child: _BodyRow(text: widget.missionVision),
        ),
        const Divider(color: AppColors.border, height: 1, thickness: 1),

        _PlainTile(
          title: '2- الرسالة',
          expanded: _openIndex == 1,
          onTap: () => _toggle(1),
          child: _BodyRow(text: widget.forumGoals),
        ),
        const Divider(color: AppColors.border, height: 1, thickness: 1),

        _PlainTile(
          title: '3- أهداف المنتدى',
          expanded: _openIndex == 2,
          onTap: () => _toggle(2),
          child: _BodyRow(text: widget.targetAudience),
        ),
      ],
    );
  }
}

class _PlainTile extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  const _PlainTile({
    required this.title,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  // Title (right side in RTL)
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Arrow at the end (left in RTL) that rotates
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0, // 0° → 180°
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: const Icon(
                      Icons.expand_more,
                      size: 25,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Animated body
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                    child: child,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _BodyRow extends StatelessWidget {
  final String text;
  const _BodyRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: AppColors.textBody,
          fontSize: 14,
          height: 1.7,
        ),
      ),
    );
  }
}
