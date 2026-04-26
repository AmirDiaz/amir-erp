// Amir ERP — futuristic animated background (mesh gradient + particle starfield).
// Author: Amir Saoudi.
//
// Performance notes:
// - No BackdropFilter (very expensive on Flutter web).
// - Single CustomPainter repainting once per frame (~60fps), wrapped in RepaintBoundary.
// - Particles use cached Float32 positions + simple sin/cos motion.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../tokens/theme.dart';

class AmirAnimatedBackground extends StatefulWidget {
  const AmirAnimatedBackground({super.key, required this.child, this.density = 70});
  final Widget child;
  final int density;

  @override
  State<AmirAnimatedBackground> createState() => _AmirAnimatedBackgroundState();
}

class _AmirAnimatedBackgroundState extends State<AmirAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
    final rng = math.Random(42);
    _particles = List.generate(widget.density, (_) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        r: rng.nextDouble() * 1.6 + 0.4,
        speed: rng.nextDouble() * 0.4 + 0.1,
        phase: rng.nextDouble() * math.pi * 2,
        hue: rng.nextDouble(),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AmirColors.bg),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              painter: _BgPainter(t: _ctrl.value, particles: _particles),
              size: Size.infinite,
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.r,
    required this.speed,
    required this.phase,
    required this.hue,
  });
  final double x;
  final double y;
  final double r;
  final double speed;
  final double phase;
  final double hue;
}

class _BgPainter extends CustomPainter {
  _BgPainter({required this.t, required this.particles});
  final double t;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final tp = t * math.pi * 2;

    // 1. Mesh gradient: 3 large radial blobs with sin/cos motion.
    _blob(canvas, w, h,
        cx: w * (0.18 + 0.06 * math.sin(tp)),
        cy: h * (0.22 + 0.04 * math.cos(tp * 1.1)),
        radius: math.max(w, h) * 0.55,
        color: AmirColors.primary.withValues(alpha: 0.32));
    _blob(canvas, w, h,
        cx: w * (0.82 + 0.05 * math.sin(tp * 0.9 + 1.2)),
        cy: h * (0.20 + 0.05 * math.cos(tp * 0.7 + 0.6)),
        radius: math.max(w, h) * 0.45,
        color: AmirColors.secondary.withValues(alpha: 0.26));
    _blob(canvas, w, h,
        cx: w * (0.55 + 0.07 * math.sin(tp * 0.6 + 2.4)),
        cy: h * (0.85 + 0.05 * math.cos(tp * 0.8 + 1.0)),
        radius: math.max(w, h) * 0.6,
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.22));

    // 2. Subtle vertical fade for legibility.
    final fade = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x00000000),
          Color(0x66000000),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), fade);

    // 3. Grid lines (cyber feel).
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    const step = 60.0;
    for (double x = 0; x < w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), grid);
    }
    for (double y = 0; y < h; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }

    // 4. Particle starfield.
    for (final p in particles) {
      final dx = p.x * w + 14 * math.sin(tp * p.speed + p.phase);
      final dy = p.y * h + 10 * math.cos(tp * p.speed * 0.8 + p.phase);
      final twinkle = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(tp * 2 * p.speed + p.phase));
      final color = Color.lerp(AmirColors.primary, AmirColors.secondary, p.hue)!
          .withValues(alpha: 0.55 * twinkle);
      final paint = Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
      canvas.drawCircle(Offset(dx, dy), p.r, paint);
    }
  }

  void _blob(Canvas canvas, double w, double h,
      {required double cx, required double cy, required double radius, required Color color}) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}
