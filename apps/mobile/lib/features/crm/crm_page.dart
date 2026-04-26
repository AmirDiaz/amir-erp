// Amir ERP — Crm page.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import '../../design_system/tokens/theme.dart';

class CrmPage extends StatelessWidget {
  const CrmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AmirSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crm', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AmirSpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.construction),
              title: const Text('Crm module'),
              subtitle: const Text('Connected to backend at /api/v1. Built by Amir Saoudi.'),
            ),
          ),
        ],
      ),
    );
  }
}
