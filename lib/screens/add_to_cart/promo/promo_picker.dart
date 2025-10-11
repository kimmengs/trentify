import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trentify/model/promo.dart';

class PromoPickerPage extends StatefulWidget {
  const PromoPickerPage({
    super.key,
    required this.promos,
    required this.subtotal,
    this.initialSelectedId,
  });

  final List<Promo> promos;
  final double subtotal;
  final String? initialSelectedId;

  @override
  State<PromoPickerPage> createState() => _PromoPickerPageState();
}

class _PromoPickerPageState extends State<PromoPickerPage> {
  late List<Promo> _list;
  String? _selectedId;
  final _redeemCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _list = List<Promo>.from(widget.promos);
    _selectedId = widget.initialSelectedId;
  }

  @override
  void dispose() {
    _redeemCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Promos & Vouchers'),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have a Promo Code?',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 20),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: _redeemCtl,
                          decoration: const InputDecoration(
                            hintText: 'Enter code here',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF528F65),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: _onRedeem,
                        child: const Text(
                          'Redeem',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          ..._list.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PromoTile(
                promo: p,
                selected: p.id == _selectedId,
                eligible: widget.subtotal >= p.minSpend,
                onTap: () => setState(() => _selectedId = p.id),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF528F65),
                shape: const StadiumBorder(),
              ),
              onPressed: _selectedId == null
                  ? null
                  : () {
                      final promo = _list.firstWhere(
                        (e) => e.id == _selectedId,
                      );
                      Navigator.pop(context, promo);
                    },
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onRedeem() {
    final code = _redeemCtl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    // Simulate a lookup in existing list; you can replace with API call
    final found = _list.where((p) => p.code.toUpperCase() == code).toList();
    if (found.isNotEmpty) {
      setState(() => _selectedId = found.first.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Promo applied')));
      return;
    }

    // Example: if code not found, create a temporary promo (10% off)
    final tmp = Promo(
      id: 'redeem_$code',
      title: '$code — 10% OFF',
      code: code,
      type: PromoType.percent,
      value: 10,
      minSpend: 0,
      validUntil: DateTime.now().add(const Duration(days: 7)),
    );
    setState(() {
      _list = [tmp, ..._list];
      _selectedId = tmp.id;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Promo added')));
  }
}

// ——— UI widgets ———

class _Card extends StatelessWidget {
  const _Card({required this.child});
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

class _PromoTile extends StatelessWidget {
  const _PromoTile({
    required this.promo,
    required this.selected,
    required this.eligible,
    required this.onTap,
  });

  final Promo promo;
  final bool selected;
  final bool eligible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final df = DateFormat('MM/dd/yyyy');

    final borderColor = selected ? const Color(0xFF528F65) : Colors.transparent;

    final subtitle =
        '${promo.code} · Min. spend \$${promo.minSpend.toStringAsFixed(0)} · Valid till ${df.format(promo.validUntil)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: eligible ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.4),
            // grey-out if not eligible
            // you can also overlay a banner like "Not eligible"
          ),
          child: Row(
            children: [
              // left icon token
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0x22528F65),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_offer, color: Color(0xFF528F65)),
              ),
              const SizedBox(width: 12),

              // title + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.title,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: eligible
                            ? cs.onSurface
                            : cs.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              if (selected) const Icon(Icons.check, color: Color(0xFF528F65)),
            ],
          ),
        ),
      ),
    );
  }
}
