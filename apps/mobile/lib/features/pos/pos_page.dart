// Amir ERP — POS terminal (instant UI; offline-friendly).
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/tokens/theme.dart';

class PosProduct {
  PosProduct(this.id, this.name, this.price);
  final String id;
  final String name;
  final double price;
}

final _demoProducts = [
  PosProduct('p1', 'Large Coffee', 4.50),
  PosProduct('p2', 'Medium Coffee', 3.50),
  PosProduct('p3', 'Croissant', 2.75),
  PosProduct('p4', 'Bagel', 2.25),
  PosProduct('p5', 'Water 500ml', 1.00),
  PosProduct('p6', 'Orange Juice', 3.00),
  PosProduct('p7', 'Club Sandwich', 7.50),
  PosProduct('p8', 'Caesar Salad', 8.50),
];

class CartItem {
  CartItem(this.product, this.qty);
  final PosProduct product;
  int qty;
  double get total => product.price * qty;
}

final cartProvider = StateNotifierProvider<CartCtrl, List<CartItem>>((_) => CartCtrl());

class CartCtrl extends StateNotifier<List<CartItem>> {
  CartCtrl() : super([]);
  void add(PosProduct p) {
    final i = state.indexWhere((x) => x.product.id == p.id);
    if (i >= 0) {
      final list = [...state];
      list[i].qty += 1;
      state = list;
    } else {
      state = [...state, CartItem(p, 1)];
    }
  }
  void remove(String id) => state = state.where((x) => x.product.id != id).toList();
  void clear() => state = [];
}

class PosPage extends ConsumerWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final subtotal = cart.fold<double>(0, (a, b) => a + b.total);
    final tax = subtotal * 0.15;
    final total = subtotal + tax;

    return Padding(
      padding: const EdgeInsets.all(AmirSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 1100 ? 4 : 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                for (final p in _demoProducts)
                  InkWell(
                    onTap: () => ref.read(cartProvider.notifier).add(p),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.shopping_basket, size: 36, color: AmirColors.primary),
                            Text(p.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 2),
                            Text('\$${p.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AmirSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Cart', style: Theme.of(context).textTheme.titleLarge),
                    const Divider(),
                    Expanded(
                      child: cart.isEmpty
                          ? const Center(child: Text('Tap a product to add'))
                          : ListView.builder(
                              itemCount: cart.length,
                              itemBuilder: (_, i) {
                                final c = cart[i];
                                return ListTile(
                                  title: Text(c.product.name),
                                  subtitle: Text('${c.qty} × \$${c.product.price.toStringAsFixed(2)}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('\$${c.total.toStringAsFixed(2)}'),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => ref.read(cartProvider.notifier).remove(c.product.id),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(),
                    _kv('Subtotal', subtotal),
                    _kv('Tax (15%)', tax),
                    const SizedBox(height: 4),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: cart.isEmpty
                                ? null
                                : () {
                                    ref.read(cartProvider.notifier).clear();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Order saved (offline-ready). — Amir Saoudi')),
                                    );
                                  },
                            icon: const Icon(Icons.payments_outlined),
                            label: const Text('Charge'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, double v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
          Text('\$${v.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 18 : 14)),
        ],
      ),
    );
  }
}
