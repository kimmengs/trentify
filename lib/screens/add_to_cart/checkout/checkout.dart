import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/address.dart';
import 'package:trentify/model/cart_item.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/model/payment_method.dart';
import 'package:trentify/model/promo.dart';
import 'package:trentify/provider/address_provider.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/order_provider.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/screens/add_to_cart/address_picker/address_picker.dart';
import 'package:trentify/screens/add_to_cart/payment_picker/payment_picker.dart';
import 'package:trentify/screens/add_to_cart/promo/promo_picker.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/app_badge_pill.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/app_network_image.dart';
import 'package:trentify/widgets/app_price_text.dart';
import 'package:trentify/widgets/app_step_indicator.dart';
import 'package:trentify/widgets/liquid_glass_card.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.items,
    this.addresses = const [],
    this.initialAddress,
  });

  final List<CartItem> items;
  final List<Address> addresses;
  final Address? initialAddress;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Address? _selectedAddress;
  PaymentMethod? _selectedPayment;
  Promo? _selectedPromo;
  int _selectedShippingSpeed = 0; // 0: Express VIP (Free), 1: Standard

  @override
  void initState() {
    super.initState();
    final addrProvider = AddressProvider.instance;
    _selectedAddress = widget.initialAddress ??
        (widget.addresses.isNotEmpty
            ? widget.addresses.first
            : addrProvider.selectedAddress);

    if (DemoDb.demoMethods.isNotEmpty) {
      _selectedPayment = DemoDb.demoMethods.first;
    }
  }

  double get _subtotal => widget.items.fold<double>(
        0.0,
        (sum, item) => sum + (item.price * item.qty),
      );

  double get _shippingFee {
    if (_selectedShippingSpeed == 0) {
      return _subtotal >= 300.0 ? 0.0 : 8.50;
    }
    return 0.0;
  }

  double get _promoDiscountValue {
    if (_selectedPromo == null) return 0.0;
    if (_subtotal < _selectedPromo!.minSpend) return 0.0;
    switch (_selectedPromo!.type) {
      case PromoType.percent:
      case PromoType.cashback:
        return _subtotal * (_selectedPromo!.value / 100.0);
      case PromoType.flat:
        return _selectedPromo!.value;
    }
  }

  double get _estimatedTax => 3.50;

  double get _totalPayment =>
      (_subtotal + _shippingFee + _estimatedTax - _promoDiscountValue)
          .clamp(0.0, double.infinity);

  void _openAddressPicker() async {
    AppHaptics.light();
    final picked = await Navigator.of(context).push<Address?>(
      CupertinoPageRoute(
        builder: (_) => AddressPickerPage(
          initialSelectedId: _selectedAddress?.id ?? AddressProvider.instance.selectedAddressId,
          isPickerMode: true,
        ),
      ),
    );

    if (picked != null && mounted) {
      setState(() => _selectedAddress = picked);
    }
  }

  void _openPaymentPicker() async {
    AppHaptics.light();
    final picked = await Navigator.of(context).push<PaymentMethod?>(
      CupertinoPageRoute(
        builder: (_) => PaymentPickerPage(
          methods: DemoDb.demoMethods,
          initialSelectedId: _selectedPayment?.id,
        ),
      ),
    );

    if (picked != null && mounted) {
      setState(() => _selectedPayment = picked);
    }
  }

  void _openPromoPicker() async {
    AppHaptics.light();
    final picked = await Navigator.of(context).push<Promo?>(
      CupertinoPageRoute(
        builder: (_) => PromoPickerPage(
          promos: DemoDb.demoPromos,
          subtotal: _subtotal,
          initialSelectedId: _selectedPromo?.id,
        ),
      ),
    );

    if (picked != null && mounted) {
      setState(() => _selectedPromo = picked);
    }
  }

  void _handlePlaceOrder() async {
    AppHaptics.heavy();

    // Show processing modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ModernProcessingDialog(),
    );

    // Create live order in OrderProvider
    OrderProvider.instance.createOrderFromCart(
      items: widget.items,
      total: _totalPayment,
      address: _selectedAddress?.line1,
      paymentMethod: _selectedPayment?.name,
    );

    // Remove purchased items from Cart
    for (final item in widget.items) {
      CartProvider.instance.removeItem(item.id);
    }

    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss loading

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModernSuccessDialog(
        orderTotal: _totalPayment,
        onViewOrder: () {
          Navigator.of(context, rootNavigator: true).pop();
          context.go(AppRoutes.home, extra: {'tabIndex': 3});
        },
        onBackHome: () {
          Navigator.of(context, rootNavigator: true).pop();
          context.go(AppRoutes.home, extra: {'tabIndex': 0});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('checkout'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const AppBadgePill(
              label: 'SSL 256',
              icon: CupertinoIcons.lock_fill,
              variant: BadgeVariant.success,
              fontSize: 9,
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 140),
        children: [
          // Step Progress Indicator
          AnimatedEntry(
            delay: const Duration(milliseconds: 40),
            child: LiquidGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: 18,
              child: const AppStepIndicator(
                currentStepIndex: 1,
                steps: [
                  StepItem(number: '1', title: 'Bag'),
                  StepItem(number: '2', title: 'Checkout'),
                  StepItem(number: '3', title: 'Delivery'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 1. Delivery Address Card
          AnimatedEntry(
            delay: const Duration(milliseconds: 80),
            child: LiquidGlassCard(
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              CupertinoIcons.location_solid,
                              size: 16,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            context.tr('shipping_address'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                      PressableScale(
                        onTap: _openAddressPicker,
                        child: AppBadgePill(
                          label: context.tr('edit'),
                          variant: BadgeVariant.primary,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedAddress != null) ...[
                    Row(
                      children: [
                        AppBadgePill(
                          label: _selectedAddress!.label,
                          variant: BadgeVariant.neutral,
                          fontSize: 11,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedAddress!.fullName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedAddress!.phone,
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedAddress!.line1,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ] else
                    TextButton.icon(
                      onPressed: _openAddressPicker,
                      icon: const Icon(CupertinoIcons.plus_circle, size: 16),
                      label: const Text('Add Delivery Address'),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 2. Order Items Review Summary Card
          AnimatedEntry(
            delay: const Duration(milliseconds: 120),
            child: LiquidGlassCard(
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              CupertinoIcons.bag_fill,
                              size: 16,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Order Items (${widget.items.length})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${widget.items.fold<int>(0, (a, b) => a + b.qty)} items',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == widget.items.length - 1 ? 0 : 10),
                      child: Row(
                        children: [
                          AppNetworkImage(
                            imageUrl: item.imageUrl,
                            width: 54,
                            height: 60,
                            borderRadius: 12,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    AppBadgePill(
                                      label: 'Size: ${item.size} • ${item.colorName}',
                                      variant: BadgeVariant.neutral,
                                      fontSize: 10,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'x${item.qty}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          AppPriceText(
                            price: item.price * item.qty,
                            fontSize: 14,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 3. Shipping Courier Option
          AnimatedEntry(
            delay: const Duration(milliseconds: 160),
            child: LiquidGlassCard(
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CupertinoIcons.airplane,
                          size: 16,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Delivery Courier Speed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => setState(() => _selectedShippingSpeed = 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedShippingSpeed == 0
                            ? primaryColor.withValues(alpha: isDark ? 0.15 : 0.08)
                            : (isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedShippingSpeed == 0 ? primaryColor : borderColor,
                          width: _selectedShippingSpeed == 0 ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedShippingSpeed == 0
                                ? CupertinoIcons.checkmark_circle_fill
                                : CupertinoIcons.circle,
                            color: _selectedShippingSpeed == 0 ? primaryColor : textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DHL Express VIP Priority Air (1-2 Days)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _subtotal >= 300
                                      ? 'Free VIP shipping unlocked'
                                      : 'Estimated arrival: Tomorrow by 2:00 PM',
                                  style: TextStyle(fontSize: 11, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _subtotal >= 300 ? 'FREE' : '\$8.50',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _subtotal >= 300 ? const Color(0xFF10B981) : primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 4. Payment Method Card
          AnimatedEntry(
            delay: const Duration(milliseconds: 200),
            child: LiquidGlassCard(
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              CupertinoIcons.creditcard_fill,
                              size: 16,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            context.tr('payment_method'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                      PressableScale(
                        onTap: _openPaymentPicker,
                        child: AppBadgePill(
                          label: context.tr('edit'),
                          variant: BadgeVariant.primary,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedPayment != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161B22) : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor),
                            ),
                            child: Icon(
                              _selectedPayment!.kind == PaymentKind.wallet
                                  ? CupertinoIcons.device_phone_portrait
                                  : CupertinoIcons.creditcard,
                              size: 18,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedPayment!.brand ?? _selectedPayment!.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedPayment!.kind == PaymentKind.wallet
                                      ? 'Instant 1-Touch Apple Pay'
                                      : '•••• •••• •••• ${_selectedPayment!.last4 ?? '4242'}',
                                  style: TextStyle(fontSize: 11, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            size: 18,
                            color: Color(0xFF10B981),
                          ),
                        ],
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: _openPaymentPicker,
                      icon: const Icon(CupertinoIcons.plus_circle, size: 16),
                      label: const Text('Choose Payment Method'),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 5. Promo Voucher Card
          AnimatedEntry(
            delay: const Duration(milliseconds: 240),
            child: LiquidGlassCard(
              borderRadius: 20,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (_selectedPromo != null ? const Color(0xFF10B981) : primaryColor)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      CupertinoIcons.tag_fill,
                      size: 16,
                      color: _selectedPromo != null ? const Color(0xFF10B981) : primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPromo != null
                              ? 'Voucher: ${_selectedPromo!.code}'
                              : context.tr('apply_voucher'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _selectedPromo != null ? const Color(0xFF10B981) : textPrimary,
                          ),
                        ),
                        if (_selectedPromo != null)
                          Text(
                            'Saving \$${_promoDiscountValue.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 11, color: textSecondary),
                          ),
                      ],
                    ),
                  ),
                  if (_selectedPromo != null)
                    IconButton(
                      icon: const Icon(CupertinoIcons.clear_circled_solid, size: 18, color: Color(0xFFEF4444)),
                      onPressed: () => setState(() => _selectedPromo = null),
                    )
                  else
                    PressableScale(
                      onTap: _openPromoPicker,
                      child: const AppBadgePill(
                        label: 'Apply',
                        variant: BadgeVariant.primary,
                        fontSize: 11,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 6. Review Summary Card
          AnimatedEntry(
            delay: const Duration(milliseconds: 280),
            child: LiquidGlassCard(
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: '${context.tr('items_subtotal')} (${widget.items.length})',
                    value: '\$${_subtotal.toStringAsFixed(2)}',
                    textSecondary: textSecondary,
                    textPrimary: textPrimary,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: context.tr('estimated_shipping'),
                    value: _shippingFee == 0.0 ? context.tr('free') : '\$${_shippingFee.toStringAsFixed(2)}',
                    isGreen: _shippingFee == 0.0,
                    textSecondary: textSecondary,
                    textPrimary: textPrimary,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Estimated Sales Tax',
                    value: '\$${_estimatedTax.toStringAsFixed(2)}',
                    textSecondary: textSecondary,
                    textPrimary: textPrimary,
                  ),
                  if (_promoDiscountValue > 0) ...[
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: context.tr('discount'),
                      value: '-\$${_promoDiscountValue.toStringAsFixed(2)}',
                      isGreen: true,
                      textSecondary: textSecondary,
                      textPrimary: textPrimary,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Divider(color: borderColor, height: 1),
                  const SizedBox(height: 12),
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
                      AppPriceText(
                        price: _totalPayment,
                        fontSize: 19,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Fixed Bottom Place Order Bar
      bottomNavigationBar: SafeArea(
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
              // Total Price
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('total'),
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AppPriceText(
                    price: _totalPayment,
                    fontSize: 20,
                    color: primaryColor,
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Place Order Button
              Expanded(
                child: PressableScale(
                  onTap: _handlePlaceOrder,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withValues(alpha: 0.88),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.lock_shield_fill, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
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

class _ModernProcessingDialog extends StatelessWidget {
  const _ModernProcessingDialog();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 52,
              width: 52,
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Securing Payment...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Authorizing with 256-bit encryption',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernSuccessDialog extends StatelessWidget {
  final double orderTotal;
  final VoidCallback onViewOrder;
  final VoidCallback onBackHome;

  const _ModernSuccessDialog({
    required this.orderTotal,
    required this.onViewOrder,
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.checkmark_alt_circle_fill,
                  size: 52,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Order Confirmed!',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you! Your luxury order has been placed. You paid \$${orderTotal.toStringAsFixed(2)}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            PressableScale(
              onTap: onViewOrder,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Track Order in My Orders',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            PressableScale(
              onTap: onBackHome,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
