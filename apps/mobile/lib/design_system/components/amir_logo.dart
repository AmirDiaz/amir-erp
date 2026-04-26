// Amir ERP — wordmark logo component.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import '../tokens/theme.dart';

class AmirLogo extends StatelessWidget {
  const AmirLogo({super.key, this.size = 56, this.glow = true});
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AmirGradients.brand,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AmirColors.primary.withValues(alpha: 0.45),
                  blurRadius: size * 0.6,
                  spreadRadius: -size * 0.1,
                  offset: Offset(0, size * 0.18),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // glossy highlight
          Positioned(
            top: size * 0.08,
            left: size * 0.08,
            right: size * 0.08,
            height: size * 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0)],
                ),
                borderRadius: BorderRadius.circular(size * 0.2),
              ),
            ),
          ),
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              colors: [Colors.white, Color(0xFFE0E7FF)],
            ).createShader(r),
            child: Text(
              'A',
              style: TextStyle(
                fontSize: size * 0.55,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -size * 0.02,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
