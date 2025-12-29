import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CompatibilityPill extends StatelessWidget {
  const CompatibilityPill({required this.score, super.key});

  final int score; // 0..100

  Color _color(BuildContext context) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return CircularPercentIndicator(
      radius: 18,
      percent: (score.clamp(0, 100)) / 100.0,
      progressColor: color,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      center: Text(
        '$score%',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
