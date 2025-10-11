import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/model/address.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/model/payment_method.dart';
import 'package:trentify/model/promo.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/screens/add_to_cart/add_to_cart.dart';
import 'package:trentify/widgets/adaptive_button_style_widget.dart';
import 'package:trentify/widgets/section_header_widget.dart';

// Reuse your CartItem from add_to_cart.dart
// import 'add_to_cart.dart'; // ensure the path is right

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

  static List<Widget> _buildItemRows(
    BuildContext context,
    List<CartItem> items,
    ColorScheme cs,
    TextTheme text,
  ) {
    final divider = Divider(
      color: cs.outlineVariant.withOpacity(.5),
      height: 20,
    );
    final rows = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final e = items[i];
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                e.imageUrl,
                width: 64,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Size: ${e.size}', style: text.bodyMedium),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text('Color: ${e.colorName}', style: text.bodyMedium),
                      const SizedBox(width: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: e.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.outlineVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Qty: ${e.qty}', style: text.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    '\$${e.price.toStringAsFixed(2)}',
                    style: text.titleMedium?.copyWith(
                      color: const Color(0xFF528F65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      if (i != items.length - 1) rows.add(divider);
    }
    return rows;
  }

  static String _money(double v) =>
      (v >= 0 ? '\$' : '- \$') + v.abs().toStringAsFixed(2);

  static Widget _kv(
    String key,
    String value, {
    TextStyle? keyStyle,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(key, style: keyStyle)),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _CheckoutPageState extends State<CheckoutPage> {
  Address? selected;
  PaymentMethod? selectedPay;
  Promo? selectedPromo;

  @override
  void initState() {
    super.initState();
    selected =
        widget.initialAddress ??
        (widget.addresses.isNotEmpty ? widget.addresses.first : null);

    if (DemoDb.demoMethods.isNotEmpty) {
      selectedPay = DemoDb.demoMethods.first;
    }

    if (DemoDb.demoMethods.isNotEmpty) selectedPay = DemoDb.demoMethods.first;
  }

  double _promoDiscount(Promo? p, double subtotal) {
    if (p == null) return 0;
    if (subtotal < p.minSpend) return 0;
    switch (p.type) {
      case PromoType.percent:
      case PromoType.cashback:
        return -(subtotal * (p.value / 100));
      case PromoType.flat:
        return -p.value;
    }
  }

  Widget _kv(
    String key,
    String value, {
    TextStyle? keyStyle,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: keyStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // <- keeps current selection

    final subtotal = widget.items.fold<double>(
      0,
      (a, e) => a + e.price * e.qty,
    );
    const serviceFee = 1.50;
    const deliveryFee = 8.50;
    const tax = 3.50;
    // Example promo: -$107
    const promo = -107.00;
    final total = subtotal + serviceFee + deliveryFee + tax + promo;

    Future<void> _openPromoPicker() async {
      final subtotal = widget.items.fold<double>(
        0,
        (a, e) => a + e.price * e.qty,
      );
      final picked = await context.push<Promo>(
        AppRoutes.promoPicker,
        extra: {
          'promos': DemoDb.demoPromos,
          'selectedId': selectedPromo?.id,
          'subtotal': subtotal,
        },
      );
      if (picked != null) setState(() => selectedPromo = picked);
    }

    Future<void> _handleConfirmOrder() async {
      // Show "Processing Payments" dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _ProcessingDialog(),
      );

      // Simulate payment delay
      await Future.delayed(const Duration(seconds: 4));

      // Close the loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SuccessDialog(
          onViewOrder: () {
            Navigator.pop(context); // close dialog
            context.go(AppRoutes.home, extra: {'tabIndex': 3}); // back to home
          },
          onBackHome: () {
            Navigator.pop(context);
            context.go(AppRoutes.home, extra: {'tabIndex': 0}); // back to home
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          _CardBlock(
            child: _LeadingTitleRow(
              icon: Icons.location_on_rounded,
              title: 'Delivery Address',
              subtitle: selected != null
                  ? '${selected!.label} — ${selected!.fullName}\n${selected!.line1}'
                  : 'Choose an address',
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await context.push<Address>(
                  AppRoutes.addressPicker,
                  extra: {
                    'addresses': DemoDb.addresses, // List<Address>
                    'selectedId': selected?.id, // currently selected id or null
                  },
                );

                // If user tapped OK:
                if (picked != null) {
                  setState(
                    () => selected = picked,
                  ); // or update your state management
                }
              },
            ),
          ),

          const SizedBox(height: 12),

          _CardBlock(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Your Order (${widget.items.length})',
                  onAction: () {
                    /* add more items */
                  },
                ),
                const SizedBox(height: 12),
                ...CheckoutPage._buildItemRows(context, widget.items, cs, text),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _CardBlock(
            child: _PaymentSection(
              method: selectedPay, // PaymentMethod? from state
              onOpenPicker: () async {
                final picked = await context.push<PaymentMethod>(
                  AppRoutes.paymentPicker,
                  extra: {
                    'methods': DemoDb.demoMethods,
                    'selectedId': selectedPay?.id,
                  },
                );
                if (picked != null) setState(() => selectedPay = picked);
              },
            ),
          ),

          const SizedBox(height: 12),

          // In your CheckoutPage build (inside the ListView)
          _CardBlock(
            child: _PromoSection(
              promo: selectedPromo, // Promo? from your state
              onOpenPicker: _openPromoPicker, // opens promo picker
              onRemove: () => setState(() => selectedPromo = null),
            ),
          ),
          const SizedBox(height: 12),

          _CardBlock(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _RowTitle(title: 'Review Summary'),
                const SizedBox(height: 12),

                Builder(
                  builder: (context) {
                    final subtotal = widget.items.fold<double>(
                      0,
                      (a, e) => a + e.price * e.qty,
                    );
                    const serviceFee = 1.50;
                    const deliveryFee = 8.50;
                    const tax = 3.50;
                    final promo = _promoDiscount(selectedPromo, subtotal);
                    final total =
                        subtotal + serviceFee + deliveryFee + tax + promo;

                    final text = Theme.of(context).textTheme;

                    return Column(
                      children: [
                        _kv(
                          'Subtotal (${widget.items.length} items)',
                          '\$${subtotal.toStringAsFixed(2)}',
                        ),
                        _kv(
                          'Service Fee',
                          '\$${serviceFee.toStringAsFixed(2)}',
                        ),
                        _kv(
                          'Delivery Fee',
                          '\$${deliveryFee.toStringAsFixed(2)}',
                        ),
                        _kv('Tax', '\$${tax.toStringAsFixed(2)}'),
                        _kv(
                          'Promo',
                          (promo >= 0 ? '\$' : '- \$') +
                              promo.abs().toStringAsFixed(2),
                          valueStyle: text.bodyLarge?.copyWith(
                            color: Colors.redAccent,
                          ),
                        ),
                        const Divider(height: 20),
                        _kv(
                          'Total Payment',
                          '\$${total.toStringAsFixed(2)}',
                          keyStyle: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          valueStyle: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      // Confirm Order
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: AdaptiveActionButton(
              label: 'Confirm Order',
              style: AdaptiveButtonStyle.filled,
              onPressed: _handleConfirmOrder,
              color: const Color(0xFF528F65),
            ),
          ),
        ),
      ),
    );
  }
}

// ——— UI pieces ———

class _CardBlock extends StatelessWidget {
  const _CardBlock({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _LeadingTitleRow extends StatelessWidget {
  const _LeadingTitleRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.leadingImage,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? leadingImage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0x22528F65),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF528F65), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (leadingImage != null) ...[
            const SizedBox(width: 12),
            leadingImage!,
          ],
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );
  }
}

class _RowTitle extends StatelessWidget {
  const _RowTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  );
}

class _PromoChipCard extends StatelessWidget {
  const _PromoChipCard({
    required this.title,
    required this.subtitle,
    this.onRemove,
  });
  final String title;
  final String subtitle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0x22528F65),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer,
              size: 18,
              color: Color(0xFF528F65),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: Colors.redAccent),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({this.asset, this.label});
  final String? asset;
  final String? label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: cs.surface, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        label ?? '',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PromoSection extends StatelessWidget {
  const _PromoSection({
    required this.promo,
    required this.onOpenPicker,
    required this.onRemove,
  });

  final Promo? promo;
  final VoidCallback onOpenPicker;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with chevron (taps open picker)
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onOpenPicker,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                // left token
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0x22528F65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_offer,
                    size: 18,
                    color: Color(0xFF528F65),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Promos & Vouchers',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),

        // subtle divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: cs.outlineVariant.withOpacity(.35), height: 1),
        ),

        // Selected promo row (rounded, with red X)
        if (promo != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Green circular badge
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(
                      0xFF5B8669,
                    ), // slightly darker green than header chip
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_offer, color: Colors.white),
                ),
                const SizedBox(width: 12),

                // Title + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo!.title,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${promo!.code} · Min. spend \$${promo!.minSpend.toStringAsFixed(0)} · '
                        'Valid till ${promo!.validUntil.month}/${promo!.validUntil.day}/${promo!.validUntil.year}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Remove X (red)
                IconButton(
                  tooltip: 'Remove',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                ),
              ],
            ),
          )
        else
          // If no promo, show nothing (or a hint button if you want)
          TextButton.icon(
            onPressed: onOpenPicker,
            icon: const Icon(Icons.local_offer_outlined),
            label: const Text('Add Promo'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF528F65),
              shape: const StadiumBorder(),
            ),
          ),
      ],
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.method, required this.onOpenPicker});

  final PaymentMethod? method;
  final VoidCallback onOpenPicker;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with chevron
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onOpenPicker,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0x22528F65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    size: 18,
                    color: Color(0xFF528F65),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Payment Methods',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),

        // subtle divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: cs.outlineVariant.withOpacity(.35), height: 1),
        ),

        // Selected method row
        if (method != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PMLogoCircle(
                  brand: method!.brand ?? method!.name,
                  asset: method!.asset,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method!.brand ?? method!.name,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _pmSubtitle(method!),
                        style: text.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          // If none selected, show a clear action to pick one
          TextButton.icon(
            onPressed: onOpenPicker,
            icon: const Icon(Icons.add_card),
            label: const Text('Choose Payment Method'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF528F65),
              shape: const StadiumBorder(),
            ),
          ),
      ],
    );
  }

  String _pmSubtitle(PaymentMethod m) {
    if (m.kind == PaymentKind.wallet)
      return m.name; // PayPal / Apple Pay / GPay
    final last4 = m.last4 ?? '••••';
    return '••••  ••••  ••••  $last4';
  }
}

