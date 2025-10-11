import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/model/payment_method.dart';

class PaymentPickerPage extends StatefulWidget {
  const PaymentPickerPage({
    super.key,
    required this.methods,
    this.initialSelectedId,
  });

  final List<PaymentMethod> methods;
  final String? initialSelectedId;

  @override
  State<PaymentPickerPage> createState() => _PaymentPickerPageState();
}

class _PaymentPickerPageState extends State<PaymentPickerPage> {
  late List<PaymentMethod> _list;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _list = List<PaymentMethod>.from(widget.methods);
    _selectedId =
        widget.initialSelectedId ?? (_list.isNotEmpty ? _list.first.id : null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Choose Payment Methods'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Card',
            onPressed: () async {
              // TODO: push add-card form; expect a PaymentMethod back
              // final created = await context.push<PaymentMethod>(AppRoutes.addCard);
              // if (created != null) setState(() { _list.add(created); _selectedId = created.id; });
            },
          ),
        ],
      ),

      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemCount: _list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final m = _list[i];
          final selected = m.id == _selectedId;
          return _PaymentTile(
            method: m,
            selected: selected,
            onTap: () => setState(() => _selectedId = m.id),
          );
        },
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
                      final m = _list.firstWhere((e) => e.id == _selectedId);
                      Navigator.pop(context, m);
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
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final border = selected ? const Color(0xFF528F65) : Colors.transparent;

    String title;
    if (method.kind == PaymentKind.wallet) {
      title = method.name; // PayPal / Google Pay / Apple Pay
    } else {
      // Card
      final last4 = method.last4 ?? '••••';
      title = '•••• •••• •••• $last4';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.4),
          ),
          child: Row(
            children: [
              _LogoCircle(
                brand: method.brand ?? method.name,
                asset: method.asset,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
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

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({this.asset, required this.brand});
  final String? asset;
  final String brand;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // If you have assets, load with Image.asset(asset!)
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: cs.surface, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: asset != null
          ? ClipOval(
              child: Image.asset(
                asset!,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            )
          : Text(
              // simple initials fallback
              _abbr(brand),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
    );
  }

  String _abbr(String s) {
    final parts = s.split(' ');
    if (parts.length == 1)
      return s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();
    return (parts[0].isNotEmpty ? parts[0][0] : '') +
        (parts[1].isNotEmpty ? parts[1][0] : '');
  }
}
