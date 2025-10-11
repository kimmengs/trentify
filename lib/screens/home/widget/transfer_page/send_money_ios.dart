import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/model/scanned_payee.dart';

class SendMoneyCupertino extends StatefulWidget {
  const SendMoneyCupertino({super.key, required this.payee});
  final ScannedPayee payee;

  @override
  State<SendMoneyCupertino> createState() => _SendMoneyCupertinoState();
}

class _SendMoneyCupertinoState extends State<SendMoneyCupertino> {
  final _noteController = TextEditingController();

  // Native keyboard + live currency formatting
  final _amountController = TextEditingController();
  // Format like $12,345 (no decimals)

  double _amountDollars = 0; // parsed dollars

  void _onAmountChanged(String value) {
    final amount = double.tryParse(value) ?? 0.0;
    setState(() => _amountDollars = amount);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payee;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Send Money to'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Recipient row (unchanged)
            Row(
              children: [
                _Avatar(url: p.avatarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.email,
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: const Icon(
                    CupertinoIcons.pencil,
                    color: Color(0xFF4F77FE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: CupertinoColors.separator),
            const SizedBox(height: 18),

            const Text(
              'Enter the amount to send',
              textAlign: TextAlign.center,
              style: TextStyle(color: CupertinoColors.label, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Big amount input (native keyboard)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(width: 3, color: const Color(0xFF4F77FE)),
              ),
              child: Center(
                child: CupertinoTextField(
                  controller: _amountController,
                  onChanged: _onAmountChanged,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal:
                        true, // ✅ shows the native iOS keyboard with a “.” key
                  ),
                  textAlign: TextAlign.center,
                  decoration: null,
                  autofocus: true,
                  placeholder: '0.00', // simple placeholder
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                  ),
                  // only allow digits and at most one decimal point,
                  // but don’t add a “$”, don’t reformat.
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Add a note (optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _noteController,
              placeholder: 'Add a note',
              maxLines: 3,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: _amountDollars > 0
                  ? () {
                      final amount = _amountDollars.toDouble();
                      context.push(
                        '/review-summary',
                        extra: {
                          'payee': widget.payee,
                          'amount': amount,
                          'tax': 0.00,
                          'notes': _noteController.text,
                        },
                      );
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFB3D4FF),
        borderRadius: BorderRadius.circular(27),
        image: url != null
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: url == null
          ? const Icon(CupertinoIcons.person_fill, color: Colors.white)
          : null,
    );
  }
}
