import 'package:flutter/material.dart';

/// Affiche une animation de match plein écran avec une carte animée
/// 
/// Exemple d'utilisation :
/// ```dart
/// await showMatchAnimation(
///   context,
///   candidateName: 'Marie Dupont',
///   offerTitle: 'Développeur Flutter Senior',
///   companyName: 'TechCorp France',
///   candidatePhotoUrl: candidate.profileImageUrl,
///   companyLogoUrl: null,
///   onViewDetails: () {
///     Navigator.push(context, MaterialPageRoute(
///       builder: (_) => ChatRoomScreen(matchId: matchId),
///     ));
///   },
///   onContinue: () {
///     // Retour au swipe
///   },
/// );
/// ```
Future<void> showMatchAnimation(
  BuildContext context, {
  required String candidateName,
  required String offerTitle,
  required String companyName,
  String? candidatePhotoUrl,
  String? companyLogoUrl,
  VoidCallback? onViewDetails,
  VoidCallback? onContinue,
}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _MatchAnimationOverlay(
        candidateName: candidateName,
        offerTitle: offerTitle,
        companyName: companyName,
        candidatePhotoUrl: candidatePhotoUrl,
        companyLogoUrl: companyLogoUrl,
        onViewDetails: onViewDetails,
        onContinue: onContinue,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
  return;
}

/// Widget interne pour l'animation de match
class _MatchAnimationOverlay extends StatefulWidget {
  final String candidateName;
  final String offerTitle;
  final String companyName;
  final String? candidatePhotoUrl;
  final String? companyLogoUrl;
  final VoidCallback? onViewDetails;
  final VoidCallback? onContinue;

  const _MatchAnimationOverlay({
    required this.candidateName,
    required this.offerTitle,
    required this.companyName,
    this.candidatePhotoUrl,
    this.companyLogoUrl,
    this.onViewDetails,
    this.onContinue,
  });

  @override
  State<_MatchAnimationOverlay> createState() => _MatchAnimationOverlayState();
}

class _MatchAnimationOverlayState extends State<_MatchAnimationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _breathingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    // Animation principale de la carte (scale + rotation)
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.1), weight: 0.6),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 0.4),
    ]).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeOutBack,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.15, // ~8.6 degrés en radians
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animation de "respiration" continue
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    // Démarrer l'animation principale
    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _handleViewDetails() {
    Navigator.of(context).pop();
    widget.onViewDetails?.call();
  }

  void _handleContinue() {
    Navigator.of(context).pop();
    widget.onContinue?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B6B).withOpacity(0.9),
              const Color(0xFFFF8E53).withOpacity(0.9),
              const Color(0xFFFF6B9D).withOpacity(0.9),
              const Color(0xFFC44569).withOpacity(0.9),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Espace en haut
              const Spacer(flex: 2),
              
              // Carte de match animée
              Builder(
                builder: (context) {
                  // Construire la carte une seule fois
                  final matchCard = _MatchCard(
                    candidateName: widget.candidateName,
                    offerTitle: widget.offerTitle,
                    companyName: widget.companyName,
                    candidatePhotoUrl: widget.candidatePhotoUrl,
                    companyLogoUrl: widget.companyLogoUrl,
                  );
                  
                  return AnimatedBuilder(
                    animation: _cardController,
                    child: matchCard,
                    builder: (context, child) {
                      return AnimatedBuilder(
                        animation: _breathingController,
                        child: child,
                        builder: (context, child) {
                          final combinedScale = _scaleAnimation.value * _breathingAnimation.value;
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(combinedScale)
                              ..rotateX(_rotationAnimation.value)
                              ..rotateY(_rotationAnimation.value * 0.5),
                            child: child,
                          );
                        },
                      );
                    },
                  );
                },
              ),
              
              // Espace au milieu
              const Spacer(flex: 2),
              
              // Boutons d'action
              _ActionButtons(
                onViewDetails: _handleViewDetails,
                onContinue: _handleContinue,
              ),
              
              // Espace en bas
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte de match avec avatar candidat, icône, et logo entreprise
class _MatchCard extends StatelessWidget {
  final String candidateName;
  final String offerTitle;
  final String companyName;
  final String? candidatePhotoUrl;
  final String? companyLogoUrl;

  const _MatchCard({
    required this.candidateName,
    required this.offerTitle,
    required this.companyName,
    this.candidatePhotoUrl,
    this.companyLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titre principal
          const Text(
            "C'est un match !",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Sous-titre
          Text(
            '$candidateName x $companyName',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Contenu : Avatar candidat + Icône match + Logo entreprise
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar candidat
              _AvatarWidget(
                name: candidateName,
                photoUrl: candidatePhotoUrl,
                size: 80,
              ),
              
              // Icône de match
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFFFF8E53),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              // Logo entreprise (ou placeholder)
              _CompanyLogoWidget(
                companyName: companyName,
                logoUrl: companyLogoUrl,
                size: 80,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Détails de l'offre
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  offerTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  companyName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour l'avatar du candidat
class _AvatarWidget extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double size;

  const _AvatarWidget({
    required this.name,
    this.photoUrl,
    required this.size,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5271FF),
            const Color(0xFF6C5CE7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5271FF).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                photoUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsAvatar();
                },
              ),
            )
          : _buildInitialsAvatar(),
    );
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        _getInitials(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.35,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Widget pour le logo de l'entreprise
class _CompanyLogoWidget extends StatelessWidget {
  final String companyName;
  final String? logoUrl;
  final double size;

  const _CompanyLogoWidget({
    required this.companyName,
    this.logoUrl,
    required this.size,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF8E53),
            const Color(0xFFFF6B9D),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8E53).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: logoUrl != null && logoUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                logoUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsLogo();
                },
              ),
            )
          : _buildInitialsLogo(),
    );
  }

  Widget _buildInitialsLogo() {
    return Center(
      child: Text(
        _getInitials(companyName),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.35,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Boutons d'action en bas de l'overlay
class _ActionButtons extends StatelessWidget {
  final VoidCallback? onViewDetails;
  final VoidCallback? onContinue;

  const _ActionButtons({
    this.onViewDetails,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Bouton principal : "Voir la fiche"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2D3436),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Text(
                'Voir la fiche',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bouton secondaire : "Continuer à swiper"
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onContinue,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Continuer à swiper',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

