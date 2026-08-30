import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/seller_product.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _seller = SellerProvider.instance;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: All, 1: Low Stock (<=5), 2: Out of Stock (0)

  @override
  void initState() {
    super.initState();
    _seller.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _seller.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  List<SellerProduct> get _filteredProducts {
    return _seller.products.where((p) {
      if (_searchQuery.isNotEmpty &&
          !p.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      switch (_selectedFilter) {
        case 1:
          return p.isLowStock;
        case 2:
          return p.isOutOfStock;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    final products = _filteredProducts;
    final totalUnits = _seller.products.fold(0, (sum, p) => sum + p.stock);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(context.tr('stock_inventory')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Inventory KPI Cards
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: _kpiPill(
                      context.tr('total_units'),
                      '$totalUnits',
                      primaryColor,
                      cardBg,
                      borderColor,
                      textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _kpiPill(
                      context.tr('low_stock_skus'),
                      '${_seller.lowStockCount}',
                      const Color(0xFFF59E0B),
                      cardBg,
                      borderColor,
                      textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _kpiPill(
                      context.tr('out_of_stock_skus'),
                      '${_seller.outOfStockCount}',
                      const Color(0xFFEF4444),
                      cardBg,
                      borderColor,
                      textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: CupertinoSearchTextField(
                placeholder: context.tr('search_skus'),
                style: TextStyle(color: textPrimary),
                placeholderStyle: TextStyle(color: textSecondary, fontSize: 14),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),

            const SizedBox(height: 8),

            // Filter Tabs
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _filterChip('${context.tr('filter_all')} (${_seller.products.length})', 0, primaryColor, cardBg, borderColor, textSecondary),
                  const SizedBox(width: 8),
                  _filterChip(context.tr('filter_low_stock'), 1, primaryColor, cardBg, borderColor, textSecondary),
                  const SizedBox(width: 8),
                  _filterChip(context.tr('out_of_stock_skus'), 2, primaryColor, cardBg, borderColor, textSecondary),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Inventory List
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text(
                        'No inventory matches filter',
                        style: TextStyle(fontSize: 14, color: textSecondary),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return AnimatedEntry(
                          delay: Duration(milliseconds: index * 25),
                          child: _InventoryRowCard(
                            product: product,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            primaryColor: primaryColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onAdjustStock: (delta) {
                              HapticFeedback.lightImpact();
                              _seller.updateStock(product.id, delta);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiPill(
    String label,
    String value,
    Color accentColor,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    String label,
    int index,
    Color primaryColor,
    Color cardBg,
    Color borderColor,
    Color textSecondary,
  ) {
    final isSel = _selectedFilter == index;
    return PressableScale(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? primaryColor : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSel ? primaryColor : borderColor),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSel ? Colors.white : textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _InventoryRowCard extends StatelessWidget {
  final SellerProduct product;
  final Color cardBg;
  final Color borderColor;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;
  final Function(int delta) onAdjustStock;

  const _InventoryRowCard({
    required this.product,
    required this.cardBg,
    required this.borderColor,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onAdjustStock,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = product.isLowStock;
    final isOut = product.isOutOfStock;

    final badgeColor = isOut
        ? const Color(0xFFEF4444)
        : (isLow ? const Color(0xFFF59E0B) : const Color(0xFF10B981));

    final badgeLabel = isOut
        ? 'OUT OF STOCK'
        : (isLow ? 'LOW STOCK (${product.stock})' : 'IN STOCK (${product.stock})');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOut ? const Color(0xFFEF4444).withValues(alpha: 0.5) : borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.images.first,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sizes: ${product.sizes.join(", ")} • \$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),

          // Stock Steppers
          Column(
            children: [
              Text(
                '${product.stock}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: badgeColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _stepperBtn(
                    icon: CupertinoIcons.minus,
                    onTap: () => onAdjustStock(-1),
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                  ),
                  const SizedBox(width: 6),
                  _stepperBtn(
                    icon: CupertinoIcons.plus,
                    onTap: () => onAdjustStock(1),
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepperBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color borderColor,
    required Color textPrimary,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Icon(icon, size: 14, color: textPrimary),
        ),
      ),
    );
  }
}
