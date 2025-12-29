import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A3D), // Dark blue background
      body: Stack(
        children: <Widget>[
          // Confetti background
          Positioned.fill(
            child: CustomPaint(
              painter: ConfettiPainter(),
            ),
          ),
          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Profile avatars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5271FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // MATCH text with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: <Color>[
                        Color(0xFF5271FF),
                        Color(0xFF4A90E2),
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'MATCH !',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        context.go('/profile');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF5271FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'PROPOSER UN ENTRETIEN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () {
                        context.go('/profile');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF5271FF,
                        ).withValues(alpha: 0.2),
                        foregroundColor: const Color(0xFF5271FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CONTACTER',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = DateTime.now().millisecondsSinceEpoch;

    // Draw confetti pieces
    for (var i = 0; i < 50; i++) {
      final x = (random + i * 123) % size.width;
      final y = (random + i * 456) % size.height;

      // Random colors
      final colors = <Color>[
        Colors.red,
        Colors.blue,
        Colors.yellow,
        Colors.pink,
        Colors.orange,
        Colors.green,
        Colors.purple,
      ];
      paint.color = colors[i % colors.length];

      // Draw small rectangles as confetti
      canvas.drawRect(
        Rect.fromLTWH(x, y, 4, 8),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
