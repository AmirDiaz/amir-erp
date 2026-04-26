// Amir ERP — primary navigation shell with side rail + Amir Saoudi footer.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/branding.dart';
import '../../core/auth/auth_controller.dart';
import '../../design_system/components/amir_footer.dart';
import '../../design_system/components/amir_logo.dart';
import '../../design_system/tokens/theme.dart';

class _NavItem {
  const _NavItem(this.icon, this.label, this.route, [this.badge]);
  final IconData icon;
  final String label;
  final String route;
  final String? badge;
}

class _Section {
  const _Section(this.title, this.items);
  final String title;
  final List<_NavItem> items;
}

const _sections = <_Section>[
  _Section('Workspace', [
    _NavItem(Icons.dashboard_rounded, 'Dashboard', '/dashboard'),
  ]),
  _Section('Finance', [
    _NavItem(Icons.account_balance_wallet_rounded, 'Accounting', '/accounting'),
    _NavItem(Icons.receipt_long_rounded, 'Sales', '/sales', '12'),
  ]),
  _Section('Operations', [
    _NavItem(Icons.point_of_sale_rounded, 'POS', '/pos'),
    _NavItem(Icons.inventory_2_rounded, 'Inventory', '/inventory'),
    _NavItem(Icons.handshake_rounded, 'CRM', '/crm', '4'),
  ]),
  _Section('People', [
    _NavItem(Icons.groups_rounded, 'HR', '/hr'),
  ]),
  _Section('System', [
    _NavItem(Icons.settings_rounded, 'Settings', '/settings'),
    _NavItem(Icons.info_rounded, 'About', '/about'),
  ]),
];

class ShellPage extends ConsumerWidget {
  const ShellPage({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = GoRouterState.of(context).matchedLocation;
    final wide = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      drawer: wide ? null : _Drawer(currentRoute: route),
      appBar: wide
          ? null
          : AppBar(
              backgroundColor: AmirColors.bg,
              elevation: 0,
              title: Row(
                children: [
                  const AmirLogo(size: 28, glow: false),
                  const SizedBox(width: 10),
                  Text(AmirBranding.appName, style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                )
              ],
            ),
      body: Row(
        children: [
          if (wide) _SideRail(currentRoute: route),
          Expanded(
            child: Column(
              children: [
                if (wide) const _TopBar(),
                Expanded(
                  child: Container(
                    color: AmirColors.bg,
                    child: child,
                  ),
                ),
                const AmirFooter(dense: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AmirColors.bg,
        border: Border(bottom: BorderSide(color: AmirColors.stroke)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AmirColors.surface,
                borderRadius: BorderRadius.circular(AmirRadius.md),
                border: Border.all(color: AmirColors.stroke),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 18, color: AmirColors.muted.withValues(alpha: 0.8)),
                  const SizedBox(width: 10),
                  Text('Search transactions, customers, products…',
                      style: TextStyle(color: AmirColors.muted.withValues(alpha: 0.8), fontSize: 13)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AmirColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('⌘K',
                        style: TextStyle(color: AmirColors.muted.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          _IconButton(icon: Icons.help_outline_rounded, onTap: () {}),
          const SizedBox(width: 4),
          Stack(
            children: [
              _IconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
              Positioned(
                top: 10, right: 10,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AmirColors.danger, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 26, color: AmirColors.stroke),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: AmirColors.surface,
              borderRadius: BorderRadius.circular(AmirRadius.pill),
              border: Border.all(color: AmirColors.stroke),
            ),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(gradient: AmirGradients.brand, shape: BoxShape.circle),
                  child: const Center(
                    child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Amir', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 6),
                Icon(Icons.expand_more_rounded, size: 18, color: AmirColors.muted),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AmirRadius.md),
      child: Container(
        width: 40, height: 40,
        alignment: Alignment.center,
        child: Icon(icon, color: AmirColors.muted, size: 20),
      ),
    );
  }
}

class _SideRail extends ConsumerWidget {
  const _SideRail({required this.currentRoute});
  final String currentRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AmirColors.surface,
        border: Border(right: BorderSide(color: AmirColors.stroke)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Row(
              children: [
                const AmirLogo(size: 36),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AmirBranding.appName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, height: 1)),
                    const SizedBox(height: 4),
                    Text('v${AmirBranding.version}',
                        style: TextStyle(fontSize: 11, color: AmirColors.muted.withValues(alpha: 0.8), height: 1)),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: AmirColors.stroke),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              children: [
                for (final s in _sections) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                    child: Text(
                      s.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AmirColors.muted.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  for (final it in s.items) _NavTile(item: it, currentRoute: currentRoute),
                ],
              ],
            ),
          ),
          Container(height: 1, color: AmirColors.stroke),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () => ref.read(authControllerProvider.notifier).logout(),
              borderRadius: BorderRadius.circular(AmirRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AmirColors.surfaceAlt.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AmirRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 18, color: AmirColors.muted),
                    const SizedBox(width: 12),
                    const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: AmirColors.muted.withValues(alpha: 0.7)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.currentRoute});
  final _NavItem item;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final selected = currentRoute.startsWith(item.route);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(AmirRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [
                      AmirColors.primary.withValues(alpha: 0.22),
                      AmirColors.secondary.withValues(alpha: 0.08),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(AmirRadius.md),
            border: selected
                ? Border.all(color: AmirColors.primary.withValues(alpha: 0.4))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 18,
                color: selected ? AmirColors.primary : AmirColors.muted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : AmirColors.muted,
                  ),
                ),
              ),
              if (item.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: AmirGradients.brand,
                    borderRadius: BorderRadius.circular(AmirRadius.pill),
                  ),
                  child: Text(
                    item.badge!,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Drawer extends ConsumerWidget {
  const _Drawer({required this.currentRoute});
  final String currentRoute;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AmirColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Row(
                children: [
                  const AmirLogo(size: 36),
                  const SizedBox(width: 12),
                  Text(AmirBranding.appName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                children: [
                  for (final s in _sections) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                      child: Text(
                        s.title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4,
                          color: AmirColors.muted.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    for (final it in s.items) _NavTile(item: it, currentRoute: currentRoute),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
