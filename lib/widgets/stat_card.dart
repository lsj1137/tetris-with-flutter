import 'package:flutter/material.dart';

/// 레벨·점수 표시 카드.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.level, required this.score});

  final int level;
  final int score;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Stat(label: 'LEVEL', value: '$level'),
          const SizedBox(width: 20),
          _Stat(label: 'SCORE', value: '$score'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
