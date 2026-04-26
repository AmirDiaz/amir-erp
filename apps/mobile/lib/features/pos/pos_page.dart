// Amir ERP — POS terminal (instant UI; offline-friendly).
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/tokens/theme.dart';

class PosProduct {
  PosProduct(this.id, this.name, this.price, this.icon, this.gradient, this.category);
  final String id;
  final String name;
  final double price;
  final IconData icon;
  final Gradient gradient;
  final String category;
}

final _demoProducts = [
  PosProduct('p1', 'Large Coffee', 4.50, Icons.coffee_rounded, AmirGradients.brand, 'Drinks'),
  PosProduct('p2', 'Medium Coffee', 3.50, Icons.local_cafe_rounded, AmirGradients.brand, 'Drinks'),
  PosProduct('p3', 'Croissant', 2.75, Icons.bakery_dining_rounded, AmirGradients.accent, 'Bakery'),
  PosProduct('p4', 'Bagel', 2.25, Icons.breakfast_dining_rounded, AmirGradients.accent, 'Bakery'),
  PosProduct('p5', 'Water 500ml', 1.00, Icons.water_drop_rounded, AmirGradients.brandSoft, 'Drinks'),
  PosProduct('p6', 'Orange Juice', 3.00, Icons.local_drink_rounded, AmirGradients.success, 'Drinks'),
  PosProduct('p7', 'Club Sandwich', 7.50, Icons.lunch_dining_rounded, AmirGradients.accent, 'Food'),
  PosProduct('p8', 'Caesar Salad', 8.50, Icons.restaurant_rounded, AmirGradients.success, 'Food'),
];

class CartItem {
  const CartItem(this.product, this.qty);
  final PosProduct product;
  final int qty;
  double get total => product.price * qty;
  CartItem copyWith({int? qty}) => CartItem(product, qty ?? this.qty);
}

final cartProvider = StateNotifierProvider<CartCtrl, List<CartItem>>((_) => CartCtrl());

class CartCtrl extends StateNotifier<List<CartItem>> {
  CartCtrl() : super(const []);
  void add(PosProduct p) {
    final i = state.indexWhere((x) => x.product.id == p.id);
    if (i >= 0) {
      final list = [...state];
      list[i] = list[i].copyWith(qty: list[i].qty + 1);
      state = list;
    } else {
      state = [...state, CartItem(p, 1)];
    }
  }
  void inc(String id) {
    final list = [...state];
    final i = list.indexWhere((x) => x.product.id == id);
    if (i >= 0) {
      list[i] = list[i].copyWith(qty: list[i].qty + 1);
      state = list;
    }
  }
  void dec(String id) {
    final list = [...state];
    final i = list.indexWhere((x) => x.product.id == id);
    if (i >= 0) {
      if (list[i].qty <= 1) {
        state = list.where((x) => x.product.id != id).toList();
      } else {
        list[i] = list[i].copyWith(qty: list[i].qty - 1);
        state = list;
      }
    }
  }
  void remove(String id) => state = state.where((x) => x.product.id != id).toList();
  void clear() => state = const [];
}

class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});
  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

