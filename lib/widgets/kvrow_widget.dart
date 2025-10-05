import 'package:flutter/cupertino.dart';

class KVRowWidget extends StatelessWidget {
  const KVRowWidget({
    super.key,
    required this.k,
    required this.v,
    this.boldV = false,
    this.flexK = 4,
    this.flexV = 6,
  });

  final String k;
  final String v;
  final bool boldV;
  final int flexK;
  final int flexV;

  @override
  Widget build(BuildContext context) {
    const kStyle = TextStyle(color: CupertinoColors.systemGrey, fontSize: 16);
    final vStyle = TextStyle(
      fontSize: 16,
      fontWeight: boldV ? FontWeight.w700 : FontWeight.w600,
    );

    return Row(
      children: [
        Expanded(
          flex: flexK,
          child: Text(
            k,
            style: kStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: flexV,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              v,
              style: vStyle,
              textAlign: TextAlign.right,
              maxLines: 1, // keep to one line so rows align
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ),
      ],
    );
  }
}
