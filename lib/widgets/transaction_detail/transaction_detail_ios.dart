import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trentify/widgets/transaction_detail/transaction_detail.dart';
import 'package:intl/intl.dart';
import 'package:trentify/widgets/quick_action_widget.dart';
import 'package:trentify/widgets/kvrow_widget.dart';

class TransactionDetailIOS extends StatelessWidget {
  const TransactionDetailIOS({super.key, required this.detail});
  final TxDetail detail;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final date = DateFormat('d MMM, y  •  hh:mm a');

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        middle: Text(detail.counterpartyName),
        trailing: const Icon(CupertinoIcons.ellipsis_vertical, size: 20),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            Column(
              children: [
                Text(
                  money.format(detail.amount),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${detail.type}  •  ${detail.status}',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const SizedBox(height: 18),

            _CardBox(
              child: Column(
                children: [
                  KVRowWidget(k: 'To', v: detail.counterpartyName, boldV: true),
                  const SizedBox(height: 10),
                  KVRowWidget(k: 'Email', v: detail.counterpartyEmail),
                  const SizedBox(height: 10),
                  KVRowWidget(
                    k: 'Date',
                    v: date.format(detail.createdAt),
                    boldV: true,
                  ),
                  const SizedBox(height: 10),
                  KVRowWidget(
                    k: 'Amount',
                    v: money.format(detail.amount),
                    boldV: true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(
                        flex: 4,
                        child: Text(
                          'Transaction ID',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                detail.txId,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 28,
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: detail.txId),
                                );
                                _toast(context, 'Copied');
                              },
                              child: const Icon(
                                CupertinoIcons.doc_on_doc,
                                size: 18,
                                color: CupertinoColors.activeBlue,
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
            const SizedBox(height: 14),
            _CardBox(
              child: Column(
                children: [
                  KVRowWidget(
                    k: 'Subtotal',
                    v: money.format(detail.subtotal),
                    boldV: true,
                  ),
                  const SizedBox(height: 12),
                  KVRowWidget(k: 'Fees', v: '- ${money.format(detail.fee)}'),
                  const Divider(height: 26, color: CupertinoColors.separator),
                  KVRowWidget(
                    k: 'Net Total',
                    v: money.format(detail.netTotal),
                    boldV: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, color: CupertinoColors.separator),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                QuickActionTileWidget(
                  label: 'Download',
                  icon: CupertinoIcons.download_circle,
                ),
                QuickActionTileWidget(
                  label: 'Repeat',
                  icon: CupertinoIcons.collections,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _toast(BuildContext context, String msg) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 80,
        left: 24,
        right: 24,
        child: IgnorePointer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: CupertinoColors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              msg,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 900), entry.remove);
  }
}

class _CardBox extends StatelessWidget {
  const _CardBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
