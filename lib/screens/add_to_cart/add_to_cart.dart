import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/cart_item.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/model/name_color.dart';
import 'package:trentify/model/promo.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/screens/add_to_cart/edit_cart_item_sheet_widget.dart';
import 'package:trentify/screens/add_to_cart/promo/promo_picker.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/pressable_scale.dart';

export 'package:trentify/model/cart_item.dart';

class AddToCartPage extends StatefulWidget {
  const AddToCartPage({super.key});

  @override
  State<AddToCartPage> createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  String? _appliedPromoCode;
  double _promoDiscount = 0.0;

  void _openPromoPicker() async {
    HapticFeedback.lightImpact();
    final selectedTotal = context.read<CartProvider>().selectedTotal;
    final promo = await Navigator.of(context).push<Promo?>(
      CupertinoPageRoute(
        builder: (_) => PromoPickerPage(
          promos: [
            Promo(
              id: 'p1',
              title: 'Luxury VIP Deal: 20% OFF',
              code: 'LUXURY20',
              type: PromoType.percent,
              value: 20,
              minSpend: 100,
              validUntil: DateTime.now().add(const Duration(days: 14)),
            ),
            Promo(
              id: 'p2',
              title: 'Welcome First Order',
              code: 'WELCOME30',
              type: PromoType.flat,
              value: 30,
              minSpend: 150,
              validUntil: DateTime.now().add(const Duration(days: 30)),
            ),
          ],
          subtotal: selectedTotal,
          initialSelectedId: _appliedPromoCode,
        ),
      ),
    );

    if (promo != null && mounted) {
      final currentSubtotal = context.read<CartProvider>().selectedTotal;
      final discount = promo.type == PromoType.percent
          ? (currentSubtotal * (promo.value / 100.0))
          : promo.value;
      setState(() {
        _appliedPromoCode = promo.code;
        _promoDiscount = discount;
      });
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Voucher "${promo.code}" applied successfully!'),
        ),
      );
    }
  }

  void _showEditVariantModal(CartItem item) async {
    HapticFeedback.lightImpact();
    final updatedItem = await showModalBottomSheet<CartItem?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EditCartItemSheet(
        item: item,
        availableSizes: const ['S', 'M', 'L', 'XL', 'XXL'],
        availableColors: const [
          NamedColor('Black', Color(0xFF111214)),
          NamedColor('White', Color(0xFFFFFFFF)),
          NamedColor('Red', Color(0xFFE74B3C)),
          NamedColor('Purple', Color(0xFF8E39C1)),
        ],
        initial: FilterResult.initial().copyWith(
          colorName: item.colorName,
          sizes: {item.size},
        ),
      ),
    );

    if (!mounted) return;
    if (updatedItem != null) {
      context.read<CartProvider>().updateVariant(
            item.id,
            newSize: updatedItem.size,
            newColorName: updatedItem.colorName,
            newColor: updatedItem.color,
          );
    }
  }

  void _showClearConfirmDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(context.tr('clear')),
        content: Text(
          isDark
              ? 'Are you sure you want to remove all items from your bag?'
              : 'Are you sure you want to remove all items from your bag?',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CartProvider>().clearCart();
            },
            child: Text(context.tr('clear')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    final selectedCount = cart.selectedCount;
    final selectedTotal = cart.selectedTotal;
    final isAllSelected = cart.isAllSelected;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    const double freeShippingThreshold = 300.0;
    final bool hasFreeShipping = selectedTotal >= freeShippingThreshold;
    final double shippingProgress = (selectedTotal / freeShippingThreshold).clamp(0.0, 1.0);
    final double amountNeededForFreeShipping =
        (freeShippingThreshold - selectedTotal).clamp(0.0, freeShippingThreshold);

    final finalTotal = (selectedTotal - _promoDiscount).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          '${context.tr('shopping_bag')} (${cart.totalCount})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(CupertinoIcons.back, color: textPrimary),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        actions: [
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () => _showClearConfirmDialog(context),
                child: Text(
                  context.tr('clear'),
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? _EmptyCartState(isDark: isDark, primaryColor: primaryColor)
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // VIP Free Shipping Progress Bar Card
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 60),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  primaryColor.withValues(alpha: 0.2),
                                  const Color(0xFF161B22),
                                ]
                              : [
                                  primaryColor.withValues(alpha: 0.1),
                                  Colors.white,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                hasFreeShipping
                                    ? CupertinoIcons.checkmark_seal_fill
                                    : CupertinoIcons.airplane,
                                size: 16,
                                color: hasFreeShipping ? const Color(0xFF10B981) : primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hasFreeShipping
                                      ? context.tr('free_shipping_unlocked')
                                      : 'Add \$${amountNeededForFreeShipping.toStringAsFixed(2)} more for Free VIP Delivery',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: shippingProgress,
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? const Color(0xFF30363D)
                                  : const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                hasFreeShipping ? const Color(0xFF10B981) : primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Select All Header Strip
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              cart.toggleSelectAll(!isAllSelected);
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: isAllSelected ? primaryColor : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isAllSelected ? primaryColor : borderColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isAllSelected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 15,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${context.tr('select_all')} (${cart.totalCount})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${context.tr('selected_items')}: $selectedCount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Cart Items List
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return AnimatedEntry(
                      delay: Duration(milliseconds: 120 + (index * 40)),
                      child: _CartItemCard(
                        item: item,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onToggleSelect: () => cart.toggleSelection(item.id),
                        onIncrement: () => cart.updateQty(item.id, 1),
                        onDecrement: () => cart.updateQty(item.id, -1),
                        onDelete: () => cart.removeItem(item.id),
                        onEditVariant: () => _showEditVariantModal(item),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Promo Voucher Bar
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 240),
                    child: PressableScale(
                      onTap: _openPromoPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _appliedPromoCode != null
                                ? const Color(0xFF10B981)
                                : borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: (_appliedPromoCode != null
                                        ? const Color(0xFF10B981)
                                        : primaryColor)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                CupertinoIcons.tag_fill,
                                size: 18,
                                color: _appliedPromoCode != null
                                    ? const Color(0xFF10B981)
                                    : primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _appliedPromoCode != null
                                        ? 'Voucher Applied: $_appliedPromoCode'
                                        : context.tr('apply_voucher'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _appliedPromoCode != null
                                          ? const Color(0xFF10B981)
                                          : textPrimary,
                                    ),
                                  ),
                                  if (_appliedPromoCode != null)
                                    Text(
                                      'Saved \$${_promoDiscount.toStringAsFixed(2)} on this order',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              CupertinoIcons.chevron_forward,
                              size: 14,
                              color: textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Order Summary Breakdown Card
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 280),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('order_summary_title'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _SummaryRow(
                            label: '${context.tr('items_subtotal')} ($selectedCount)',
                            value: '\$${selectedTotal.toStringAsFixed(2)}',
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                          const SizedBox(height: 10),
                          _SummaryRow(
                            label: context.tr('estimated_shipping'),
                            value: hasFreeShipping ? context.tr('free') : '\$15.00',
                            isGreen: hasFreeShipping,
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                          if (_promoDiscount > 0) ...[
                            const SizedBox(height: 10),
                            _SummaryRow(
                              label: context.tr('discount'),
                              value: '-\$${_promoDiscount.toStringAsFixed(2)}',
                              isGreen: true,
                              textSecondary: textSecondary,
                              textPrimary: textPrimary,
                            ),
                          ],
                          const SizedBox(height: 14),
                          Divider(color: borderColor, height: 1),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('total'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                '\$${finalTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                  color: primaryColor,
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
            ),

      // Fixed Frosted Bottom Checkout Bar
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF161B22).withValues(alpha: 0.96)
                      : Colors.white.withValues(alpha: 0.96),
                  border: Border(top: BorderSide(color: borderColor, width: 1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Subtotal Column
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${context.tr('total')} ($selectedCount)',
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${finalTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    // Checkout CTA Button
                    Expanded(
                      child: PressableScale(
                        onTap: selectedCount == 0
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                final selectedItems =
                                    items.where((e) => e.selected).toList();

                                context.push(
                                  AppRoutes.checkout,
                                  extra: selectedItems,
                                );
                              },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: selectedCount == 0
                                ? null
                                : LinearGradient(
                                    colors: [
                                      primaryColor,
                                      primaryColor.withValues(alpha: 0.88),
                                    ],
                                  ),
                            color: selectedCount == 0
                                ? (isDark
                                    ? const Color(0xFF21262D)
                                    : const Color(0xFFE2E8F0))
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: selectedCount == 0
                                ? null
                                : [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.tr('proceed_checkout'),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: selectedCount == 0
                                      ? textSecondary
                                      : Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                CupertinoIcons.arrow_right,
                                size: 16,
                                color: selectedCount == 0
                                    ? textSecondary
                                    : Colors.white,
                              ),
                            ],
                          ),
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

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool isDark;
  final Color primaryColor;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onToggleSelect;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
  final VoidCallback onEditVariant;

  const _CartItemCard({
    required this.item,
    required this.isDark,
    required this.primaryColor,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onToggleSelect,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    required this.onEditVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Selection Checkbox
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggleSelect();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: item.selected ? primaryColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.selected ? primaryColor : borderColor,
                  width: 1.5,
                ),
              ),
              child: item.selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // High-Res Product Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.imageUrl,
              width: 80,
              height: 88,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 80,
                height: 88,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF21262D) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(CupertinoIcons.photo, color: textSecondary),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Product Details & Stepper
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onDelete();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          CupertinoIcons.trash,
                          size: 16,
                          color: textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Interactive Variant Chip (Tap to Change Size/Color)
                GestureDetector(
                  onTap: onEditVariant,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 0.5),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${item.size} • ${item.colorName}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.chevron_down,
                          size: 9,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Price & Stepper Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: primaryColor,
                      ),
                    ),

                    // Modern Stepper
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onDecrement();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Icon(
                                CupertinoIcons.minus,
                                size: 12,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '${item.qty}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onIncrement();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Icon(
                                CupertinoIcons.plus,
                                size: 12,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isGreen;
  final Color textSecondary;
  final Color textPrimary;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isGreen = false,
    required this.textSecondary,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isGreen ? const Color(0xFF10B981) : textPrimary,
          ),
        ),
      ],
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  final bool isDark;
  final Color primaryColor;

  const _EmptyCartState({required this.isDark, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.bag,
                size: 42,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('empty_cart'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('empty_cart_sub'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            PressableScale(
              onTap: () => context.go(AppRoutes.home),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.sparkles, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('start_shopping'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
