// Amir ERP — splash screen with mandatory Amir Saoudi signature.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';

import '../../app/branding.dart';
import '../../design_system/components/amir_logo.dart';
import '../../design_system/tokens/theme.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AmirColors.primary, AmirColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AmirLogo(size: 96),
                const SizedBox(height: 24),
                Text(
                  AmirBranding.appName,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AmirBranding.tagline,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(color: Colors.white),
                const Spacer(),
                Text(
                  'Signed by ${AmirBranding.author}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  AmirBranding.authorEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
