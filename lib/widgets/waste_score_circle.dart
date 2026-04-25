import 'package:flutter/material.dart';

class WasteScoreCircle extends StatelessWidget {
  const WasteScoreCircle({
    super.key,
    required this.score,
    this.size = 132,
    this.label = 'Waste Risk',
  });

  final int score;
  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    final normalized = (score.clamp(0, 100)) / 100;
    final color = score >= 70
        ? Theme.of(context).colorScheme.error
        : score >= 40
            ? const Color(0xFFF4A261)
            : const Color(0xFF2A9D8F);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: normalized.toDouble()),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 12,
                  backgroundColor: Colors.black.withValues(alpha: 0.06),
                  color: color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$score', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
