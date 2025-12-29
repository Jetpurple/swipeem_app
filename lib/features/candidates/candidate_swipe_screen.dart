import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/providers/job_provider.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/services/firebase_match_service.dart';
import 'package:hire_me/services/firebase_subscription_service.dart';
import 'package:hire_me/services/firebase_swipe_service.dart';

class CandidateSwipeScreen extends ConsumerStatefulWidget {
  const CandidateSwipeScreen({super.key});

  @override
  ConsumerState<CandidateSwipeScreen> createState() => _CandidateSwipeScreenState();
}

class _CandidateSwipeScreenState extends ConsumerState<CandidateSwipeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final List<dynamic> _dismissedCandidates = []; // Pour stocker les candidats rejetés

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidatesAsync = ref.watch(candidatesProvider);

    return candidatesAsync.when(
      data: (candidates) {
        if (candidates.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Logo1(height: 28, fit: BoxFit.contain)),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun candidat disponible',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Logo1(height: 28, fit: BoxFit.contain),
            actions: [
              Text('${_currentIndex + 1}/${candidates.length}'),
              const SizedBox(width: 16),
            ],
          ),
          body: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              return Column(
                children: [
                  Expanded(child: _CandidateCard(candidate: candidate)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _FavoriteToggle(candidateUid: candidate.uid as String),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StreamBuilder<bool>(
                  stream: ref.watch(currentUserIdProvider) != null 
                      ? FirebaseSubscriptionService.isPremiumStream(ref.watch(currentUserIdProvider)!)
                      : Stream.value(false),
                  builder: (context, snapshot) {
                    final isPremium = snapshot.data ?? false;
                    return _SwipeButton(
                      icon: Icons.undo,
                      color: Colors.orange,
                      onTap: isPremium
                          ? () {
                              if (_dismissedCandidates.isNotEmpty) {
                                setState(_dismissedCandidates.removeLast);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Revenir en arrière')),
                                );
                              }
                            }
                          : () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Revenir en arrière est réservé aux comptes Premium'),
                                ),
                              ),
                    );
                  },
                ),
                _SwipeButton(
                  icon: Icons.close,
                  color: Colors.red,
                  onTap: () => _swipeCandidate(false),
                ),
                _SwipeButton(
                  icon: Icons.favorite,
                  color: Colors.green,
                  onTap: () => _swipeCandidate(true),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Logo1(height: 28, fit: BoxFit.contain)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Logo1(height: 28, fit: BoxFit.contain)),
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Future<void> _swipeCandidate(bool isLiked) async {
    final candidatesAsync = ref.read(candidatesProvider);
    final candidates = candidatesAsync.value ?? [];
    
    if (_currentIndex < candidates.length) {
      final candidate = candidates[_currentIndex];
      
      try {
        if (isLiked) {
          final currentUserId = ref.read(currentUserIdProvider);
          
          if (currentUserId != null) {
            await FirebaseMatchService.createMatch(
              candidateUid: candidate.uid as String,
              recruiterUid: currentUserId,
            );
          }
        }

        // Persistance: swipes/favoris côté recruteur
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          if (isLiked) {
            await FirebaseSwipeService.recordSwipe(
              fromUid: user.uid,
              toEntityId: candidate.uid as String,
              type: 'recruiter→candidate',
              value: 'like',
            );
          } else {
            await FirebaseSwipeService.recordSwipe(
              fromUid: user.uid,
              toEntityId: candidate.uid as String,
              type: 'recruiter→candidate',
              value: 'pass',
            );
          }
        }
        
        if (mounted) {
          if (isLiked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Match ! Vous pouvez maintenant discuter avec le candidat'),
                backgroundColor: Colors.green,
              ),
            );
          }
          
        // Ajouter aux candidats rejetés et passer au suivant
        setState(() {
          _dismissedCandidates.add(candidate);
        });
        
        if (_currentIndex < candidates.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          // Plus de candidats
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plus de candidats pour le moment !'),
            ),
          );
        }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _CandidateCard extends StatelessWidget {

  const _CandidateCard({required this.candidate});
  final dynamic candidate;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _getAvatarColor(candidate.firstName as String),
                  child: Text(
                    '${candidate.firstName[0]}${candidate.lastName[0]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${candidate.firstName} ${candidate.lastName}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        candidate.email as String,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5271FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Candidat',
                          style: TextStyle(
                            color: Color(0xFF5271FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (candidate.skills != null && (candidate.skills as List).isNotEmpty) ...[
              const Text(
                'Compétences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (candidate.skills as List<dynamic>)
                    .map<Widget>((skill) => Chip(
                          label: Text(skill as String),
                          backgroundColor: Colors.green.withOpacity(0.1),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              'Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Candidat motivé avec de l'expérience en développement mobile. "
              'Recherche une opportunité de rejoindre une équipe dynamique et '
              'de contribuer à des projets innovants.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Membre depuis ${_getDaysSince(candidate.createdAt as DateTime)} jours',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF5271FF),
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  int _getDaysSince(DateTime date) {
    return DateTime.now().difference(date).inDays;
  }
}

class _FavoriteToggle extends StatelessWidget {
  const _FavoriteToggle({required this.candidateUid});
  final String candidateUid;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('candidateFavorites')
        .doc(candidateUid);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        final isFav = snapshot.hasData && snapshot.data!.exists;
        return TextButton.icon(
          onPressed: () async {
            if (isFav) {
              await FirebaseSwipeService.removeCandidateFavorite(
                recruiterUid: user.uid,
                candidateUid: candidateUid,
              );
            } else {
              await FirebaseSwipeService.addCandidateFavorite(
                recruiterUid: user.uid,
                candidateUid: candidateUid,
              );
            }
          },
          icon: Icon(isFav ? Icons.bookmark_remove : Icons.bookmark_add, color: Colors.teal),
          label: Text(isFav ? 'Retirer des favoris' : 'Ajouter aux favoris'),
        );
      },
    );
  }
}

class _SwipeButton extends StatelessWidget {

  const _SwipeButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}