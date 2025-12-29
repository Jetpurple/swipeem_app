import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hire_me/design_system/modules/compatibility_pill.dart';
import 'package:hire_me/models/user_model.dart';
import 'package:hire_me/services/storage_service.dart';

class CandidateSwipeCard extends StatefulWidget {
  const CandidateSwipeCard({
    required this.candidate,
    required this.compatibilityScore,
    required this.onLike,
    required this.onPass,
    required this.onSuperLike,
    this.isFavorite = false,
    this.onTap,
    super.key,
  });

  final UserModel candidate;
  final int compatibilityScore;
  final VoidCallback onLike;
  final VoidCallback onPass;
  final VoidCallback onSuperLike;
  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  State<CandidateSwipeCard> createState() => _CandidateSwipeCardState();
}

class _CandidateSwipeCardState extends State<CandidateSwipeCard>
    with SingleTickerProviderStateMixin {
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
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: -4,
                      offset: const Offset(0, 4),
                    ),
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
                clipBehavior: Clip.hardEdge,
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
        onTap: _isDragging ? null : widget.onTap,
        child: Stack(
          children: [
            // Indicateurs visuels de swipe
            if (_isDragging && _dragX > 50)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
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
                    borderRadius: BorderRadius.circular(28),
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
                    borderRadius: BorderRadius.circular(28),
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
    final candidate = widget.candidate;
    final profileImage = StorageService.resolveProfileImage(candidate.profileImageUrl);
    
    // Collect all badges from candidate data
    final allBadges = <String>[];
    
    // Hard skills
    if (candidate.hardSkills.isNotEmpty) {
      for (var skill in candidate.hardSkills) {
        final name = skill['name'] as String? ?? skill['label'] as String?;
        if (name != null) {
          allBadges.add(name);
        }
      }
    }
    
    // Soft skills
    if (candidate.softSkills.isNotEmpty) {
      for (var skill in candidate.softSkills) {
        final name = skill['name'] as String? ?? skill['label'] as String?;
        if (name != null) {
          allBadges.add(name);
        }
      }
    }
    
    // General skills
    if (candidate.skills.isNotEmpty) {
      allBadges.addAll(candidate.skills);
    }

    // Job title or position the candidate is looking for
    final positionTitle = candidate.jobTitle ?? 'Candidat';
    
    // Location (placeholder - you may want to add location to UserModel)
    final location = 'Paris, France'; // TODO: Add location field to UserModel
    
    // Experience (placeholder - you may want to add experience to UserModel)
    final experience = '2–3 ans d\'expérience'; // TODO: Add experience field to UserModel

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (widget.isFavorite)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF21D0C3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.bookmark, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('Favori', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
          // Background: candidate photo or gradient placeholder
          if (profileImage != null)
            Image(
              image: profileImage,
              fit: BoxFit.cover,
              height: 400,
              errorBuilder: (context, error, stackTrace) {
                return _buildGradientBackground();
              },
            )
          else
            _buildGradientBackground(),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const <double>[0, 0.6, 1],
              ),
            ),
          ),
          // Content overlay
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Candidate info row with avatar and name
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImage,
                      child: profileImage == null
                          ? Text(
                              candidate.initials,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        candidate.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    CompatibilityPill(score: widget.compatibilityScore),
                  ],
                ),
                const SizedBox(height: 16),
                // Position title (what the candidate is looking for)
                Text(
                  positionTitle.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                // Location and experience
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$location · $experience',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Badges wrap with turquoise styling
                if (allBadges.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allBadges.take(10).map((String badge) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF21D0C3).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFF21D0C3).withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade400,
            Colors.pink.shade400,
          ],
        ),
      ),
    );
  }
}
