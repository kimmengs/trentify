import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

enum SortOption {
  mostSuitable,
  popularity,
  topRated,
  priceHighToLow,
  priceLowToHigh,
  latestArrival,
  discount,
}

String sortLabel(SortOption o) => switch (o) {
  SortOption.mostSuitable => 'Most Suitable',
  SortOption.popularity => 'Popularity',
  SortOption.topRated => 'Top Rated',
  SortOption.priceHighToLow => 'Price High to Low',
  SortOption.priceLowToHigh => 'Price Low to High',
  SortOption.latestArrival => 'Latest Arrival',
  SortOption.discount => 'Discount',
};

Future<SortOption?> showPlatformSortSheet(
  BuildContext context, {
  SortOption initial = SortOption.mostSuitable,
}) async {
  final brightness = Theme.of(context).brightness;
  final isDark = brightness == Brightness.dark;
  final isCupertino =
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  final options = SortOption.values;

  if (isCupertino) {
    // iOS / macOS – CupertinoActionSheet
    return showCupertinoModalPopup<SortOption>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          'Sort',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          for (final opt in options)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context, opt),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (opt == initial) ...[
                    Icon(
                      CupertinoIcons.check_mark,
                      size: 18,
                      color: const Color(0xFF528F65),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    sortLabel(opt),
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () => Navigator.pop(context, null),
          child: Text(
            'Cancel',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  } else {
    // Android / others – Material bottom sheet
    return showModalBottomSheet<SortOption>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Sort',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(height: 0),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final opt in options)
                      RadioListTile<SortOption>(
                        value: opt,
                        groupValue: initial,
                        onChanged: (v) => Navigator.pop(context, v),
                        title: Text(
                          sortLabel(opt),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        dense: true,
                        activeColor: const Color(0xFF528F65),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
