// Amir ERP — glassmorphism card component.
// Author: Amir Saoudi.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/theme.dart';

class AmirGlassCard extends StatelessWidget {
  const AmirGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AmirSpacing.lg),
    this.borderRadius,
    this.gradient,
    this.glow = false,
  });
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(AmirRadius.lg);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: glow ? AmirShadows.glow : AmirShadows.card,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white.withValues(alpha: 0.65))
                  : null,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.6),
                width: 1,
              ),
              borderRadius: radius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AmirGradientBorder extends StatelessWidget {
  const AmirGradientBorder({super.key, required this.child, this.radius = AmirRadius.lg, this.thickness = 1.2});
  final Widget child;
  final double radius;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(thickness),
      decoration: BoxDecoration(
        gradient: AmirGradients.brand,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - thickness),
        child: child,
      ),
    );
  }
}
