import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/model/name_color.dart';
import 'package:trentify/screens/add_to_cart/edit_cart_item_sheet_widget.dart';

class CartItem {
  final String id;
  final String title;
  final String imageUrl;
  final String size;
  final String colorName;
  final Color color;
  final double price;
  int qty;
  bool selected;
  int stock;

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.size,
    required this.colorName,
    required this.color,
    required this.price,
    this.qty = 1,
    this.selected = true,
    this.stock = 10,
  });
}

class AddToCartPage extends StatefulWidget {
  const AddToCartPage({super.key});

  @override
  State<AddToCartPage> createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  final List<CartItem> _items = [
    CartItem(
      id: '1',
      title: 'Urban Blend Long Sleeve Shirt',
      imageUrl:
          'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=800&auto=format&fit=crop',
      size: 'L',
      colorName: 'Black',
      color: Colors.black,
      price: 185,
      qty: 1,
      selected: true,
    ),
    CartItem(
      id: '2',
      title: 'Street Style Comfort Tee',
      imageUrl:
          'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=800&auto=format&fit=crop',
      size: 'L',
      colorName: 'Black',
      color: Colors.black,
      price: 155,
      qty: 1,
      selected: true,
    ),
    CartItem(
      id: '3',
      title: 'Elite Style Modal Elegance',
      imageUrl:
          'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=800&auto=format&fit=crop',
      size: 'L',
      colorName: 'Black',
      color: Colors.black,
      price: 190,
      qty: 1,
      selected: true,
    ),
  ];

  int get _selectedCount =>
      _items.where((e) => e.selected).fold<int>(0, (a, e) => a + e.qty);
  double get _selectedTotal => _items
      .where((e) => e.selected)
      .fold<double>(0, (a, e) => a + e.price * e.qty);

  void _toggleItem(String id) {
    setState(() {
      final i = _items.indexWhere((e) => e.id == id);
      if (i != -1) _items[i].selected = !_items[i].selected;
    });
  }

  void _removeItem(String id) {
    setState(() => _items.removeWhere((e) => e.id == id));
  }

  void _incQty(String id) {
    setState(() {
      final i = _items.indexWhere((e) => e.id == id);
      if (i != -1) _items[i].qty += 1;
    });
  }

  void _decQty(String id) {
    setState(() {
      final i = _items.indexWhere((e) => e.id == id);
      if (i != -1 && _items[i].qty > 1) _items[i].qty -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${_items.length})'),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) {
          final item = _items[i];

          final card = Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image + checkbox
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.imageUrl,
                        width: 96,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: InkWell(
                        onTap: () => _toggleItem(item.id),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: item.selected ? cs.primary : cs.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: item.selected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title + actions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              final updated =
                                  await showBarModalBottomSheet<CartItem>(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (ctx) => EditCartItemSheet(
                                      initial: FilterResult.initial(),
                                      item: item,
                                      // supply available options however you like:
                                      availableSizes: const [
                                        'XS',
                                        'S',
                                        'M',
                                        'L',
                                        'XL',
                                      ],
                                      availableColors: const [
                                        NamedColor('Black', Colors.black),
                                        NamedColor('White', Colors.white),
                                        NamedColor('Brown', Color(0xFF8B5E3C)),
                                        NamedColor(
                                          'Blue Grey',
                                          Color(0xFF607D8B),
                                        ),
                                        NamedColor('Indigo', Color(0xFF3F51B5)),
                                        NamedColor(
                                          'Deep Purple',
                                          Color(0xFF673AB7),
                                        ),
                                      ],
                                    ),
                                  );

                              if (updated != null) {
                                setState(() {
                                  final i = _items.indexWhere(
                                    (e) => e.id == updated.id,
                                  );
                                  if (i != -1) _items[i] = updated;
                                });
                              }
                            },
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _removeItem(item.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Size: ${item.size}', style: text.bodyMedium),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Color: ${item.colorName}',
                            style: text.bodyMedium,
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: cs.outlineVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text('Qty: ', style: text.bodyMedium),
                          _QtyStepper(
                            value: item.qty,
                            onDecrement: () => _decQty(item.id),
                            onIncrement: () => _incQty(item.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(
                            0xFF528F65,
                          ), // green like screenshot
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          // Ensure ripple+rounded corner works everywhere
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: card,
          );
        },
      ),

      // sticky checkout bar
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _selectedCount == 0
                      ? null
                      : () {
                          // TODO: route to checkout (go_router example):
                          // context.pushNamed('checkout');
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Checkout (${_selectedCount}) - \$${_selectedTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  const _QtyStepper({
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: 6),
      decoration: ShapeDecoration(
        color: cs.surfaceContainerHighest,
        shape: const StadiumBorder(),
      ),
      child: Row(
        children: [
          _RoundIconButton(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          _RoundIconButton(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(Icons.remove, size: 18),
        ).withIcon(icon),
      ),
    );
  }
}

// tiny extension to reuse _RoundIconButton for add/remove
extension on Widget {
  Widget withIcon(IconData icon) {
    return Stack(
      alignment: Alignment.center,
      children: [this, Icon(icon, size: 18)],
    );
  }
}
