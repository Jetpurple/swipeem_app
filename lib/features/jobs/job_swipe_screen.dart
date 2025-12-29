import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/design_system/widgets/match_animation.dart';
import 'package:hire_me/models/message_model.dart';
import 'package:hire_me/providers/job_provider.dart';
import 'package:hire_me/providers/message_provider.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/services/firebase_match_service.dart';
import 'package:hire_me/services/firebase_swipe_service.dart';

class JobSwipeScreen extends ConsumerStatefulWidget {
  const JobSwipeScreen({super.key});

  @override
  ConsumerState<JobSwipeScreen> createState() => _JobSwipeScreenState();
}

class _JobSwipeScreenState extends ConsumerState<JobSwipeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  // Garde pour éviter les appels multiples à l'animation
  final Set<String> _shownMatchIds = {};
  Set<String> _previousMatchIds = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Ne configurer le listener qu'une seule fois
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Initialiser la liste précédente avec les matches actuels
    final matchesAsync = ref.read(userMatchesProvider);
    matchesAsync.whenData((matches) {
      if (mounted) {
        _previousMatchIds = matches.map((m) => m.id).toSet();
      }
    });
    
    // Écouter les matches de manière sûre avec ref.listen
    // didChangeDependencies est appelé après le premier build, donc c'est sûr
    ref.listen(userMatchesProvider, (previous, next) {
      if (!mounted) return;
      
      next.whenData((matches) {
        if (!mounted) return;
        
        // Comparer avec les matches précédents pour détecter les nouveaux
        final currentMatchIds = matches.map((m) => m.id).toSet();
        
        // Trouver les nouveaux matches (présents maintenant mais pas avant)
        final newMatchIds = currentMatchIds.difference(_previousMatchIds);
        
        if (newMatchIds.isNotEmpty) {
          // Traiter chaque nouveau match de manière asynchrone
          Future.microtask(() {
            if (!mounted) return;
            
            for (final matchId in newMatchIds) {
              // Vérifier qu'on n'a pas déjà affiché ce match
              if (_shownMatchIds.contains(matchId)) continue;
              
              // Trouver le match correspondant
              final newMatch = matches.firstWhere((m) => m.id == matchId);
              
              // Trouver l'offre correspondante si disponible
              Map<String, dynamic>? jobOffer;
              if (newMatch.jobOfferId != null) {
                final jobOfferAsync = ref.read(jobOfferProvider(newMatch.jobOfferId!));
                jobOffer = jobOfferAsync.value;
              }
              
              // Gérer l'animation de manière sûre (hors du callback synchrone)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _handleNewMatch(newMatch, jobOffer);
                }
              });
            }
          });
        }
        
        // Mettre à jour la liste précédente (sans causer de rebuild)
        _previousMatchIds = currentMatchIds;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // Méthode pour gérer l'animation de match de manière sûre
  // Cette méthode est appelée depuis addPostFrameCallback dans le listener
  void _handleNewMatch(MatchModel match, Map<String, dynamic>? jobOffer) {
    // Vérifier que le match n'a pas déjà été affiché (double vérification)
    if (_shownMatchIds.contains(match.id)) {
      return;
    }
    
    // Marquer le match comme affiché IMMÉDIATEMENT pour éviter les appels multiples
    _shownMatchIds.add(match.id);
    
    // Utiliser Future.microtask pour s'assurer qu'on est bien après le build
    Future.microtask(() async {
      if (!mounted) return;
      
      // Récupérer les informations du candidat pour l'animation
      final currentUser = ref.read(currentUserProvider).value;
      final candidateName = currentUser != null
          ? '${currentUser.firstName} ${currentUser.lastName}'
          : 'Candidat';
      final candidatePhotoUrl = currentUser?.profileImageUrl;
      
      // Récupérer les informations de l'offre si disponibles
      String offerTitle = 'Offre d\'emploi';
      String companyName = 'Entreprise';
      
      if (jobOffer != null) {
        offerTitle = jobOffer['title'] as String? ?? offerTitle;
        companyName = jobOffer['company'] as String? ?? companyName;
      } else if (match.jobOfferId != null) {
        // Essayer de récupérer l'offre depuis le provider
        final jobOfferAsync = ref.read(jobOfferProvider(match.jobOfferId!));
        final jobOfferData = jobOfferAsync.value;
        if (jobOfferData != null) {
          offerTitle = jobOfferData['title'] as String? ?? offerTitle;
          companyName = jobOfferData['company'] as String? ?? companyName;
        }
      }
      
      if (!mounted) return;
      
      // Afficher l'animation de match (jamais dans build())
      await showMatchAnimation(
        context,
        candidateName: candidateName,
        offerTitle: offerTitle,
        companyName: companyName,
        candidatePhotoUrl: candidatePhotoUrl,
        companyLogoUrl: null,
        onViewDetails: () {
          // Naviguer vers la conversation
          context.go('/chat?matchId=${match.id}');
        },
        onContinue: () {
          // Continuer à swiper
          final jobOffersAsync = ref.read(jobOffersProvider);
          final jobOffers = jobOffersAsync.value ?? [];
          if (_currentIndex < jobOffers.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            // Plus d'offres
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Plus d'offres pour le moment !"),
              ),
            );
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobOffersAsync = ref.watch(jobOffersProvider);
    // Ne pas watch userMatchesProvider ici, on utilise ref.listen dans initState

    return jobOffersAsync.when(
      data: (jobOffers) {
        if (jobOffers.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Logo1(height: 100, fit: BoxFit.contain)),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune offre disponible',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Logo1(height: 100, fit: BoxFit.contain),
            actions: [
              Text('${_currentIndex + 1}/${jobOffers.length}'),
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
            itemCount: jobOffers.length,
            itemBuilder: (context, index) {
              final job = jobOffers[index];
              return _JobCard(job: job);
            },
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SwipeButton(
                  icon: Icons.close,
                  color: Colors.red,
                  onTap: () => _swipeJob(false),
                ),
                _SwipeButton(
                  icon: Icons.favorite,
                  color: Colors.green,
                  onTap: () => _swipeJob(true),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Logo1(height: 100, fit: BoxFit.contain)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Logo1(height: 100, fit: BoxFit.contain)),
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Future<void> _swipeJob(bool isLiked) async {
    final jobOffersAsync = ref.read(jobOffersProvider);
    final jobOffers = jobOffersAsync.value ?? [];
    
    if (_currentIndex < jobOffers.length) {
      final job = jobOffers[_currentIndex];
      
      try {
        final companyUid = job['postedBy'] as String?;
        final jobOfferId = job['id'] as String?;
        final currentUserId = ref.read(currentUserIdProvider);
        
        if (currentUserId == null || companyUid == null) {
          return;
        }
        
        // Enregistrer le swipe
        await FirebaseSwipeService.recordSwipe(
          fromUid: currentUserId,
          toEntityId: companyUid,
          type: 'candidate→job',
          value: isLiked ? 'like' : 'pass',
        );
        
        if (isLiked) {
          // Créer un match avec l'entreprise qui a posté l'offre
          // L'animation sera déclenchée automatiquement par le listener sur userMatchesProvider
          await FirebaseMatchService.createMatch(
            candidateUid: currentUserId,
            recruiterUid: companyUid,
            jobOfferId: jobOfferId,
          );
          
          // Continuer à swiper après un court délai pour laisser le match se créer
          if (mounted) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            if (_currentIndex < jobOffers.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        } else {
          // Pas de match, continuer à swiper
          if (mounted) {
            if (_currentIndex < jobOffers.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              // Plus d'offres
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Plus d'offres pour le moment !"),
                ),
              );
            }
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

class _JobCard extends StatelessWidget {

  const _JobCard({required this.job});
  final Map<String, dynamic> job;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job['company'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job['salary'] as String,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job['location'] as String,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job['description'] as String,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Compétences requises',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (job['requirements'] as List<dynamic>)
                  .map((req) => Chip(
                        label: Text(req as String),
                        backgroundColor: const Color(0xFF5271FF).withOpacity(0.1),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Avantages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (job['benefits'] as List<dynamic>)
                  .map((benefit) => Chip(
                        label: Text(benefit as String),
                        backgroundColor: Colors.orange.withOpacity(0.1),
                      ))
                  .toList(),
            ),
            ],
          ),
        ),
      ),
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