class _PosPageState extends ConsumerState<PosPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final subtotal = cart.fold<double>(0, (a, b) => a + b.total);
    final tax = subtotal * 0.15;
    final total = subtotal + tax;

    final categories = ['All', 'Drinks', 'Food', 'Bakery'];
    final products = _filter == 'All'
        ? _demoProducts
        : _demoProducts.where((p) => p.category == _filter).toList();

    return Padding(
      padding: const EdgeInsets.all(AmirSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Point of Sale',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AmirColors.success.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AmirRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(color: AmirColors.success, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text('Online',
                              style: TextStyle(color: AmirColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final c in categories)
                      InkWell(
                        borderRadius: BorderRadius.circular(AmirRadius.pill),
                        onTap: () => setState(() => _filter = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: c == _filter ? AmirGradients.brand : null,
                            color: c == _filter ? null : AmirColors.surface,
                            borderRadius: BorderRadius.circular(AmirRadius.pill),
                            border: Border.all(color: c == _filter ? Colors.transparent : AmirColors.stroke),
                          ),
                          child: Text(c,
                              style: TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w700,
                                color: c == _filter ? Colors.white : AmirColors.muted,
                              )),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 1400 ? 4 : 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                    children: [
                      for (final p in products) _ProductTile(product: p),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AmirSpacing.lg),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(AmirSpacing.lg),
              decoration: BoxDecoration(
                color: AmirColors.card,
                borderRadius: BorderRadius.circular(AmirRadius.lg),
                border: Border.all(color: AmirColors.stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text('Current Order',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AmirColors.surface,
                          borderRadius: BorderRadius.circular(AmirRadius.pill),
                          border: Border.all(color: AmirColors.stroke),
                        ),
                        child: Text('${cart.length} item${cart.length == 1 ? '' : 's'}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: cart.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 56, color: AmirColors.muted.withValues(alpha: 0.5)),
                                const SizedBox(height: 12),
                                Text('Cart is empty',
                                    style: TextStyle(color: AmirColors.muted.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('Tap a product to add it',
                                    style: TextStyle(color: AmirColors.muted.withValues(alpha: 0.6), fontSize: 12)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: cart.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final c = cart[i];
                              return _CartLine(item: c, ref: ref);
                            },
                          ),
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: AmirColors.stroke),
                  const SizedBox(height: 12),
                  _kv('Subtotal', subtotal),
                  _kv('Tax (15%)', tax),
                  const SizedBox(height: 6),
                  _kv('Total', total, bold: true),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: cart.isEmpty ? null : () => ref.read(cartProvider.notifier).clear(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _ChargeButton(
                          enabled: cart.isNotEmpty,
                          total: total,
                          onTap: () {
                            ref.read(cartProvider.notifier).clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order saved (offline-ready). — Amir Saoudi')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, double v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                fontSize: bold ? 16 : 13,
                color: bold ? Colors.white : AmirColors.muted.withValues(alpha: 0.95),
              )),
          Text('\$${v.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
                fontSize: bold ? 22 : 13,
                letterSpacing: bold ? -0.5 : 0,
              )),
        ],
      ),
    );
  }
}

class _ProductTile extends ConsumerStatefulWidget {
  const _ProductTile({required this.product});
  final PosProduct product;
  @override
  ConsumerState<_ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends ConsumerState<_ProductTile> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _hover ? -4.0 : 0.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(AmirRadius.lg),
          onTap: () => ref.read(cartProvider.notifier).add(p),
          child: Container(
            padding: const EdgeInsets.all(AmirSpacing.md),
            decoration: BoxDecoration(
              color: AmirColors.card,
              borderRadius: BorderRadius.circular(AmirRadius.lg),
              border: Border.all(color: _hover ? AmirColors.primary.withValues(alpha: 0.6) : AmirColors.stroke),
              boxShadow: _hover
                  ? [
                      BoxShadow(
                        color: AmirColors.primary.withValues(alpha: 0.25),
                        blurRadius: 24, spreadRadius: -6, offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: p.gradient,
                    borderRadius: BorderRadius.circular(AmirRadius.md),
                  ),
                  child: Icon(p.icon, color: Colors.white, size: 22),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.2,
                          color: AmirColors.muted.withValues(alpha: 0.8),
                        )),
                    const SizedBox(height: 4),
                    Text(p.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.2),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('\$${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.item, required this.ref});
  final CartItem item;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AmirColors.surface,
        borderRadius: BorderRadius.circular(AmirRadius.md),
        border: Border.all(color: AmirColors.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: item.product.gradient,
              borderRadius: BorderRadius.circular(AmirRadius.sm),
            ),
            child: Icon(item.product.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('\$${item.product.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 11.5, color: AmirColors.muted.withValues(alpha: 0.85))),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AmirColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AmirRadius.pill),
            ),
            child: Row(
              children: [
                _qBtn(Icons.remove_rounded, () => ref.read(cartProvider.notifier).dec(item.product.id)),
                SizedBox(
                  width: 24,
                  child: Text('${item.qty}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                ),
                _qBtn(Icons.add_rounded, () => ref.read(cartProvider.notifier).inc(item.product.id)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('\$${item.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _qBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AmirRadius.pill),
      child: Container(
        width: 26, height: 26,
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: AmirColors.muted),
      ),
    );
  }
}

class _ChargeButton extends StatelessWidget {
  const _ChargeButton({required this.enabled, required this.total, required this.onTap});
  final bool enabled;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AmirRadius.md),
      child: Ink(
        decoration: BoxDecoration(
          gradient: enabled ? AmirGradients.brand : null,
          color: enabled ? null : AmirColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AmirRadius.md),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AmirColors.primary.withValues(alpha: 0.45),
                    blurRadius: 18, spreadRadius: -4, offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(enabled ? 'Charge \$${total.toStringAsFixed(2)}' : 'Charge',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
