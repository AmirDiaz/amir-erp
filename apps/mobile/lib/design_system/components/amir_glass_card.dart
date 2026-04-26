// Amir ERP — futuristic surface widgets.
// Author: Amir Saoudi.
//
// AmirGlassCard: solid translucent panel with gradient border + soft glow.
//   (BackdropFilter removed — too heavy on web; uses tinted color instead.)
//
// AmirNeonBorder: animated gradient border that "breathes" (great for hero panels
//   and CTA cards).
//
// AmirGlowPulse: cheap repeating box-shadow pulse around any child.

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

class AmirNeonBorder extends StatefulWidget {
  const AmirNeonBorder({
    super.key,
    required this.child,
    this.borderRadius,
    this.thickness = 1.4,
  });
  final Widget child;
  final BorderRadius? borderRadius;
  final double thickness;

  @override
  State<AmirNeonBorder> createState() => _AmirNeonBorderState();
}

class _AmirNeonBorderState extends State<AmirNeonBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
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
        builder: (_, __) {
          final t = _c.value;
          return Container(
            padding: EdgeInsets.all(widget.thickness),
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: SweepGradient(
                startAngle: 0,
                endAngle: 6.283,
                transform: GradientRotation(t * 6.283),
                colors: const [
                  AmirColors.primary,
                  AmirColors.secondary,
                  Color(0xFF8B5CF6),
                  AmirColors.primary,
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                ((radius.topLeft.x) - widget.thickness).clamp(0, double.infinity).toDouble(),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

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
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
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
          return Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.18 + 0.32 * v),
                  blurRadius: 18 + 22 * v,
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

class AmirAnimatedCounter extends StatefulWidget {
  const AmirAnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.fractionDigits = 0,
    this.duration = const Duration(milliseconds: 1400),
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

class AmirShimmer extends StatefulWidget {
  const AmirShimmer({super.key, required this.child});
  final Widget child;
  @override
  State<AmirShimmer> createState() => _AmirShimmerState();
}

class _AmirShimmerState extends State<AmirShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
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
        builder: (_, child) {
          final t = _c.value;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment(-1.5 + t * 3, -0.5),
              end: Alignment(-0.5 + t * 3, 0.5),
              colors: [
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0.35),
                Colors.white.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
