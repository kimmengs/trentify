import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/model/scanned_payee.dart';

class SendMoneyMaterial extends StatefulWidget {
  const SendMoneyMaterial({super.key, required this.payee});
  final ScannedPayee payee;

  @override
  State<SendMoneyMaterial> createState() => _SendMoneyMaterialState();
}

class _SendMoneyMaterialState extends State<SendMoneyMaterial> {
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();

  double _amountDollars = 0;

  void _onAmountChanged(String value) {
    // allow empty → 0
    final parsed = double.tryParse(value) ?? 0.0;
    setState(() => _amountDollars = parsed);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _continue() {
    context.push(
      '/review-summary',
      extra: {
        'payee': widget.payee,
        'amount': _amountDollars,
        'tax': 0.00,
        'notes': _noteController.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payee;

    final headerRow = Row(
      children: [
        _Avatar(url: p.avatarUrl),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                p.email,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.edit, color: Color(0xFF4F77FE)),
        ),
      ],
    );

    final titleText = Text(
      'Enter the amount to send',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
      ),
    );

    final amountFieldMaterial = TextField(
      controller: _amountController,
      onChanged: _onAmountChanged,
      autofocus: true,
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800),
      decoration: const InputDecoration(
        hintText: '0.00',
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 3)),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );

    final noteField = TextField(
      controller: _noteController,
      maxLines: 3,
      decoration: const InputDecoration(
        hintText: 'Add a note',
        border: OutlineInputBorder(),
      ),
    );

    final continueButton = SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _amountDollars > 0 ? _continue : null,
        child: const Text('Continue'),
      ),
    );

    final content = ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        headerRow,
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 18),
        titleText,
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: amountFieldMaterial,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Add a note (optional)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        noteField,
        const SizedBox(height: 24),
        continueButton,
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Send Money to')),
      body: SafeArea(child: content),
      backgroundColor: Color(0xFF528F65),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 27,
      backgroundColor: const Color(0xFFB3D4FF),
      backgroundImage: url != null ? NetworkImage(url!) : null,
      child: url == null ? const Icon(Icons.person, color: Colors.white) : null,
    );
  }
}
