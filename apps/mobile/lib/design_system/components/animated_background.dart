// Amir ERP — lightweight futuristic background.
// Author: Amir Saoudi.
//
// Cheapest possible "alive" background for Flutter web:
// - Static gradient mesh painted ONCE (RepaintBoundary, no controller).
// - No MaskFilter, no shaders rebuilt per frame, no particles.
// - Vibe still futuristic via gradients + grid.

import 'package:flutter/material.dart';
import '../tokens/theme.dart';

class AmirAnimatedBackground extends StatelessWidget {
  const AmirAnimatedBackground({super.key, required this.child, this.density = 0});
  final Widget child;
  final int density; // ignored — kept for API compatibility

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AmirColors.bg),
        const RepaintBoundary(
          child: CustomPaint(
            painter: _StaticBgPainter(),
            size: Size.infinite,
          ),
        ),
        child,
      ],
    );
  }
}

class _StaticBgPainter extends CustomPainter {
  const _StaticBgPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _blob(canvas, cx: w * 0.18, cy: h * 0.22, radius: w * 0.55,
        color: AmirColors.primary.withValues(alpha: 0.30));
    _blob(canvas, cx: w * 0.85, cy: h * 0.18, radius: w * 0.45,
        color: AmirColors.secondary.withValues(alpha: 0.22));
    _blob(canvas, cx: w * 0.55, cy: h * 0.90, radius: w * 0.6,
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.20));

    // Vertical fade for legibility.
    final fade = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x00000000), Color(0x55000000)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), fade);

    // Subtle grid (cyber feel).
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.022)
      ..strokeWidth = 1;
    const step = 80.0;
    for (double x = 0; x < w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), grid);
    }
    for (double y = 0; y < h; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }
  }

  void _blob(Canvas canvas,
      {required double cx, required double cy, required double radius, required Color color}) {
    final paint = Paint()
      ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
          .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _StaticBgPainter oldDelegate) => false;
}
