import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../viewmodels/splash_page_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2400,
      ), // Slower for smoother effect
    )..repeat();

    // Use a curved animation for smoother motion
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Trigger loading after the first frame so context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashPageViewModel>().loadData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SplashPageViewModel>();

    if (!vm.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/home'));
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: vm.isLoading
          ? Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo-white.png',
                        height: 120,
                        width: MediaQuery.of(context).size.width * 0.7,
                      ),
                      const SizedBox(height: 32),
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (_, __) =>
                            _RippleLoader(progress: _animation.value),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 48,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'brought you by',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Image.asset('assets/saudi-exim-logo.png', height: 40),
                    ],
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

// A clean ripple loader: three expanding, fading rings + a center dot.
class _RippleLoader extends StatelessWidget {
  const _RippleLoader({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: 72,
        height: 72,
        child: CustomPaint(painter: _RipplePainter(progress: progress)),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  const _RipplePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = math.min(size.width, size.height) / 2;

    // Three ripples for smoother effect
    for (int i = 0; i < 3; i++) {
      final p = ((progress + i * 0.33) % 1.0);

      // Use eased progress for smoother animation
      final easedP = _easeInOutQuad(p);

      final r = 6 + easedP * maxR; // radius grows with progress

      // Smoother opacity curve
      final opacity = math.pow(1.0 - p, 2.0).clamp(0.0, 1.0);

      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            2.5 -
            (p * 1.5) // Stroke gets thinner as it expands
        ..color = Colors.white.withOpacity(opacity * 0.6);

      canvas.drawCircle(center, r, ring);
    }

    // Pulsing center dot for visual anchor
    final dotScale = 0.9 + (math.sin(progress * math.pi * 2) * 0.1);
    final dot = Paint()..color = Colors.white.withOpacity(0.95);
    canvas.drawCircle(center, 4 * dotScale, dot);
  }

  // Easing function for smoother animation
  double _easeInOutQuad(double t) {
    if (t < 0.5) {
      return 2 * t * t;
    } else {
      return -1 + (4 - 2 * t) * t;
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) => old.progress != progress;
}
