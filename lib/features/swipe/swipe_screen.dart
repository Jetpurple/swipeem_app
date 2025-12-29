import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hire_me/design_system/modules/swipe_card.dart';
import 'package:hire_me/providers/job_provider.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/services/firebase_subscription_service.dart';
import 'package:hire_me/services/firebase_swipe_service.dart';
import 'package:hire_me/services/storage_service.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen>
    with TickerProviderStateMixin {
  final List<_JobCardData> _cards = <_JobCardData>[
    const _JobCardData(
      imageUrl:
          "https://images.unsplash.com/photo-1511919884226-fd3cad34687c?q=80&w=1200",
      company: 'Gueudet',
      title: "Chef des ventes véhicules d'occasion H/F",
      tags: <String>['CDI', 'Amiens', 'France', '80', 'Audi'],
      badges: <String>[
        'Leader',
        "Esprit d'équipe",
        'Relationnel',
        'Expertise Auto',
        'Négociation',
        'Management',
        'Exp. similaire',
        'Bac+5',
      ],
      compatibilityScore: 82,
    ),
  ];

  bool _cardsHydrated = false;

  final List<_JobCardData> _dismissed = <_JobCardData>[];
  final List<_JobCardData> _favorites = <_JobCardData>[];
  final List<String> _superLikedIds = <String>[];

  void _onAction(String action) {
    if (action == 'rewind') {
      if (_dismissed.isEmpty) return;
      setState(() {
        _cards.insert(0, _dismissed.removeLast());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revenir en arrière')),
      );
      return;
    }

    if (_cards.isEmpty) return;
    final current = _cards.first;

    setState(() {
      _dismissed.add(current);
      _cards.removeAt(0);
      if (action == 'save') {
        _favorites.add(current);
      }
      if (action == 'superlike') {
        _superLikedIds.add(current.title);
      }
    });

    // Persistance Firestore
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;
      // Map demo card to Firestore shape when available
      final jobId = current.firestoreJobId ?? current.title;
      final companyId = current.firestoreCompanyId ?? current.company;
      if (action == 'save') {
        FirebaseSwipeService.addFavorite(uid: uid, jobId: jobId);
      }
      if (action == 'like' || action == 'pass' || action == 'superlike') {
        FirebaseSwipeService.recordSwipe(
          fromUid: uid,
          toEntityId: companyId,
          type: 'candidate→job',
          value: action == 'like' ? 'like' : action == 'pass' ? 'pass' : 'superlike',
        );
      }
    }

    switch (action) {
      case 'pass':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refus')),
        );
      case 'save':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajouté aux favoris')),
        );
      case 'like':
        // TODO: Check for match and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match potentiel !')),
        );
      case 'superlike':
        // TODO: Check for match and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Super Like envoyé')),
        );
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action: $action')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobOffersAsync = ref.watch(jobOffersProvider);
    return jobOffersAsync.when(
      data: (jobOffers) {
        if (!_cardsHydrated && jobOffers.isNotEmpty) {
          _cardsHydrated = true;
          final mapped = jobOffers.take(10).map((j) => _JobCardData(
                imageUrl: j['imageUrl'] as String? ??
                    'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?q=80&w=1200',
                company: (j['company'] as String?) ?? 'Entreprise',
                title: (j['title'] as String?) ?? 'Offre',
                tags: <String>[(j['location'] as String?) ?? 'Ville'],
                badges: List<String>.from((j['requirements'] as List<dynamic>?) ?? const <String>[]),
                compatibilityScore: 80,
                firestoreJobId: j['id'] as String?,
                firestoreCompanyId: j['postedBy'] as String?,
              )).toList();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _cards.insertAll(0, mapped);
            });
          });
        }

        final currentUserAsync = ref.watch(currentUserProvider);
        final currentUser = currentUserAsync.value;
        final photoUrl = currentUser?.profileImageUrl;
        
        return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/ui/logo1_withoutbg.png',
          height: 100,
          fit: BoxFit.contain,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              key: ValueKey(photoUrl ?? 'no-photo'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Builder(
                builder: (_) {
                  final imageProvider = StorageService.resolveProfileImage(photoUrl);
                  return CircleAvatar(
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? const Icon(Icons.person)
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: _cards.isEmpty
                  ? const Center(child: Text("Plus d'offres pour le moment"))
                  : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                      stream: _favoriteDocStream(_cards.first.firestoreJobId),
                      builder: (context, snapshot) {
                        final isFav = snapshot.hasData && (snapshot.data?.exists ?? false);
                        return Column(
                          children: <Widget>[
                            Expanded(
                              child: _TinderStack(
                                cards: _cards,
                                onLike: () => _onAction('like'),
                                onPass: () => _onAction('pass'),
                                onSuperLike: () => _onAction('superlike'),
                                favoriteStates: _cards.asMap().entries.map((e) {
                                  final jobId = e.value.firestoreJobId;
                                  return jobId != null ? _favoriteDocStream(jobId) : const Stream<DocumentSnapshot<Map<String, dynamic>>?>.empty();
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () async {
                                  final user = FirebaseAuth.instance.currentUser;
                                  final jobId = _cards.first.firestoreJobId;
                                  if (user == null || jobId == null) return;
                                  if (isFav) {
                                    await FirebaseSwipeService.removeFavorite(uid: user.uid, jobId: jobId);
                                  } else {
                                    await FirebaseSwipeService.addFavorite(uid: user.uid, jobId: jobId);
                                  }
                                },
                                icon: Icon(isFav ? Icons.bookmark_remove : Icons.bookmark_add, color: Colors.teal),
                                label: Text(isFav ? 'Retirer des favoris' : 'Ajouter aux favoris'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder<bool>(
                  stream: ref.watch(currentUserIdProvider) != null 
                      ? FirebaseSubscriptionService.isPremiumStream(ref.watch(currentUserIdProvider)!)
                      : Stream.value(false),
                  builder: (context, snapshot) {
                    final isPremium = snapshot.data ?? false;
                    return _ActionCircle(
                      icon: Icons.undo,
                      color: Colors.orange,
                      onTap: isPremium
                          ? () => _onAction('rewind')
                          : () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Revenir en arrière est réservé aux comptes Premium'),
                                ),
                              ),
                    );
                  },
                ),
                _ActionCircle(
                  icon: Icons.close,
                  color: Colors.red,
                  onTap: () => _onAction('pass'),
                ),
                _ActionCircle(
                  icon: Icons.bookmark_add_outlined,
                  color: Colors.teal,
                  onTap: () => _onAction('save'),
                ),
                _ActionCircle(
                  icon: Icons.handshake,
                  color: theme.colorScheme.primary,
                  onTap: () => _onAction('like'),
                ),
                _ActionCircle(
                  icon: Icons.bolt,
                  color: Colors.amber.shade700,
                  onTap: () => _onAction('superlike'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

// Helpers
Stream<DocumentSnapshot<Map<String, dynamic>>?> _favoriteDocStream(String? jobId) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || jobId == null) {
    return const Stream<DocumentSnapshot<Map<String, dynamic>>?>.empty();
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('favorites')
      .doc(jobId)
      .snapshots();
}

/// Widget qui affiche une pile de cartes style Tinder avec effet de flou
class _TinderStack extends StatefulWidget {
  const _TinderStack({
    required this.cards,
    required this.onLike,
    required this.onPass,
    required this.onSuperLike,
    required this.favoriteStates,
  });

  final List<_JobCardData> cards;
  final VoidCallback onLike;
  final VoidCallback onPass;
  final VoidCallback onSuperLike;
  final List<Stream<DocumentSnapshot<Map<String, dynamic>>?>> favoriteStates;

  @override
  State<_TinderStack> createState() => _TinderStackState();
}

class _TinderStackState extends State<_TinderStack> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  
  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_TinderStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animer la transition quand une carte est retirée ou ajoutée (rewind)
    if ((oldWidget.cards.length > widget.cards.length || oldWidget.cards.length < widget.cards.length) && widget.cards.isNotEmpty) {
      _scaleController.forward(from: 0).then((_) {
        _scaleController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const Center(child: Text("Plus d'offres pour le moment"));
    }

    // Afficher jusqu'à 2 cartes : la principale et celle derrière
    final visibleCards = widget.cards.take(2).toList();
    
    // Construire les cartes en ordre inverse pour que la principale soit au-dessus
    final cardWidgets = <Widget>[];
    
    // D'abord la carte derrière (si elle existe)
    if (visibleCards.length > 1) {
      final backCard = visibleCards[1];
      cardWidgets.add(
        Positioned(
          top: 8.0,
          left: 8.0,
          right: -8.0,
          bottom: -8.0,
          child: IgnorePointer(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
              stream: widget.favoriteStates.length > 1 ? widget.favoriteStates[1] : const Stream<DocumentSnapshot<Map<String, dynamic>>?>.empty(),
              builder: (context, snapshot) {
                final isFav = snapshot.hasData && (snapshot.data?.exists ?? false);
                return Transform.scale(
                  scale: 0.95,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Opacity(
                      opacity: 0.8,
                      child: SwipeCard(
                        imageUrl: backCard.imageUrl,
                        company: backCard.company,
                        title: backCard.title,
                        tags: backCard.tags,
                        badges: backCard.badges,
                        compatibilityScore: backCard.compatibilityScore,
                        onLike: () {}, // Non interactive
                        onPass: () {},
                        onSuperLike: () {},
                        isFavorite: isFav,
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
    if (visibleCards.isNotEmpty) {
      final frontCard = visibleCards[0];
      cardWidgets.add(
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
          stream: widget.favoriteStates.isNotEmpty ? widget.favoriteStates[0] : const Stream<DocumentSnapshot<Map<String, dynamic>>?>.empty(),
          builder: (context, snapshot) {
            final isFav = snapshot.hasData && (snapshot.data?.exists ?? false);
            return AnimatedBuilder(
              animation: _scaleController,
              builder: (context, child) {
                final scale = 1.0 - (_scaleController.value * 0.05);
                return Transform.scale(
                  scale: scale,
                  child: SwipeCard(
                    imageUrl: frontCard.imageUrl,
                    company: frontCard.company,
                    title: frontCard.title,
                    tags: frontCard.tags,
                    badges: frontCard.badges,
                    compatibilityScore: frontCard.compatibilityScore,
                    onLike: widget.onLike,
                    onPass: widget.onPass,
                    onSuperLike: widget.onSuperLike,
                    isFavorite: isFav,
                  ),
                );
              },
            );
          },
        ),
      );
    }
    
    return Stack(
      children: cardWidgets,
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: CircleAvatar(
        radius: 34,
        backgroundColor: Colors.black,
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}

class _JobCardData {
  const _JobCardData({
    required this.imageUrl,
    required this.company,
    required this.title,
    required this.tags,
    required this.badges,
    required this.compatibilityScore,
    this.firestoreJobId,
    this.firestoreCompanyId,
  });

  final String imageUrl;
  final String company;
  final String title;
  final List<String> tags;
  final List<String> badges;
  final int compatibilityScore;
  final String? firestoreJobId;
  final String? firestoreCompanyId;

  // No demo mapping anymore
}
