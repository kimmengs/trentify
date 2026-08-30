import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/seller_product.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class SellerProductListPage extends StatefulWidget {
  const SellerProductListPage({super.key});

  @override
  State<SellerProductListPage> createState() => _SellerProductListPageState();
}

class _SellerProductListPageState extends State<SellerProductListPage> {
  final _seller = SellerProvider.instance;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: All, 1: Active, 2: Draft, 3: Low Stock

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
          !p.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !p.category.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      switch (_selectedFilter) {
        case 1:
          return p.status == SellerProductStatus.active;
        case 2:
          return p.status == SellerProductStatus.draft;
        case 3:
          return p.isLowStock || p.isOutOfStock;
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

    final filters = [
      context.tr('filter_all'),
      context.tr('filter_active'),
      context.tr('filter_drafts'),
      context.tr('filter_low_stock'),
    ];

    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(context.tr('product_catalog')),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.sellerNewProduct),
            icon: Icon(CupertinoIcons.plus_circle_fill, color: primaryColor, size: 26),
            tooltip: context.tr('add_product'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: CupertinoSearchTextField(
                placeholder: context.tr('search_seller_products'),
                style: TextStyle(color: textPrimary),
                placeholderStyle: TextStyle(color: textSecondary, fontSize: 14),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),

            // Horizontal Filter Tabs
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return PressableScale(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primaryColor : borderColor,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filters[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Product List View
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.cube_box, size: 48, color: textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to add your first store listing.',
                            style: TextStyle(fontSize: 13, color: textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return AnimatedEntry(
                          delay: Duration(milliseconds: index * 30),
                          child: _ProductItemCard(
                            product: product,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            primaryColor: primaryColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onToggleStatus: () {
                              HapticFeedback.lightImpact();
                              _seller.toggleProductStatus(product.id);
                            },
                            onDelete: () => _confirmDelete(product),
                            onEdit: () {
                              context.push(
                                '/seller/products/edit/${product.id}',
                                extra: product,
                              );
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

  void _confirmDelete(SellerProduct product) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.title}"? This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(ctx);
              _seller.deleteProduct(product.id);
            },
          ),
        ],
      ),
    );
  }
}

class _ProductItemCard extends StatelessWidget {
  final SellerProduct product;
  final Color cardBg;
  final Color borderColor;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ProductItemCard({
    required this.product,
    required this.cardBg,
    required this.borderColor,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = product.status == SellerProductStatus.active;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  product.images.first,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                : const Color(0xFF64748B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive ? const Color(0xFF10B981) : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isActive ? 'Active' : 'Draft',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isActive ? const Color(0xFF10B981) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Stock: ${product.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: product.stock <= 5
                                ? const Color(0xFFEF4444)
                                : textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 8),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Toggle Active/Draft
              GestureDetector(
                onTap: onToggleStatus,
                child: Row(
                  children: [
                    Icon(
                      isActive ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                      size: 14,
                      color: textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isActive ? 'Switch to Draft' : 'Publish',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  PressableScale(
                    onTap: onEdit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.pencil, size: 14, color: primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PressableScale(
                    onTap: onDelete,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.trash, size: 14, color: Color(0xFFEF4444)),
                          SizedBox(width: 4),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
