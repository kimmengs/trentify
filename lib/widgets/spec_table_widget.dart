import 'package:flutter/material.dart';

class SpecTableWidget extends StatelessWidget {
  final Map<String, String> specs;
  const SpecTableWidget({required this.specs});

  @override
  Widget build(BuildContext context) {
    final rows = specs.entries.map((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                e.key,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Text(':  '),
            Expanded(child: Text(e.value)),
          ],
        ),
      );
    }).toList();

    return Column(children: rows);
  }
}
