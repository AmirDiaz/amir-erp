// Amir ERP — splash screen with mandatory Amir Saoudi signature.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';

import '../../app/branding.dart';
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
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const AmirLogo(size: 112),
                    const SizedBox(height: AmirSpacing.lg),
                    ShaderMask(
                      shaderCallback: (r) => AmirGradients.brandSoft.createShader(r),
                      child: Text(
                        AmirBranding.appName,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: AmirSpacing.sm),
                    Text(
                      AmirBranding.tagline,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: AmirSpacing.xxl),
                    SizedBox(
                      width: 220,
                      height: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation(AmirColors.primary),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(AmirRadius.pill),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_outlined, size: 16, color: AmirColors.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'Signed by ${AmirBranding.author}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
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
          ),
        ),
      ),
    );
  }
}
