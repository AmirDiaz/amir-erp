// Amir ERP — primary navigation shell with side rail + Amir Saoudi footer.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/branding.dart';
import '../../core/auth/auth_controller.dart';
import '../../design_system/components/amir_footer.dart';
import '../../design_system/components/amir_logo.dart';

class ShellPage extends ConsumerWidget {
  const ShellPage({super.key, required this.child});
  final Widget child;

  static const _routes = <(IconData, String, String)>[
    (Icons.dashboard_outlined, 'Dashboard', '/dashboard'),
    (Icons.account_balance_wallet_outlined, 'Accounting', '/accounting'),
    (Icons.point_of_sale_outlined, 'POS', '/pos'),
    (Icons.shopping_bag_outlined, 'Sales', '/sales'),
    (Icons.handshake_outlined, 'CRM', '/crm'),
    (Icons.inventory_2_outlined, 'Inventory', '/inventory'),
    (Icons.people_outline, 'HR', '/hr'),
    (Icons.settings_outlined, 'Settings', '/settings'),
    (Icons.info_outline, 'About', '/about'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = GoRouterState.of(context).matchedLocation;
    final selected = _routes.indexWhere((r) => route.startsWith(r.$3));
    final wide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      drawer: wide ? null : _drawer(context, ref, selected),
      appBar: wide
          ? null
          : AppBar(
              title: Text(AmirBranding.appName),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                )
              ],
            ),
      body: Row(
        children: [
          if (wide) _railNav(context, ref, selected),
          Expanded(
            child: Column(
              children: [
                Expanded(child: child),
                const AmirFooter(dense: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawer(BuildContext ctx, WidgetRef ref, int selected) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: AmirLogo(size: 56)),
          for (var i = 0; i < _routes.length; i++)
            ListTile(
              leading: Icon(_routes[i].$1),
              title: Text(_routes[i].$2),
              selected: i == selected,
              onTap: () {
                Navigator.pop(ctx);
                ctx.go(_routes[i].$3);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }

  Widget _railNav(BuildContext ctx, WidgetRef ref, int selected) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Theme.of(ctx).colorScheme.surface,
        border: Border(right: BorderSide(color: Theme.of(ctx).dividerColor)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const AmirLogo(size: 48),
          const SizedBox(height: 8),
          Text(AmirBranding.appName, style: Theme.of(ctx).textTheme.titleMedium),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < _routes.length; i++)
                  ListTile(
                    leading: Icon(_routes[i].$1),
                    title: Text(_routes[i].$2),
                    selected: i == selected,
                    onTap: () => ctx.go(_routes[i].$3),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
