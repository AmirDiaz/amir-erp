// Amir ERP — global footer with mandatory "Amir Saoudi" signature.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import '../../app/branding.dart';

class AmirFooter extends StatelessWidget {
  const AmirFooter({super.key, this.dense = false});
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 6 : 12, horizontal: 16),
      child: Center(
        child: Text(
          '${AmirBranding.copyright(year)} · ${AmirBranding.appName} · Built by ${AmirBranding.author}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
