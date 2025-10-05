import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

class DividerInsetWidget extends StatelessWidget {
  const DividerInsetWidget();
  @override
  Widget build(BuildContext context) {
    final isIos = _isCupertino;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: isIos
          ? const Divider(height: 1, color: CupertinoColors.separator)
          : Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
    );
  }
}
