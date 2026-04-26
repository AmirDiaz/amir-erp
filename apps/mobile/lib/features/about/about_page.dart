// Amir ERP — About page (mandatory Amir Saoudi signature).
// Author: Amir Saoudi.

import 'package:flutter/material.dart';

import '../../app/branding.dart';
import '../../design_system/components/amir_logo.dart';
import '../../design_system/tokens/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(AmirSpacing.lg),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AmirLogo(size: 80),
                  const SizedBox(height: 16),
                  Text(AmirBranding.appName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('v${AmirBranding.version}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  Text(AmirBranding.tagline, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Author', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: 8),
                  Text(AmirBranding.author, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text(AmirBranding.authorEmail, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Text(AmirBranding.copyright(DateTime.now().year), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
