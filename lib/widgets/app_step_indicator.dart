import 'package:flutter/material.dart';

class StepItem {
  final String number;
  final String title;
  const StepItem({required this.number, required this.title});
}

/// A multi-step horizontal progress tracker for checkout, onboarding, and shipping journeys.
class AppStepIndicator extends StatelessWidget {
  final List<StepItem> steps;
  final int currentStepIndex; // 0-indexed
  final Color? activeColor;

  const AppStepIndicator({
    super.key,
    required this.steps,
    required this.currentStepIndex,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = activeColor ?? theme.primaryColor;
    final inactiveBg = isDark ? const Color(0xFF21262D) : const Color(0xFFE2E8F0);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _buildPill(
            step: steps[i],
            isDone: i < currentStepIndex,
            isActive: i == currentStepIndex,
            primary: primary,
            inactiveBg: inactiveBg,
            textSecondary: textSecondary,
          ),
          if (i < steps.length - 1)
            Container(
              width: 20,
              height: 2,
              color: i < currentStepIndex ? primary : const Color(0xFFCBD5E1),
            ),
        ],
      ],
    );
  }

  Widget _buildPill({
    required StepItem step,
    required bool isDone,
    required bool isActive,
    required Color primary,
    required Color inactiveBg,
    required Color textSecondary,
  }) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone || isActive ? primary : inactiveBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : Text(
                    step.number,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isActive ? Colors.white : textSecondary,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          step.title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive || isDone ? FontWeight.w700 : FontWeight.w500,
            color: isActive || isDone ? primary : textSecondary,
          ),
        ),
      ],
    );
  }
}