class _PMLogoCircle extends StatelessWidget {
  const _PMLogoCircle({required this.brand, this.asset});
  final String brand;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: cs.surface, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: asset != null
          ? ClipOval(
              child: Image.asset(
                asset!,
                width: 34,
                height: 34,
                fit: BoxFit.contain,
              ),
            )
          : Text(
              _abbr(brand),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
    );
  }

  String _abbr(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final t = parts.first;
      return t.substring(0, t.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0].isNotEmpty ? parts[0][0] : '').toUpperCase() +
        (parts[1].isNotEmpty ? parts[1][0] : '').toUpperCase();
  }
}

class _ProcessingDialog extends StatelessWidget {
  const _ProcessingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              height: 48,
              width: 48,
              child: CircularProgressIndicator(
                color: Color(0xFF528F65),
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Processing Payments...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final VoidCallback onViewOrder;
  final VoidCallback onBackHome;

  const _SuccessDialog({required this.onViewOrder, required this.onBackHome});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: const [
                CircleAvatar(radius: 40, backgroundColor: Color(0x33528F65)),
                Icon(Icons.check_circle, size: 60, color: Color(0xFF528F65)),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Confirmed!',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Peep your order details in "My Order" and start planning outfits.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onViewOrder,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF528F65),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'View My Order',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onBackHome,
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
