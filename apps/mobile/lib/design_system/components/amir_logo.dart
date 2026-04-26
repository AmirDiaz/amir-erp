// Amir ERP — wordmark logo component.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import '../tokens/theme.dart';

class AmirLogo extends StatelessWidget {
  const AmirLogo({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AmirColors.primary, AmirColors.secondary],
        ),
        borderRadius: BorderRadius.circular(AmirRadius.md),
      ),
      child: Center(
        child: Text(
          'A',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }
}
