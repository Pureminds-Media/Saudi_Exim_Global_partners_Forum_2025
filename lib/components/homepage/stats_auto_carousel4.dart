import 'dart:async';
import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';

class StatsAutoCarousel extends StatefulWidget {
  /// items = [{ 'value': '500', 'label': 'زائر' }, ...]
  final List<Map<String, String>> items;
  final Duration autoEvery; // step interval
  final double cardWidth;
  final double cardHeight;

  const StatsAutoCarousel({
    super.key,
    required this.items,
    this.autoEvery = const Duration(seconds: 2), // ← moves every 5s
    this.cardWidth = 64,
    this.cardHeight = 64,
  });

  @override
  State<StatsAutoCarousel> createState() => _StatsAutoCarouselState();
}

class _StatsAutoCarouselState extends State<StatsAutoCarousel> {
  late final PageController _pc;
  Timer? _timer;
  Timer? _resumeTimer;
  bool _userInteracting = false;
  late int _page;
  late int _initialPage;

  @override
  void initState() {
    super.initState();

    // Start far from edges so we can "infinite" loop by just increasing the page.
    _initialPage = widget.items.isEmpty ? 0 : widget.items.length * 1000;

    _pc = PageController(
      viewportFraction: 0.24, // ≈4 visible with a small gap
      initialPage: _initialPage,
    );

    _page = _initialPage;

    // Start the timer AFTER first frame to avoid race with first build/layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAuto();
    });
  }

  void _startAuto() {
    _timer?.cancel();
    if (widget.items.isEmpty) return;

    _timer = Timer.periodic(widget.autoEvery, (_) {
      if (!mounted || _userInteracting) return;

      final next = _page + 1; // step forward forever
      _pc.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _page = next;

      // Occasionally jump back near the anchor to keep numbers small (no visual jump).
      if (_page > _initialPage + 4000) {
        _pc.jumpToPage(_initialPage);
        _page = _initialPage;
      }
    });
  }

  void _pauseAuto() {
    _userInteracting = true;
    _timer?.cancel();
  }

  void _resumeAutoAfterIdle() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 2), () {
      _userInteracting = false;
      _startAuto();
    });
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          gradient: AppColors.brandVerticalGradient,
        ),
        child: Column(
          children: [
            const Text(
              'تمكين التجارة\nوتوسيع آفاق الشراكات العالمية',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.background,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),

            SizedBox(
              height: widget.cardHeight + 52, // card + label
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  // Pause ONLY on real user drags; programmatic anims won't pause it.
                  if (n is ScrollUpdateNotification && n.dragDetails != null) {
                    _pauseAuto();
                  }
                  if (n is ScrollEndNotification) {
                    _resumeAutoAfterIdle();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pc,
                  onPageChanged: (i) => _page = i,
                  padEnds: false,
                  // infinite mapping: use modulo to show finite data at any index
                  itemBuilder: (_, index) {
                    final map = widget.items[index % widget.items.length];
                    final value = map['value'] ?? '';
                    final label = map['label'] ?? '';
                    return Align(
                      alignment: Alignment.topCenter,
                      child: _StatCard(
                        value: value,
                        label: label,
                        width: widget.cardWidth,
                        height: widget.cardHeight,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final double width;
  final double height;

  const _StatCard({
    required this.value,
    required this.label,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.background, // over gradient
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
