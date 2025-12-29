import 'package:flutter/material.dart';
import 'package:hire_me/design_system/modules/compatibility_pill.dart';

class SwipeCard extends StatefulWidget {
  const SwipeCard({
    required this.imageUrl,
    required this.company,
    required this.title,
    required this.tags,
    required this.badges,
    required this.compatibilityScore,
    required this.onLike,
    required this.onPass,
    required this.onSuperLike,
    this.isFavorite = false,
    super.key,
  });

  final String? imageUrl;
  final String company;
  final String title;
  final List<String>? tags;
  final List<String>? badges;
  final int compatibilityScore;
  final VoidCallback onLike;
  final VoidCallback onPass;
  final VoidCallback onSuperLike;
  final bool isFavorite;

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with SingleTickerProviderStateMixin {
  double _dragX = 0;
  double _dragY = 0;
  bool _isDragging = false;
  
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
      _dragY += details.delta.dy;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_dragX > threshold) {
      // Swipe vers la droite = Like
      _animateAndTrigger(Offset(screenWidth, 0), widget.onLike);
    } else if (_dragX < -threshold) {
      // Swipe vers la gauche = Pass
      _animateAndTrigger(Offset(-screenWidth, 0), widget.onPass);
    } else if (_dragY < -100) {
      // Swipe vers le haut = Super Like
      _animateAndTrigger(const Offset(0, -1000), widget.onSuperLike);
    } else {
      // Retour à la position d'origine
      setState(() {
        _dragX = 0;
        _dragY = 0;
      });
    }
  }

  void _animateAndTrigger(Offset targetOffset, VoidCallback callback) {
    _animation = Tween<Offset>(
      begin: Offset(_dragX, _dragY),
      end: targetOffset,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward(from: 0).then((_) {
      callback();
      _animationController.reset();
      setState(() {
        _dragX = 0;
        _dragY = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final rotation = _dragX / 1000;
    final opacity = 1 - (_dragX.abs() / 500).clamp(0.0, 0.5);
    
    // Calculer l'intensité de l'ombre verte pour le swipe à droite
    final greenShadowIntensity = (_dragX > 0 ? _dragX / 200 : 0.0).clamp(0.0, 1.0);
    final redShadowIntensity = (_dragX < 0 ? -_dragX / 200 : 0.0).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final offset = _animationController.isAnimating
            ? _animation.value
            : Offset(_dragX, _dragY);

        return Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(
              opacity: opacity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    // Ombre verte pour swipe à droite (like)
                    if (greenShadowIntensity > 0)
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5 * greenShadowIntensity),
                        blurRadius: 30 * greenShadowIntensity,
                        spreadRadius: 10 * greenShadowIntensity,
                        offset: Offset(-5 * greenShadowIntensity, 0),
                      ),
                    // Ombre rouge pour swipe à gauche (pass)
                    if (redShadowIntensity > 0)
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5 * redShadowIntensity),
                        blurRadius: 30 * redShadowIntensity,
                        spreadRadius: 10 * redShadowIntensity,
                        offset: Offset(5 * redShadowIntensity, 0),
                      ),
                  ],
                ),
                child: child!,
              ),
            ),
          ),
        );
      },
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          children: [
            // Indicateurs visuels de swipe
            if (_isDragging && _dragX > 50)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green, width: 4),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.handshake,
                      size: 100,
                      color: Colors.green.withOpacity(0.7 + (0.3 * greenShadowIntensity)),
                    ),
                  ),
                ),
              ),
            if (_isDragging && _dragX < -50)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red, width: 4),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 100,
                      color: Colors.red.withOpacity(0.7 + (0.3 * redShadowIntensity)),
                    ),
                  ),
                ),
              ),
            if (_isDragging && _dragY < -50)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber, width: 4),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.bolt,
                      size: 100,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ),
              ),
            _buildCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (widget.isFavorite)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.bookmark, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Favori', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          // Background image
          Image.network(
            widget.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return ColoredBox(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image, size: 100),
              );
            },
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const <double>[0, 0.6, 1],
              ),
            ),
          ),
          // Content overlay
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Company info row
                Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.company.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    CompatibilityPill(score: widget.compatibilityScore),
                  ],
                ),
                const SizedBox(height: 12),
                // Job title
                Text(
                  widget.title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Tags rows
                if (widget.tags != null) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.tags!
                        .map(
                          (String tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B4513), // Brown
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 6),
                ],
                if (widget.badges != null) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.badges!
                        .map(
                          (String badge) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32), // Green
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
