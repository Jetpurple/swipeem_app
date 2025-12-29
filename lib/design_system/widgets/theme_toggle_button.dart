import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hire_me/providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {

  const ThemeToggleButton({
    super.key,
    this.showLabel = true,
    this.padding,
  });
  final bool showLabel;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return InkWell(
      onTap: themeNotifier.toggleTheme,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                themeMode == ThemeMode.dark ? 'Mode clair' : 'Mode sombre',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ThemeToggleIconButton extends ConsumerWidget {
  const ThemeToggleIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return IconButton(
      onPressed: themeNotifier.toggleTheme,
      icon: Icon(
        themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
      ),
      tooltip: themeMode == ThemeMode.dark ? 'Passer au mode clair' : 'Passer au mode sombre',
    );
  }
}
