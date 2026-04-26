// Amir ERP — modern dashboard with KPI cards, sparklines and activity feed.
// Author: Amir Saoudi.

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../design_system/components/amir_glass_card.dart';
import '../../design_system/tokens/theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 1200;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AmirSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LiveStatusBar(),
          const SizedBox(height: AmirSpacing.md),
          _Header(),
          const SizedBox(height: AmirSpacing.lg),
          _KpiGrid(wide: wide),
          const SizedBox(height: AmirSpacing.lg),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 3, child: _RevenueChartCard()),
                SizedBox(width: AmirSpacing.md),
                Expanded(flex: 2, child: _BreakdownCard()),
              ],
            )
          else
            const Column(children: [_RevenueChartCard(), SizedBox(height: AmirSpacing.md), _BreakdownCard()]),
          const SizedBox(height: AmirSpacing.lg),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 3, child: _ActivityCard()),
                SizedBox(width: AmirSpacing.md),
                Expanded(flex: 2, child: _QuickActionsCard()),
              ],
            )
          else
            const Column(children: [_ActivityCard(), SizedBox(height: AmirSpacing.md), _QuickActionsCard()]),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greet = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greet, Amir',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
              ),
              const SizedBox(height: 4),
              Text(
                'Here is what is happening across your workspace today.',
                style: TextStyle(fontSize: 13.5, color: AmirColors.muted.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AmirColors.surface,
            borderRadius: BorderRadius.circular(AmirRadius.md),
            border: Border.all(color: AmirColors.stroke),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AmirColors.muted),
              const SizedBox(width: 8),
              Text('Last 30 days',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AmirColors.muted.withValues(alpha: 0.95))),
              const SizedBox(width: 6),
              const Icon(Icons.expand_more_rounded, size: 16, color: AmirColors.muted),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            gradient: AmirGradients.brand,
            borderRadius: BorderRadius.circular(AmirRadius.md),
            boxShadow: [
              BoxShadow(
                color: AmirColors.primary.withValues(alpha: 0.4),
                blurRadius: 18, spreadRadius: -4, offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(AmirRadius.md),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Kpi {
  const _Kpi(
    this.title,
    this.numeric,
    this.delta,
    this.up,
    this.icon,
    this.gradient, {
    this.prefix = '',
    this.suffix = '',
    this.fractionDigits = 0,
  });
  final String title;
  final double numeric;
  final String delta;
  final bool up;
  final IconData icon;
  final Gradient gradient;
  final String prefix;
  final String suffix;
  final int fractionDigits;
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    const items = [
      _Kpi('REVENUE · MTD', 124500, '+12.4%', true, Icons.trending_up_rounded, AmirGradients.brand, prefix: '\$ '),
      _Kpi('OPEN INVOICES', 32, '-3', true, Icons.receipt_long_rounded, AmirGradients.success),
      _Kpi('ACTIVE ORDERS', 17, '+5', true, Icons.shopping_cart_rounded, AmirGradients.brandSoft),
      _Kpi('INVENTORY VALUE', 412890, '+2.1%', true, Icons.inventory_rounded, AmirGradients.accent, prefix: '\$ '),
      _Kpi('POS SESSIONS', 3, 'LIVE', true, Icons.point_of_sale_rounded, AmirGradients.brand),
      _Kpi('EMPLOYEES', 48, '+2', true, Icons.groups_rounded, AmirGradients.success),
    ];
    final cols = wide ? 4 : MediaQuery.of(context).size.width > 700 ? 3 : 2;
    return LayoutBuilder(builder: (_, c) {
      final spacing = AmirSpacing.md;
      final w = (c.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final k in items) SizedBox(width: w, child: _KpiCard(k: k)),
        ],
      );
    });
  }
}

