import 'package:flutter/cupertino.dart';

class SearchFieldWidget extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchFieldWidget({
    super.key,
    required this.placeholder,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bg = CupertinoDynamicColor.resolve(
      CupertinoColors.systemGrey6,
      context,
    );
    final textColor = CupertinoDynamicColor.resolve(
      CupertinoColors.secondaryLabel,
      context,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            CupertinoIcons.search,
            size: 20,
            color: CupertinoColors.inactiveGray,
          ),
          const SizedBox(width: 8),

          // text input (borderless)
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              placeholder: placeholder,
              placeholderStyle: TextStyle(color: textColor),
              onChanged: onChanged,
              padding: const EdgeInsets.symmetric(vertical: 14),
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
          ),
        ],
      ),
    );
  }
}
