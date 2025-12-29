import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/models/message_model.dart';
import 'package:hire_me/models/user_model.dart';
import 'package:hire_me/providers/job_provider.dart';
import 'package:hire_me/providers/message_provider.dart';
import 'package:hire_me/providers/user_provider.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(userMatchesProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return matchesAsync.when(
      data: (matches) {
        return currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null) {
              return const Scaffold(
                body: Center(child: Text('Utilisateur non connecté')),
              );
            }

            if (matches.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Logo1(height: 100, fit: BoxFit.contain)),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucun message pour le moment',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Commencez à matcher avec des profils !',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/swipe'),
                        icon: Icon(Icons.swipe),
                        label: Text('Swiper des offres'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
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
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // TODO: Implémenter la recherche
                    },
                  ),
                ],
              ),
              body: ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  final otherUserUid = match.candidateUid == currentUser.uid 
                      ? match.recruiterUid 
                      : match.candidateUid;
                  
                  return Consumer(
                    builder: (context, ref, child) {
                      final otherUserAsync = ref.watch(userProvider(otherUserUid));
                      final isCandidate = !currentUser.isRecruiter;
                      
                      return otherUserAsync.when(
                        data: (otherUser) {
                          if (otherUser == null) {
                            return const ListTile(
                              title: Text('Utilisateur inconnu'),
                            );
                          }

                          final isUnread = !(match.readBy[currentUser.uid] ?? false);
                          final isLastMessageFromOther = match.lastMessageSenderUid != currentUser.uid;
                          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

                          // Si c'est un candidat et qu'il y a un jobOfferId, récupérer l'offre
                          if (isCandidate && match.jobOfferId != null) {
                            final jobOfferAsync = ref.watch(jobOfferProvider(match.jobOfferId!));
                            
                            return jobOfferAsync.when(
                              data: (jobOffer) {
                                final displayTitle = jobOffer != null
                                    ? (jobOffer['title'] as String? ?? 'Offre d\'emploi')
                                    : '${otherUser.firstName} ${otherUser.lastName}';
                                final subtitleText = jobOffer != null
                                    ? (jobOffer['company'] as String?)
                                    : null;
                                
                                return _buildMessageTile(
                                  context: context,
                                  match: match,
                                  otherUser: otherUser,
                                  displayTitle: displayTitle,
                                  subtitleText: subtitleText,
                                  isUnread: isUnread,
                                  isLastMessageFromOther: isLastMessageFromOther,
                                  isDarkMode: isDarkMode,
                                );
                              },
                              loading: () => const ListTile(
                                title: Text('Chargement...'),
                              ),
                              error: (error, stack) => _buildMessageTile(
                                context: context,
                                match: match,
                                otherUser: otherUser,
                                displayTitle: '${otherUser.firstName} ${otherUser.lastName}',
                                subtitleText: null,
                                isUnread: isUnread,
                                isLastMessageFromOther: isLastMessageFromOther,
                                isDarkMode: isDarkMode,
                              ),
                            );
                          } else {
                            // Côté recruteur ou pas d'offre associée : afficher le nom de l'utilisateur
                            return _buildMessageTile(
                              context: context,
                              match: match,
                              otherUser: otherUser,
                              displayTitle: '${otherUser.firstName} ${otherUser.lastName}',
                              subtitleText: null,
                              isUnread: isUnread,
                              isLastMessageFromOther: isLastMessageFromOther,
                              isDarkMode: isDarkMode,
                            );
                          }
                        },
                        loading: () => const ListTile(
                          title: Text('Chargement...'),
                        ),
                        error: (error, stack) => ListTile(
                          title: Text('Erreur: $error'),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(child: Text('Erreur: $error')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }

  // Méthode pour construire un tile de message
  Widget _buildMessageTile({
    required BuildContext context,
    required MatchModel match,
    required UserModel otherUser,
    required String displayTitle,
    String? subtitleText,
    required bool isUnread,
    required bool isLastMessageFromOther,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () {
        context.go('/chat?matchId=${match.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFF5271FF).withOpacity(0.05) : null,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getAvatarColor(otherUser.firstName),
            child: Text(
              '${otherUser.firstName[0]}${otherUser.lastName[0]}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayTitle,
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isUnread && isLastMessageFromOther)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5271FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              if (subtitleText != null && subtitleText.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                match.lastMessageContent ?? 'Aucun message',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUnread
                      ? (isDarkMode ? Colors.white : Colors.black)
                      : Colors.grey[600],
                  fontWeight: isUnread
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(match.lastMessageAt ?? DateTime.now()),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(match.lastMessageAt ?? DateTime.now()),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              if (isUnread && isLastMessageFromOther) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5271FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_chat_unread,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour obtenir une couleur d'avatar basée sur les initiales
  Color _getAvatarColor(String initials) {
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
    
    final hash = initials.hashCode;
    return colors[hash.abs() % colors.length];
  }

  // Méthode pour formater l'heure
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'Maintenant';
    }
  }
}