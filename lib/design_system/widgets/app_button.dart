import 'package:flutter/material.dart';

class AppButton {
  static Widget filled({
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton(onPressed: onPressed, child: Text(label));
  }

  static Widget tonal({
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton.tonal(onPressed: onPressed, child: Text(label));
  }

  static Widget outline({
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }

  static Widget text({required String label, required VoidCallback onPressed}) {
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}
