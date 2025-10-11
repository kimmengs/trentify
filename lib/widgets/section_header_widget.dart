import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum SectionHeaderVariant { divider, materialAction, cupertinoAction, auto }

class SectionHeader extends StatelessWidget {
  final String title;

  /// Choose variant manually or let it auto-detect
  final SectionHeaderVariant variant;

  /// Action (for materialAction & cupertinoAction)
  final VoidCallback? onAction;
  final String actionLabel;
  final IconData actionIcon;

  /// Styling knobs
  final EdgeInsetsGeometry padding;
  final double dividerOpacity;

  const SectionHeader({
    super.key,
    required this.title,
    this.variant = SectionHeaderVariant.auto,
    this.onAction,
    this.actionLabel = 'View All',
    this.actionIcon = Icons.arrow_forward,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
    this.dividerOpacity = 0.4,
  });

  const SectionHeader.divider({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
    this.dividerOpacity = 0.4,
  }) : variant = SectionHeaderVariant.divider,
       onAction = null,
       actionLabel = 'View All',
       actionIcon = Icons.arrow_forward;

  const SectionHeader.material({
    super.key,
    required this.title,
    required this.onAction,
    this.actionLabel = 'View All',
    this.actionIcon = Icons.arrow_forward,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
    this.dividerOpacity = 0.4,
  }) : variant = SectionHeaderVariant.materialAction;

  const SectionHeader.cupertino({
    super.key,
    required this.title,
    required this.onAction,
    this.actionLabel = 'View All',
    this.actionIcon = CupertinoIcons.arrow_right_circle,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
    this.dividerOpacity = 0.4,
  }) : variant = SectionHeaderVariant.cupertinoAction;

  @override
  Widget build(BuildContext context) {
    // Auto-detect platform when variant = auto
    final effectiveVariant = variant == SectionHeaderVariant.auto
        ? (Theme.of(context).platform == TargetPlatform.iOS ||
                  Theme.of(context).platform == TargetPlatform.macOS)
              ? SectionHeaderVariant.cupertinoAction
              : SectionHeaderVariant.materialAction
        : variant;

    switch (effectiveVariant) {
      case SectionHeaderVariant.divider:
        return _buildWithDivider(context);
      case SectionHeaderVariant.materialAction:
        return _buildMaterialAction(context);
      case SectionHeaderVariant.cupertinoAction:
        return _buildCupertinoAction(context);
      case SectionHeaderVariant.auto:
        return const SizedBox(); // should never hit, handled above
    }
  }

  Widget _buildWithDivider(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dividerColor = Theme.of(
      context,
    ).dividerColor.withOpacity(dividerOpacity);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: dividerColor, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildMaterialAction(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (onAction != null)
            TextButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon, size: 16),
              label: Text(actionLabel),
            ),
        ],
      ),
    );
  }

  Widget _buildCupertinoAction(BuildContext context) {
    final base = CupertinoTheme.of(context).textTheme.navTitleTextStyle;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(title, style: base.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          if (onAction != null)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              onPressed: onAction,
              child: Row(
                children: [
                  Text(
                    actionLabel,
                    style: const TextStyle(
                      color: Color(0xFF528F65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(actionIcon, size: 18, color: const Color(0xFF528F65)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
