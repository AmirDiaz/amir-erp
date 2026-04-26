// Amir ERP — animated gradient background with floating orbs.
// Author: Amir Saoudi.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens/theme.dart';

class AmirAnimatedBackground extends StatefulWidget {
  const AmirAnimatedBackground({super.key, this.child});
  final Widget? child;

  @override
  State<AmirAnimatedBackground> createState() => _AmirAnimatedBackgroundState();
}

class _AmirAnimatedBackgroundState extends State<AmirAnimatedBackground>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0B0F1A), Color(0xFF131A2A), Color(0xFF0B0F1A)],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final t = _ctrl.value * 2 * math.pi;
            return Stack(
              children: [
                _orb(
                  dx: 0.18 + 0.06 * math.sin(t),
                  dy: 0.22 + 0.04 * math.cos(t),
                  size: 380,
                  color: AmirColors.primary.withValues(alpha: 0.55),
                ),
                _orb(
                  dx: 0.78 + 0.05 * math.cos(t * 0.8),
                  dy: 0.18 + 0.06 * math.sin(t * 0.7),
                  size: 320,
                  color: AmirColors.secondary.withValues(alpha: 0.45),
                ),
                _orb(
                  dx: 0.65 + 0.06 * math.sin(t * 0.6 + 1.2),
                  dy: 0.78 + 0.04 * math.cos(t * 0.9),
                  size: 460,
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                ),
                _orb(
                  dx: 0.22 + 0.05 * math.cos(t * 1.1),
                  dy: 0.82 + 0.05 * math.sin(t * 0.5),
                  size: 300,
                  color: AmirColors.accent.withValues(alpha: 0.22),
                ),
              ],
            );
          },
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AmirColors.bg.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
        ),
        if (widget.child != null) Positioned.fill(child: widget.child!),
      ],
    );
  }

  Widget _orb({required double dx, required double dy, required double size, required Color color}) {
    return LayoutBuilder(builder: (ctx, c) {
      return Positioned(
        left: c.maxWidth * dx - size / 2,
        top: c.maxHeight * dy - size / 2,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
            ),
          ),
        ),
      );
    });
  }
}
