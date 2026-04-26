// Amir ERP — dashboard.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';

import '../../design_system/tokens/theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AmirSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AmirSpacing.lg),
          Wrap(
            spacing: AmirSpacing.md,
            runSpacing: AmirSpacing.md,
            children: const [
              _StatCard(title: 'Revenue (MTD)', value: '\$ 124,500', icon: Icons.trending_up),
              _StatCard(title: 'Open Invoices', value: '32', icon: Icons.receipt_long),
              _StatCard(title: 'Active Orders', value: '17', icon: Icons.shopping_cart_checkout),
              _StatCard(title: 'Inventory Value', value: '\$ 412,890', icon: Icons.inventory),
              _StatCard(title: 'Active POS Sessions', value: '3', icon: Icons.point_of_sale),
              _StatCard(title: 'Employees', value: '48', icon: Icons.people_alt),
            ],
          ),
          const SizedBox(height: AmirSpacing.xl),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AmirSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent activity', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AmirSpacing.md),
                  for (var i = 0; i < 5; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.fiber_manual_record, size: 8),
                      title: Text('Sample event #${i + 1}'),
                      subtitle: const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit.'),
                      trailing: const Text('just now'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AmirSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AmirColors.primary),
              const SizedBox(height: AmirSpacing.sm),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AmirSpacing.xs),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
