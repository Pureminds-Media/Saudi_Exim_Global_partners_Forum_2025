import 'dart:async';
import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime target;
  final EdgeInsetsGeometry padding;
  final double cardWidth;

  const CountdownTimer({
    super.key,
    required this.target,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.cardWidth = 68,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _t;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final left = widget.target.difference(DateTime.now());
    setState(() => _left = left.isNegative ? Duration.zero : left);
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final days = _left.inDays;
    final hours = _left.inHours % 24;
    final minutes = _left.inMinutes % 60;
    final seconds = _left.inSeconds % 60;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: widget.padding,
        child: LayoutBuilder(
          builder: (context, c) {
            final isTight = c.maxWidth < 380;
            final items = [
              _UnitCard(value: _two(days), label: 'يوم'),
              _UnitCard(value: _two(hours), label: 'ساعة'),
              _UnitCard(value: _two(minutes), label: 'دقائق'),
              _UnitCard(value: _two(seconds), label: 'ثواني'),
            ];

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items.map((w) {
                // Expanded/Flexible must be direct children of Row. Wrap the
                // constrained content inside them instead of the other way
                // around to avoid "Incorrect use of ParentDataWidget" errors.
                final constrained = ConstrainedBox(
                  constraints: BoxConstraints(minWidth: widget.cardWidth),
                  child: w,
                );
                return isTight
                    ? Flexible(child: constrained)
                    : Expanded(child: constrained);
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final String value;
  final String label;

  const _UnitCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // use brand gradient from AppColors
        gradient: AppColors.brandVerticalGradient,
        // shadow derived from brand color
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.20),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
        // optional border using palette (uncomment if you want an edge)
        // border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.background, // white from palette
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.background, // white from palette
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
