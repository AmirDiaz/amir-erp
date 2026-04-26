// Amir ERP — surface widgets (lightweight, web-friendly).
// Author: Amir Saoudi.
//
// All widgets here are designed to be CHEAP on Flutter web:
// - No BackdropFilter
// - No animated shaders / SweepGradient
// - No MaskFilter
// Animations limited to color/opacity tweens that the engine handles efficiently.

import 'package:flutter/material.dart';
import '../tokens/theme.dart';

class AmirGlassCard extends StatelessWidget {
  const AmirGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.gradient,
    this.glow = false,
    this.borderColor,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final bool glow;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AmirRadius.lg);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AmirColors.card.withValues(alpha: 0.78) : null,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? Colors.white.withValues(alpha: 0.06)),
        boxShadow: glow ? AmirShadows.glow : AmirShadows.card,
      ),
      child: child,
    );
  }
}

/// Static gradient border (no rotation) — futuristic look without animation cost.
class AmirNeonBorder extends StatelessWidget {
  const AmirNeonBorder({
    super.key,
    required this.child,
    this.borderRadius,
    this.thickness = 1.2,
  });
  final Widget child;
  final BorderRadius? borderRadius;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AmirRadius.lg);
    return Container(
      padding: EdgeInsets.all(thickness),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AmirColors.primary,
            AmirColors.secondary,
            Color(0xFF8B5CF6),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          ((radius.topLeft.x) - thickness).clamp(0, double.infinity).toDouble(),
        ),
        child: child,
      ),
    );
  }
}

/// Subtle one-controller glow (color tween only — no rebuilds of layout).
/// Still expensive if used too many times — use sparingly.
class AmirGlowPulse extends StatefulWidget {
  const AmirGlowPulse({
    super.key,
    required this.child,
    this.color = AmirColors.primary,
    this.borderRadius,
  });
  final Widget child;
  final Color color;
  final BorderRadius? borderRadius;

  @override
  State<AmirGlowPulse> createState() => _AmirGlowPulseState();
}

class _AmirGlowPulseState extends State<AmirGlowPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(AmirRadius.lg);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) {
          final v = _c.value;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.18 + 0.28 * v),
                  blurRadius: 16 + 14 * v,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// One-shot animated counter — efficient (single TweenAnimationBuilder, no repeat).
class AmirAnimatedCounter extends StatefulWidget {
  const AmirAnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.fractionDigits = 0,
    this.duration = const Duration(milliseconds: 1200),
  });
  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final int fractionDigits;
  final Duration duration;

  @override
  State<AmirAnimatedCounter> createState() => _AmirAnimatedCounterState();
}

class _AmirAnimatedCounterState extends State<AmirAnimatedCounter> {
  double _from = 0;

  @override
  void didUpdateWidget(covariant AmirAnimatedCounter old) {
    super.didUpdateWidget(old);
    _from = old.value;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _from, end: widget.value),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(
        '${widget.prefix}${_format(v)}${widget.suffix}',
        style: widget.style,
      ),
    );
  }

  String _format(double v) {
    if (widget.fractionDigits == 0) {
      return v.toInt().toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return v.toStringAsFixed(widget.fractionDigits);
  }
}

/// Cheap pulsing dot — single controller, single decoration update.
class AmirPulseDot extends StatefulWidget {
  const AmirPulseDot({super.key, this.color = AmirColors.success, this.size = 7});
  final Color color;
  final double size;

  @override
  State<AmirPulseDot> createState() => _AmirPulseDotState();
}

class _AmirPulseDotState extends State<AmirPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 + 0.4 * _c.value),
                blurRadius: 4 + 4 * _c.value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
