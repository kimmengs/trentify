import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trentify/model/scanned_payee.dart';

class ReviewSummaryMaterial extends StatelessWidget {
  const ReviewSummaryMaterial({
    super.key,
    required this.payee,
    required this.amount,
    required this.tax,
    required this.notes,
  });

  final ScannedPayee payee;
  final double amount;
  final double tax;
  final String notes;

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final total = amount - tax; // keeping your original behavior

    final avatar = CircleAvatar(
      radius: 43,
      backgroundColor: const Color(0xFFB3D4FF),
      backgroundImage: payee.avatarUrl != null
          ? NetworkImage(payee.avatarUrl!)
          : null,
      child: payee.avatarUrl == null
          ? const Icon(Icons.person, color: Colors.white, size: 44)
          : null,
    );

    final header = Column(
      children: [
        avatar,
        const SizedBox(height: 12),
        Text(
          payee.name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          payee.email,
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
      ],
    );

    final summaryCardMaterial = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SummaryRow(label: 'Amount (USD)', value: f.format(amount)),
            const SizedBox(height: 12),
            _SummaryRow(label: 'Fee', value: '- ${f.format(tax)}'),
            const Divider(height: 24),
            _SummaryRow(label: 'Total', value: f.format(total), bold: true),
          ],
        ),
      ),
    );

    final paymentType = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: ListTile(
        title: const Text('For goods and services'),
        trailing: const Icon(Icons.keyboard_arrow_down),
        onTap: () {}, // keep non-interactive like original
      ),
    );

    final notesSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          notes.isEmpty ? '—' : notes,
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
      ],
    );

    final confirmButton = SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () async {
          if (!context.mounted) return;
          context.go('/success', extra: payee.name);
        },
        child: const Text('Confirm & Send'),
      ),
    );

    final content = ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        header,
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),
        summaryCardMaterial,
        const SizedBox(height: 28),
        const Text(
          'Payment Type',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        paymentType,
        const SizedBox(height: 28),
        notesSection,
        const SizedBox(height: 36),
        confirmButton,
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Review Summary')),
      body: SafeArea(child: content),
      backgroundColor: Color(0xFF528F65),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 18,
      fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
