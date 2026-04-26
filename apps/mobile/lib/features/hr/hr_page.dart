// Amir ERP — Hr page.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import '../../design_system/tokens/theme.dart';

class HrPage extends StatelessWidget {
  const HrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AmirSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hr', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AmirSpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.construction),
              title: const Text('Hr module'),
              subtitle: const Text('Connected to backend at /api/v1. Built by Amir Saoudi.'),
            ),
          ),
        ],
      ),
    );
  }
}