class _KpiCard extends StatefulWidget {
  const _KpiCard({required this.k});
  final _Kpi k;
  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _hover ? -3.0 : 0.0),
        padding: const EdgeInsets.all(AmirSpacing.md),
        decoration: BoxDecoration(
          color: AmirColors.card,
          borderRadius: BorderRadius.circular(AmirRadius.lg),
          border: Border.all(
            color: _hover ? AmirColors.primary.withValues(alpha: 0.55) : AmirColors.stroke,
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: AmirColors.primary.withValues(alpha: 0.28),
                    blurRadius: 22,
                    spreadRadius: -6,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    gradient: k.gradient,
                    borderRadius: BorderRadius.circular(AmirRadius.sm),
                    boxShadow: [
                      BoxShadow(
                        color: AmirColors.primary.withValues(alpha: 0.45),
                        blurRadius: 14,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Icon(k.icon, color: Colors.white, size: 18),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (k.up ? AmirColors.success : AmirColors.danger).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AmirRadius.pill),
                    border: Border.all(
                      color: (k.up ? AmirColors.success : AmirColors.danger).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        k.up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 11, color: k.up ? AmirColors.success : AmirColors.danger,
                      ),
                      const SizedBox(width: 3),
                      Text(k.delta,
                          style: TextStyle(
                            color: k.up ? AmirColors.success : AmirColors.danger,
                            fontSize: 10.5, fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(k.title,
                style: TextStyle(
                  color: AmirColors.muted.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                )),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (r) => AmirGradients.brandSoft.createShader(r),
              child: AmirAnimatedCounter(
                value: k.numeric,
                prefix: k.prefix,
                suffix: k.suffix,
                fractionDigits: k.fractionDigits,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              child: SizedBox(
                height: 36,
                child: _Sparkline(seed: k.title.hashCode, gradient: k.gradient),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.seed, required this.gradient});
  final int seed;
  final Gradient gradient;

  List<FlSpot> _spots() {
    final r = math.Random(seed);
    final pts = <FlSpot>[];
    double v = 0.5 + r.nextDouble() * 0.3;
    for (int i = 0; i < 16; i++) {
      v += (r.nextDouble() - 0.45) * 0.18;
      v = v.clamp(0.05, 0.95);
      pts.add(FlSpot(i.toDouble(), v));
    }
    return pts;
  }

  @override
  Widget build(BuildContext context) {
    final colors = gradient is LinearGradient ? (gradient as LinearGradient).colors : <Color>[AmirColors.primary];
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minY: 0, maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: _spots(),
            isCurved: true,
            curveSmoothness: 0.32,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            gradient: LinearGradient(colors: colors),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.first.withValues(alpha: 0.28), colors.first.withValues(alpha: 0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChartCard extends StatelessWidget {
  const _RevenueChartCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(AmirSpacing.lg),
      decoration: BoxDecoration(
        color: AmirColors.card,
        borderRadius: BorderRadius.circular(AmirRadius.lg),
        border: Border.all(color: AmirColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Revenue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AmirColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AmirRadius.pill),
                ),
                child: const Text('+18.2%',
                    style: TextStyle(color: AmirColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              for (final t in const ['1W', '1M', '3M', '1Y'])
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: t == '1M' ? AmirColors.primary.withValues(alpha: 0.18) : null,
                      borderRadius: BorderRadius.circular(AmirRadius.sm),
                    ),
                    child: Text(t,
                        style: TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w700,
                          color: t == '1M' ? AmirColors.primary : AmirColors.muted,
                        )),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(child: _RevenueLine()),
        ],
      ),
    );
  }
}

class _RevenueLine extends StatelessWidget {
  List<FlSpot> _series(int seed, double base) {
    final r = math.Random(seed);
    final pts = <FlSpot>[];
    double v = base;
    for (int i = 0; i < 30; i++) {
      v += (r.nextDouble() - 0.45) * 12;
      v = v.clamp(20.0, 200.0);
      pts.add(FlSpot(i.toDouble(), v));
    }
    return pts;
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AmirColors.stroke.withValues(alpha: 0.7), strokeWidth: 1, dashArray: [4, 4]),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, reservedSize: 36, interval: 50,
              getTitlesWidget: (v, _) => Text(
                '\$${v.toInt()}k',
                style: TextStyle(color: AmirColors.muted.withValues(alpha: 0.7), fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, reservedSize: 24, interval: 7,
              getTitlesWidget: (v, _) {
                final labels = ['W1', 'W2', 'W3', 'W4', 'W5'];
                final i = (v / 7).floor();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i],
                      style: TextStyle(color: AmirColors.muted.withValues(alpha: 0.7), fontSize: 10)),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0, maxX: 29, minY: 0, maxY: 200,
        lineBarsData: [
          LineChartBarData(
            spots: _series(7, 110),
            isCurved: true, curveSmoothness: 0.3, barWidth: 2.5, isStrokeCapRound: true,
            gradient: AmirGradients.brand,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [AmirColors.primary.withValues(alpha: 0.32), AmirColors.primary.withValues(alpha: 0)],
              ),
            ),
          ),
          LineChartBarData(
            spots: _series(13, 80),
            isCurved: true, curveSmoothness: 0.3, barWidth: 2, isStrokeCapRound: true,
            color: AmirColors.muted.withValues(alpha: 0.5),
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard();
  @override
  Widget build(BuildContext context) {
    final segs = const [
      ('Sales', 0.42, AmirColors.primary),
      ('POS', 0.28, AmirColors.secondary),
      ('Subscriptions', 0.18, Color(0xFF8B5CF6)),
      ('Services', 0.12, AmirColors.accent),
    ];
    return Container(
      height: 320,
      padding: const EdgeInsets.all(AmirSpacing.lg),
      decoration: BoxDecoration(
        color: AmirColors.card,
        borderRadius: BorderRadius.circular(AmirRadius.lg),
        border: Border.all(color: AmirColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Channel breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Distribution of revenue',
              style: TextStyle(fontSize: 12, color: AmirColors.muted.withValues(alpha: 0.85))),
          const SizedBox(height: AmirSpacing.lg),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 180, height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 60,
                    sections: [
                      for (final s in segs)
                        PieChartSectionData(
                          color: s.$3,
                          value: s.$2 * 100,
                          title: '',
                          radius: 18,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AmirSpacing.md),
          for (final s in segs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: s.$3, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s.$1,
                        style: TextStyle(fontSize: 12.5, color: AmirColors.muted.withValues(alpha: 0.95), fontWeight: FontWeight.w500)),
                  ),
                  Text('${(s.$2 * 100).round()}%',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();
  @override
  Widget build(BuildContext context) {
    final events = const [
      (Icons.shopping_cart_rounded, AmirColors.primary, 'New order #ORD-3289', 'Acme Corp · \$2,450', '2m'),
      (Icons.person_add_rounded, AmirColors.secondary, 'Customer onboarded', 'Beta Studios joined', '14m'),
      (Icons.payments_rounded, AmirColors.success, 'Invoice paid', 'INV-1142 · \$890', '38m'),
      (Icons.warning_amber_rounded, AmirColors.warning, 'Low stock alert', 'SKU-0021 (3 units left)', '1h'),
      (Icons.account_balance_wallet_rounded, AmirColors.primary, 'Journal entry posted', 'AR Reconciliation · 12 lines', '2h'),
      (Icons.point_of_sale_rounded, AmirColors.secondary, 'POS session opened', 'Terminal #2 · Cashier: Sara', '3h'),
    ];
    return Container(
      padding: const EdgeInsets.all(AmirSpacing.lg),
      decoration: BoxDecoration(
        color: AmirColors.card,
        borderRadius: BorderRadius.circular(AmirRadius.lg),
        border: Border.all(color: AmirColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Recent activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('View all',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AmirColors.primary.withValues(alpha: 0.95))),
            ],
          ),
          const SizedBox(height: 4),
          Text('Live feed across all modules',
              style: TextStyle(fontSize: 12, color: AmirColors.muted.withValues(alpha: 0.85))),
          const SizedBox(height: AmirSpacing.md),
          for (final e in events)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: e.$2.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AmirRadius.sm),
                    ),
                    child: Icon(e.$1, size: 17, color: e.$2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.$3,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(e.$4,
                            style: TextStyle(fontSize: 12, color: AmirColors.muted.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                  Text(e.$5,
                      style: TextStyle(fontSize: 11.5, color: AmirColors.muted.withValues(alpha: 0.7))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();
  @override
  Widget build(BuildContext context) {
    final actions = const [
      (Icons.add_business_rounded, 'New invoice', AmirColors.primary),
      (Icons.person_add_alt_1_rounded, 'Add customer', AmirColors.secondary),
      (Icons.point_of_sale_rounded, 'Open POS', Color(0xFF8B5CF6)),
      (Icons.local_shipping_rounded, 'Receive stock', AmirColors.warning),
      (Icons.receipt_rounded, 'Record expense', AmirColors.success),
      (Icons.bar_chart_rounded, 'Open report', AmirColors.danger),
    ];
    return Container(
      padding: const EdgeInsets.all(AmirSpacing.lg),
      decoration: BoxDecoration(
        color: AmirColors.card,
        borderRadius: BorderRadius.circular(AmirRadius.lg),
        border: Border.all(color: AmirColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Jump straight into the most-used flows',
              style: TextStyle(fontSize: 12, color: AmirColors.muted.withValues(alpha: 0.85))),
          const SizedBox(height: AmirSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: [
              for (final a in actions)
                InkWell(
                  borderRadius: BorderRadius.circular(AmirRadius.md),
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AmirColors.surface,
                      borderRadius: BorderRadius.circular(AmirRadius.md),
                      border: Border.all(color: AmirColors.stroke),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: a.$3.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(AmirRadius.sm),
                          ),
                          child: Icon(a.$1, size: 15, color: a.$3),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(a.$2,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveStatusBar extends StatefulWidget {
  const _LiveStatusBar();
  @override
  State<_LiveStatusBar> createState() => _LiveStatusBarState();
}

class _LiveStatusBarState extends State<_LiveStatusBar> {
  late final Stream<DateTime> _tick;
  @override
  void initState() {
    super.initState();
    _tick = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AmirColors.card.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AmirRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 11.5,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.85),
          fontFamily: 'monospace',
        ),
        child: Row(
          children: [
            _StatusDot(color: AmirColors.success, label: 'API ONLINE'),
            const SizedBox(width: 16),
            _StatusDot(color: AmirColors.secondary, label: 'DB SYNCED'),
            const SizedBox(width: 16),
            _StatusDot(color: const Color(0xFF8B5CF6), label: 'AI READY'),
            const Spacer(),
            const Icon(Icons.business_outlined, size: 14, color: AmirColors.muted),
            const SizedBox(width: 6),
            const Text('TENANT · DEMO'),
            const SizedBox(width: 16),
            const Icon(Icons.schedule_rounded, size: 14, color: AmirColors.muted),
            const SizedBox(width: 6),
            StreamBuilder<DateTime>(
              stream: _tick,
              builder: (_, snap) {
                final n = snap.data ?? DateTime.now();
                final h = n.hour.toString().padLeft(2, '0');
                final m = n.minute.toString().padLeft(2, '0');
                final s = n.second.toString().padLeft(2, '0');
                return Text('$h:$m:$s');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatefulWidget {
  const _StatusDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5 + 0.4 * _c.value),
                  blurRadius: 4 + 6 * _c.value,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(widget.label),
      ],
    );
  }
}

