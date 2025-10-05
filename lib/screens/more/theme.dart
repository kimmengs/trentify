// lib/screens/settings/theme_settings_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_controller.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ThemeController>();

    final colorChoices = <Color>[
      const Color(0xFF4F77FE),
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFF8B5CF6),
    ];

    Widget body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Appearance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        _SegControl<AppThemeMode>(
          value: ctrl.mode,
          onValueChanged: ctrl.setMode,
          segments: const {
            AppThemeMode.system: 'System',
            AppThemeMode.light: 'Light',
            AppThemeMode.dark: 'Dark',
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Brand color',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colorChoices.map((c) {
            final selected = ctrl.seed.value == c.value;
            return GestureDetector(
              onTap: () => ctrl.setSeed(c),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: c.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ]
                      : const [],
                  border: selected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
        CupertinoButton(
          child: const Text('Ocean Theme'),
          onPressed: () => context.read<ThemeController>().setPackId('ocean'),
        ),
        CupertinoButton(
          child: const Text('Particles Theme'),
          onPressed: () =>
              context.read<ThemeController>().setPackId('particles'),
        ),
      ],
    );

    // Adapt UI container
    return Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(middle: Text('Theme')),
            child: SafeArea(child: body),
          )
        : Scaffold(
            appBar: AppBar(title: const Text('Theme')),
            body: body,
          );
  }
}

class _SegControl<T extends Object> extends StatelessWidget {
  const _SegControl({
    required this.value,
    required this.onValueChanged,
    required this.segments,
  });

  final T value;
  final ValueChanged<T> onValueChanged;
  final Map<T, String> segments;

  @override
  Widget build(BuildContext context) {
    final isCupertino = Theme.of(context).platform == TargetPlatform.iOS;
    if (isCupertino) {
      return CupertinoSegmentedControl<T>(
        groupValue: value,
        onValueChanged: onValueChanged,
        children: {
          for (final e in segments.entries)
            e.key: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Text(e.value),
            ),
        },
      );
    }
    return SegmentedButton<T>(
      segments: [
        for (final e in segments.entries)
          ButtonSegment(value: e.key, label: Text(e.value)),
      ],
      selected: {value},
      onSelectionChanged: (set) => onValueChanged(set.first),
    );
  }
}
