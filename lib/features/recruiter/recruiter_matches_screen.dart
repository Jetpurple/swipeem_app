import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/models/user_model.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/services/storage_service.dart';

class RecruiterMatchesScreen extends ConsumerStatefulWidget {
  const RecruiterMatchesScreen({super.key});

  @override
  ConsumerState<RecruiterMatchesScreen> createState() => _RecruiterMatchesScreenState();
}

class _RecruiterMatchesScreenState extends ConsumerState<RecruiterMatchesScreen> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserIdProvider);
    
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Veuillez vous connecter')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Logo1(height: 100, fit: BoxFit.contain),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('matches')
            .where('recruiterUid', isEqualTo: uid)
            .where('isActive', isEqualTo: true)
            .orderBy('lastMessageAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur lors du chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final matches = snapshot.data?.docs ?? [];

          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aucun match pour le moment',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Continuez à publier des offres pour attirer des candidats',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/recruiter/job-offers'),
                    icon: const Icon(Icons.work),
                    label: const Text('Voir mes offres'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Carrousel des candidats matchés
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final data = match.data()! as Map<String, dynamic>;
                    final candidateUid = data['candidateUid'] as String;
                    
                    return _CandidateCard(
                      matchId: match.id,
                      candidateUid: candidateUid,
                      lastMessage: data['lastMessageContent'] as String?,
                      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
                      isUnread: (data['readBy'] as Map<String, bool>?)?[uid] != true,
                      onTap: () => _openChat(context, match.id, candidateUid),
                    );
                  },
                ),
              ),
              
              // Indicateurs de page
              if (matches.length > 1) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    matches.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Liste des conversations
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final data = match.data()! as Map<String, dynamic>;
                    final candidateUid = data['candidateUid'] as String;
                    final lastMessage = data['lastMessageContent'] as String?;
                    final lastMessageAt = (data['lastMessageAt'] as Timestamp?)?.toDate();
                    final readBy = data['readBy'] as Map<String, bool>?;
                    final isUnread = readBy != null ? !(readBy[uid] ?? false) : true;
                    
                    return _ConversationTile(
                      matchId: match.id,
                      candidateUid: candidateUid,
                      lastMessage: lastMessage,
                      lastMessageAt: lastMessageAt,
                      isUnread: isUnread,
                      onTap: () => _openChat(context, match.id, candidateUid),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openChat(BuildContext context, String matchId, String candidateUid) {
    // TODO: Implémenter l'ouverture du chat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ouvrir le chat avec $candidateUid')),
    );
  }
}

class _CandidateCard extends StatelessWidget {

  const _CandidateCard({
    required this.matchId,
    required this.candidateUid,
    required this.isUnread, required this.onTap, this.lastMessage,
    this.lastMessageAt,
  });
  final String matchId;
  final String candidateUid;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(candidateUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildLoadingCard();
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) {
            return _buildErrorCard();
          }

          final user = UserModel.fromFirestore(snapshot.data!);
          
          return GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Stack(
                children: [
                  // Photo de profil
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Builder(
                        builder: (_) {
                          final imageProvider = StorageService.resolveProfileImage(user.profileImageUrl);
                          if (imageProvider == null) {
                            return _buildDefaultAvatar();
                          }
                          return Image(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Overlay avec informations
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Informations du candidat
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user.jobTitle != null && user.jobTitle!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.jobTitle!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        if (lastMessage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              lastMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Indicateur de message non lu
                  if (isUnread)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.red.withOpacity(0.1),
      ),
      child: const Center(
        child: Icon(Icons.error, color: Colors.red),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return ColoredBox(
      color: Colors.grey.withOpacity(0.3),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {

  const _ConversationTile({
    required this.matchId,
    required this.candidateUid,
    required this.isUnread, required this.onTap, this.lastMessage,
    this.lastMessageAt,
  });
  final String matchId;
  final String candidateUid;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(candidateUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingTile();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) {
          return _buildErrorTile();
        }

        final user = UserModel.fromFirestore(snapshot.data!);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: onTap,
            leading: Builder(
              builder: (_) {
                final imageProvider = StorageService.resolveProfileImage(user.profileImageUrl);
                return CircleAvatar(
                  radius: 24,
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(Icons.person)
                      : null,
                );
              },
            ),
            title: Text(
              user.fullName,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.jobTitle != null && user.jobTitle!.isNotEmpty)
                  Text(
                    user.jobTitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                if (lastMessage != null)
                  Text(
                    lastMessage!,
                    style: TextStyle(
                      color: isUnread
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          : null,
                      fontWeight: isUnread
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (lastMessageAt != null)
                  Text(
                    _formatTime(lastMessageAt!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                if (isUnread)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingTile() {
    return const Card(
      child: ListTile(
        leading: CircleAvatar(child: CircularProgressIndicator()),
        title: Text('Chargement...'),
      ),
    );
  }

  Widget _buildErrorTile() {
    return const Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(Icons.error)),
        title: Text('Erreur de chargement'),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Maintenant';
    }
  }
}
