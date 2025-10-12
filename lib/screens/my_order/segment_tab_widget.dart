import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SegmentedTabsWidget extends StatelessWidget {
  const SegmentedTabsWidget({required this.controller, required this.items});

  final TabController controller;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(6),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: const Color(0xFF528F65),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: items.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}
