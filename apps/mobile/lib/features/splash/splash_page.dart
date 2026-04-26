// Amir ERP — splash screen (futuristic boot sequence with mandatory Amir Saoudi signature).
// Author: Amir Saoudi.

import 'package:flutter/material.dart';

import '../../app/branding.dart';
import '../../design_system/components/amir_glass_card.dart';
import '../../design_system/components/amir_logo.dart';
import '../../design_system/components/animated_background.dart';
import '../../design_system/tokens/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmirAnimatedBackground(
        density: 90,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = Curves.easeOutCubic.transform(_ctrl.value);
              return Center(
                child: Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 24 * (1 - t)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        AmirGlowPulse(
                          color: AmirColors.primary,
                          borderRadius: BorderRadius.circular(36),
                          child: const AmirLogo(size: 120),
                        ),
                        const SizedBox(height: AmirSpacing.lg),
                        ShaderMask(
                          shaderCallback: (r) => AmirGradients.brandSoft.createShader(r),
                          child: Text(
                            AmirBranding.appName,
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1.8,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: AmirSpacing.sm),
                        Text(
                          AmirBranding.tagline.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11.5,
                            letterSpacing: 3.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AmirSpacing.xxl),
                        const _BootLines(),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(AmirRadius.pill),
                            border: Border.all(color: AmirColors.secondary.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, size: 16, color: AmirColors.secondary),
                              const SizedBox(width: 8),
                              Text(
                                'Signed by ${AmirBranding.author}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AmirBranding.authorEmail,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
                        ),
                        const SizedBox(height: AmirSpacing.lg),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BootLines extends StatefulWidget {
  const _BootLines();
  @override
  State<_BootLines> createState() => _BootLinesState();
}

class _BootLinesState extends State<_BootLines> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  static const _lines = [
    '> initializing tenant runtime',
    '> warming up postgres + redis',
    '> bootstrapping modules · 24 / 24',
    '> ready',
  ];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final shown = (_c.value * _lines.length).ceil().clamp(1, _lines.length);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < shown; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _lines[i],
                    style: TextStyle(
                      color: i == shown - 1
                          ? AmirColors.secondary.withValues(alpha: 0.95)
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 11.5,
                      fontFamily: 'monospace',
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _c.value,
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor: const AlwaysStoppedAnimation(AmirColors.primary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
