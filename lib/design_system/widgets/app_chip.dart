import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label, super.key,
    this.selected = false,
    this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      checkmarkColor: theme.colorScheme.primary,
    );
  }
}
