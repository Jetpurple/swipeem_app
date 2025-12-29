import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/modules/candidate_swipe_card.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/models/user_model.dart';
import 'package:hire_me/providers/job_provider.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/services/firebase_match_service.dart';
import 'package:hire_me/services/firebase_subscription_service.dart';
import 'package:hire_me/services/firebase_swipe_service.dart';
import 'package:hire_me/services/storage_service.dart';

class RecruiterSwipeScreen extends ConsumerStatefulWidget {
  const RecruiterSwipeScreen({super.key});

  @override
  ConsumerState<RecruiterSwipeScreen> createState() => _RecruiterSwipeScreenState();
}

class _RecruiterSwipeScreenState extends ConsumerState<RecruiterSwipeScreen>
    with TickerProviderStateMixin {
  final List<UserModel> _candidates = <UserModel>[];
  final List<UserModel> _dismissed = <UserModel>[];
  final List<String> _superLikedIds = <String>[];
  bool _cardsHydrated = false;
  bool _isBioExpanded = false;

  late AnimationController _scaleController;
  late AnimationController _bioAnimationController;
  late Animation<double> _cardTranslateAnimation;
  late Animation<double> _bioFadeAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bioAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _cardTranslateAnimation = Tween<double>(
      begin: 0.0,
      end: -140.0,
    ).animate(CurvedAnimation(
      parent: _bioAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _bioFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bioAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bioAnimationController.dispose();
    super.dispose();
  }

  void _toggleBio() {
    setState(() {
      _isBioExpanded = !_isBioExpanded;
      if (_isBioExpanded) {
        _bioAnimationController.forward();
      } else {
        _bioAnimationController.reverse();
      }
    });
  }

  void _onAction(String action) {
    // Close bio if open
    if (_isBioExpanded) {
      _toggleBio();
    }
    
    if (action == 'rewind') {
      if (_dismissed.isEmpty) return;
      setState(() {
        _candidates.insert(0, _dismissed.removeLast());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revenir en arrière')),
      );
      return;
    }

    if (_candidates.isEmpty) return;
    final current = _candidates.first;

    setState(() {
      _dismissed.add(current);
      _candidates.removeAt(0);
      if (action == 'superlike') {
        _superLikedIds.add(current.uid);
      }
    });

    // Persistance Firestore
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;
      final recruiterDocId = currentUser.email ?? uid;
      final candidateUid = current.uid;
      
      if (action == 'save') {
        FirebaseSwipeService.addCandidateFavorite(
          recruiterUid: recruiterDocId,
          candidateUid: candidateUid,
        );
      }
      if (action == 'like' || action == 'pass' || action == 'superlike') {
        FirebaseSwipeService.recordSwipe(
          fromUid: uid,
          toEntityId: candidateUid,
          type: 'recruiter→candidate',
          value: action == 'like' ? 'like' : action == 'pass' ? 'pass' : 'superlike',
        );
        
        // Create match if like or superlike
        if (action == 'like' || action == 'superlike') {
          FirebaseMatchService.createMatch(
            candidateUid: candidateUid,
            recruiterUid: uid,
          ).then((matchId) {
            if (matchId.isNotEmpty && mounted) {
              context.push('/match-success?matchId=$matchId&otherUserId=$candidateUid');
            }
          }).catchError((Object e) {
            print('⚠️ Erreur lors de la création du match: $e');
            return '';
          });
        }
      }
    }

    switch (action) {
      case 'pass':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Candidat refusé')),
        );
      case 'save':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajouté à la short-list')),
        );
      case 'like':
        // Navigation handled in createMatch callback
        break;
      case 'superlike':
        // Navigation handled in createMatch callback
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action: $action')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final candidatesAsync = ref.watch(candidatesProvider);
    
    return candidatesAsync.when(
      data: (candidates) {
        if (!_cardsHydrated && candidates.isNotEmpty) {
          _cardsHydrated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _candidates.addAll(candidates.take(20));
            });
          });
        }

        final currentUserAsync = ref.watch(currentUserProvider);
        final currentUser = currentUserAsync.value;
        final photoUrl = currentUser?.profileImageUrl;

        return Scaffold(
          backgroundColor: const Color(0xFF05081B),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF05081B),
                  Color(0xFF0A1630),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Logo1(height: 80, fit: BoxFit.contain),
                        CircleAvatar(
                          key: ValueKey(photoUrl ?? 'no-photo'),
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          child: Builder(
                            builder: (_) {
                              final imageProvider = StorageService.resolveProfileImage(photoUrl);
                              return CircleAvatar(
                                backgroundImage: imageProvider,
                                child: imageProvider == null
                                    ? const Icon(Icons.person, color: Colors.white70)
                                    : null,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Swipe stack with bio section
                  Expanded(
                    child: _candidates.isEmpty
                        ? const Center(
                            child: Text(
                              "Plus de candidats pour le moment",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                            stream: _favoriteDocStream(_candidates.first.uid),
                            builder: (context, snapshot) {
                              final isFav = snapshot.hasData && (snapshot.data?.exists ?? false);
                              return Column(
                                children: <Widget>[
                                  // Card stack with animation
                                  Expanded(
                                    child: AnimatedBuilder(
                                      animation: _bioAnimationController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(0, _cardTranslateAnimation.value),
                                          child: _TinderStack(
                                            candidates: _candidates,
                                            onLike: () => _onAction('like'),
                                            onPass: () => _onAction('pass'),
                                            onSuperLike: () => _onAction('superlike'),
                                            favoriteStates: _candidates.map((c) {
                                              return _favoriteDocStream(c.uid);
                                            }).toList(),
                                            scaleController: _scaleController,
                                            onCardTap: _toggleBio,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Bio section (animated)
                                  AnimatedBuilder(
                                    animation: _bioAnimationController,
                                    builder: (context, child) {
                                      if (!_isBioExpanded || _candidates.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      return Opacity(
                                        opacity: _bioFadeAnimation.value,
                                        child: _BioSection(
                                          candidate: _candidates.first,
                                          onClose: _toggleBio,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  // Favorite button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          final user = FirebaseAuth.instance.currentUser;
                                          final candidateUid = _candidates.first.uid;
                                          if (user == null || candidateUid.isEmpty) return;
                                          final recruiterDocId = user.email ?? user.uid;
                                          if (isFav) {
                                            await FirebaseSwipeService.removeCandidateFavorite(
                                              recruiterUid: recruiterDocId,
                                              candidateUid: candidateUid,
                                            );
                                          } else {
                                            await FirebaseSwipeService.addCandidateFavorite(
                                              recruiterUid: recruiterDocId,
                                              candidateUid: candidateUid,
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          isFav ? Icons.bookmark_remove : Icons.person_add_alt_1_rounded,
                                          color: const Color(0xFF21D0C3),
                                          size: 18,
                                        ),
                                        label: Text(
                                          isFav ? 'Retirer de la short-list' : 'Ajouter à la short-list',
                                          style: const TextStyle(
                                            color: Color(0xFF21D0C3),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  // Circular action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        StreamBuilder<bool>(
                          stream: ref.watch(currentUserIdProvider) != null
                              ? FirebaseSubscriptionService.isPremiumStream(
                                  ref.watch(currentUserIdProvider)!)
                              : Stream.value(false),
                          builder: (context, snapshot) {
                            final isPremium = snapshot.data ?? false;
                            return _ActionCircle(
                              icon: Icons.undo_rounded,
                              color: Colors.orange,
                              onTap: isPremium
                                  ? () => _onAction('rewind')
                                  : () => ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Revenir en arrière est réservé aux comptes Premium'),
                                        ),
                                      ),
                            );
                          },
                        ),
                        _ActionCircle(
                          icon: Icons.close_rounded,
                          color: Colors.red,
                          onTap: () => _onAction('pass'),
                        ),
                        _ActionCircle(
                          icon: Icons.bookmark_border_rounded,
                          color: const Color(0xFF21D0C3),
                          onTap: () => _onAction('save'),
                        ),
                        _ActionCircle(
                          icon: Icons.layers_rounded,
                          color: theme.colorScheme.primary,
                          onTap: () {
                            if (_candidates.isNotEmpty) {
                              context.go('/candidate-detail?candidateUid=${_candidates.first.uid}');
                            }
                          },
                        ),
                        _ActionCircle(
                          icon: Icons.flash_on_rounded,
                          color: Colors.amber.shade700,
                          onTap: () => _onAction('superlike'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: const Color(0xFF05081B),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF05081B),
                Color(0xFF0A1630),
              ],
            ),
          ),
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF05081B),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF05081B),
                Color(0xFF0A1630),
              ],
            ),
          ),
          child: Center(
            child: Text(
              'Erreur: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// Bio section widget
class _BioSection extends StatelessWidget {
  const _BioSection({
    required this.candidate,
    required this.onClose,
  });

  final UserModel candidate;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  candidate.bio ?? 'Aucune description disponible pour le moment.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.expand_more_rounded,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helpers
Stream<DocumentSnapshot<Map<String, dynamic>>?> _favoriteDocStream(String candidateUid) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || candidateUid.isEmpty) {
    return const Stream<DocumentSnapshot<Map<String, dynamic>>?>.empty();
  }
  final userDocId = user.email ?? user.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userDocId)
      .collection('candidateFavorites')
      .doc(candidateUid)
      .snapshots();
}

/// Widget qui affiche une pile de cartes style Tinder avec effet de flou
class _TinderStack extends StatefulWidget {
  const _TinderStack({
    required this.candidates,
    required this.onLike,
    required this.onPass,
    required this.onSuperLike,
    required this.favoriteStates,
    required this.scaleController,
    this.onCardTap,
  });

  final List<UserModel> candidates;
  final VoidCallback onLike;
  final VoidCallback onPass;
  final VoidCallback onSuperLike;
  final List<Stream<DocumentSnapshot<Map<String, dynamic>>?>> favoriteStates;
  final AnimationController scaleController;
  final VoidCallback? onCardTap;

  @override
  State<_TinderStack> createState() => _TinderStackState();
}

class _TinderStackState extends State<_TinderStack> {
  @override
  void didUpdateWidget(_TinderStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animer la transition quand une carte est retirée ou ajoutée (rewind)
    if ((oldWidget.candidates.length > widget.candidates.length ||
         oldWidget.candidates.length < widget.candidates.length) &&
        widget.candidates.isNotEmpty) {
      widget.scaleController.forward(from: 0).then((_) {
        widget.scaleController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candidates.isEmpty) {
      return const Center(
        child: Text(
          "Plus de candidats pour le moment",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Afficher jusqu'à 2 cartes : la principale et celle derrière
    final visibleCandidates = widget.candidates.take(2).toList();

    // Construire les cartes en ordre inverse pour que la principale soit au-dessus
    final cardWidgets = <Widget>[];

    // D'abord la carte derrière (si elle existe)
    if (visibleCandidates.length > 1) {
      final backCandidate = visibleCandidates[1];
      cardWidgets.add(
        Positioned(
          top: 8.0,
          left: 8.0,
          right: -8.0,
          bottom: -8.0,
          child: IgnorePointer(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
              stream: widget.favoriteStates.length > 1
                  ? widget.favoriteStates[1]
                  : const Stream<DocumentSnapshot<Map<String, dynamic>>?>.empty(),
              builder: (context, snapshot) {
                final isFav = snapshot.hasData && (snapshot.data?.exists ?? false);
                return Transform.scale(
                  scale: 0.95,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Opacity(
                      opacity: 0.8,
                      child: CandidateSwipeCard(
                        candidate: backCandidate,
                        compatibilityScore: 80, // TODO: Calculate actual compatibility
                        onLike: () {}, // Non interactive
                        onPass: () {},
                        onSuperLike: () {},
                        isFavorite: isFav,
                        onTap: null, // Non interactive pour la carte du fond
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    // Ensuite la carte principale (au-dessus, nette)
    if (visibleCandidates.isNotEmpty) {
      final frontCandidate = visibleCandidates[0];
      cardWidgets.add(
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
          stream: widget.favoriteStates.isNotEmpty
              ? widget.favoriteStates[0]
              : const Stream<DocumentSnapshot<Map<String, dynamic>>?>.empty(),
          builder: (context, snapshot) {
            final isFav = snapshot.hasData && (snapshot.data?.exists ?? false);
            return AnimatedBuilder(
              animation: widget.scaleController,
              builder: (context, child) {
                final scale = 1.0 - (widget.scaleController.value * 0.05);
                return Transform.scale(
                  scale: scale,
                  child: CandidateSwipeCard(
                    candidate: frontCandidate,
                    compatibilityScore: 80, // TODO: Calculate actual compatibility
                    onLike: widget.onLike,
                    onPass: widget.onPass,
                    onSuperLike: widget.onSuperLike,
                    isFavorite: isFav,
                    onTap: widget.onCardTap,
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: cardWidgets,
      ),
    );
  }
}

class _ActionCircle extends StatefulWidget {
  const _ActionCircle({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ActionCircle> createState() => _ActionCircleState();
}

class _ActionCircleState extends State<_ActionCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 30),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
