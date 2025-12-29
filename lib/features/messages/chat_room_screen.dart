import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';
import 'package:hire_me/models/message_model.dart';
import 'package:hire_me/providers/job_provider.dart';
import 'package:hire_me/providers/message_provider.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/services/firebase_message_service.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  
  const ChatRoomScreen({super.key, this.matchId});
  final String? matchId;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Marquer les messages comme lus quand l'écran s'ouvre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsRead();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null && widget.matchId != null) {
      FirebaseMessageService.markMatchMessagesAsRead(widget.matchId!, authUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matchId == null) {
      return const Scaffold(
        body: Center(child: Text('ID de match manquant')),
      );
    }

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

            final match = matches.firstWhere(
              (m) => m.id == widget.matchId,
              orElse: () => throw Exception('Match non trouvé'),
            );

            final otherUserUid = match.candidateUid == currentUser.uid 
                ? match.recruiterUid 
                : match.candidateUid;

            final otherUserAsync = ref.watch(userProvider(otherUserUid));
            final messagesAsync = ref.watch(matchMessagesProvider(widget.matchId!));
            final isCandidate = !currentUser.isRecruiter;

            return otherUserAsync.when(
              data: (otherUser) {
                if (otherUser == null) {
                  return const Scaffold(
                    body: Center(child: Text('Utilisateur non trouvé')),
                  );
                }

                // Si c'est un candidat et qu'il y a un jobOfferId, récupérer l'offre
                if (isCandidate && match.jobOfferId != null) {
                  final jobOfferAsync = ref.watch(jobOfferProvider(match.jobOfferId!));
                  
                  return jobOfferAsync.when(
                    data: (jobOffer) {
                      return messagesAsync.when(
                        data: (messages) {
                          final displayTitle = jobOffer != null
                              ? (jobOffer['title'] as String? ?? 'Offre d\'emploi')
                              : '${otherUser.firstName} ${otherUser.lastName}';
                          final subtitleText = jobOffer != null
                              ? (jobOffer['company'] as String?)
                              : null;
                          
                          return Scaffold(
                            appBar: AppBar(
                              leading: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/messages');
                                  }
                                },
                              ),
                              title: Row(
                                children: [
                                  const Logo1(height: 24, fit: BoxFit.contain),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    backgroundColor: _getAvatarColor(otherUser.firstName),
                                    child: Text(
                                      '${otherUser.firstName[0]}${otherUser.lastName[0]}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayTitle,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        if (subtitleText != null && subtitleText.isNotEmpty)
                                          Text(
                                            subtitleText,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          )
                                        else
                                          Text(
                                            otherUser.isOnline ? 'En ligne' : 'Hors ligne',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: otherUser.isOnline ? Colors.green : Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                if (!isCandidate)
                                  IconButton(
                                    icon: const Icon(Icons.calendar_month),
                                    onPressed: () {
                                      context.push('/calendar/propose/${widget.matchId}');
                                    },
                                    tooltip: 'Proposer un entretien',
                                  ),
                              ],
                            ),
                            body: _buildChatBody(messages, currentUser, otherUser),
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
                    },
                    loading: () => Scaffold(
                      appBar: AppBar(title: const Logo1(height: 28, fit: BoxFit.contain)),
                      body: const Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) {
                      // En cas d'erreur, afficher le nom de l'utilisateur
                      return messagesAsync.when(
                        data: (messages) {
                          return Scaffold(
                            appBar: AppBar(
                              leading: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/messages');
                                  }
                                },
                              ),
                              title: Row(
                                children: [
                                  const Logo1(height: 24, fit: BoxFit.contain),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    backgroundColor: _getAvatarColor(otherUser.firstName),
                                    child: Text(
                                      '${otherUser.firstName[0]}${otherUser.lastName[0]}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${otherUser.firstName} ${otherUser.lastName}',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          otherUser.isOnline ? 'En ligne' : 'Hors ligne',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: otherUser.isOnline ? Colors.green : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            body: _buildChatBody(messages, currentUser, otherUser),
                          );
                        },
                        loading: () => Scaffold(
                          appBar: AppBar(title: const Logo1(height: 28, fit: BoxFit.contain)),
                          body: const Center(child: CircularProgressIndicator()),
                        ),
                        error: (error2, stack2) => Scaffold(
                          appBar: AppBar(title: const Logo1(height: 28, fit: BoxFit.contain)),
                          body: Center(child: Text('Erreur: $error2')),
                        ),
                      );
                    },
                  );
                } else {
                  // Côté recruteur ou pas d'offre associée : afficher le nom de l'utilisateur
                  return messagesAsync.when(
                    data: (messages) {
                      return Scaffold(
                        appBar: AppBar(
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/messages');
                              }
                            },
                          ),
                          title: Row(
                            children: [
                              const Logo1(height: 24, fit: BoxFit.contain),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                backgroundColor: _getAvatarColor(otherUser.firstName),
                                child: Text(
                                  '${otherUser.firstName[0]}${otherUser.lastName[0]}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${otherUser.firstName} ${otherUser.lastName}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      otherUser.isOnline ? 'En ligne' : 'Hors ligne',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: otherUser.isOnline ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            if (!isCandidate)
                              IconButton(
                                icon: const Icon(Icons.calendar_month),
                                onPressed: () {
                                  context.push('/calendar/propose/${widget.matchId}');
                                },
                                tooltip: 'Proposer un entretien',
                              ),
                          ],
                        ),
                        body: _buildChatBody(messages, currentUser, otherUser),
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

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || widget.matchId == null) {
      print('⚠️ Message vide ou matchId manquant');
      return;
    }

    // Utiliser l'UID Firebase Auth directement, pas l'email
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      print('⚠️ Utilisateur non connecté');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour envoyer un message'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    final senderUid = authUser.uid; // UID Firebase Auth (ex: "recruiter_1")
    
    try {
      // Déterminer l'autre utilisateur
      final matches = ref.read(userMatchesProvider).value ?? [];
      final match = matches.firstWhere(
        (m) => m.id == widget.matchId,
        orElse: () => throw Exception('Match non trouvé'),
      );

      final otherUserUid = match.candidateUid == senderUid 
          ? match.recruiterUid 
          : match.candidateUid;

      print('📤 Envoi du message...');
      print('   MatchId: ${widget.matchId}');
      print('   Sender UID (Auth): $senderUid');
      print('   Sender Email: ${currentUser?.email ?? authUser.email}');
      print('   Receiver: $otherUserUid');
      print('   Content: $text');

      // Envoyer le message
      await FirebaseMessageService.sendMessage(
        matchId: widget.matchId!,
        senderUid: senderUid,
        receiverUid: otherUserUid,
        content: text,
      );

      print('✅ Message envoyé avec succès');
      
      _messageController.clear();
      setState(() {
        _isTyping = false;
      });
      
      // Scroll vers le bas pour voir le nouveau message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (error) {
      print('❌ Erreur lors de l\'envoi du message: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'envoi: $error"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showImagePicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(bool fromCamera) {
    // TODO: Implémenter la sélection d'image avec image_picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'envoi d\'image à venir'),
      ),
    );
  }

  // Méthode pour construire le corps de la conversation
  Widget _buildChatBody(List<MessageModel> messages, dynamic currentUser, dynamic otherUser) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isMe = message.senderUid == currentUser.uid;
              
              return _MessageBubble(
                message: message,
                isMe: isMe,
                currentUser: currentUser,
                otherUser: otherUser,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Suggested starter phrases
        _buildSuggestedPhrases(),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _showImagePicker,
                icon: const Icon(Icons.image),
                tooltip: 'Envoyer une image',
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Tapez votre message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  maxLines: null,
                  onChanged: (text) {
                    setState(() {
                      _isTyping = text.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isTyping ? _sendMessage : null,
                icon: const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: _isTyping 
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
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

  // List of suggested starter phrases
  final List<String> _suggestedPhrases = [
    'Bonjour, comment ça va ?',
    'Je suis intéressé par votre profil.',
    'Quel est votre projet actuel ?',
    'Souhaitez-vous en savoir plus sur mon expérience ?',
    'Quand seriez-vous disponible pour un appel ?',
  ];

  Widget _buildSuggestedPhrases() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _suggestedPhrases.map((phrase) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: Text(phrase),
              onPressed: () {
                setState(() {
                  _messageController.text = phrase;
                  _isTyping = true;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.currentUser,
    required this.otherUser,
  });
  final dynamic message;
  final bool isMe;
  final dynamic currentUser;
  final dynamic otherUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: _getAvatarColor(otherUser.firstName as String),
              child: Text(
                '${(otherUser.firstName as String)[0]}${(otherUser.lastName as String)[0]}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe 
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                border: !isMe ? Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.image && message.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.imageUrl as String,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 50),
                          );
                        },
                      ),
                    ),
                    if (message.content.toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        message.content as String,
                        style: TextStyle(
                          color: isMe ? Colors.white : null,
                        ),
                      ),
                    ],
                  ] else ...[
                    Text(
                      message.content as String,
                      style: TextStyle(
                        color: isMe ? Colors.white : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.sentAt as DateTime),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe 
                              ? Colors.white70 
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          (message.isRead as bool) ? Icons.done_all : Icons.done,
                          size: 12,
                          color: (message.isRead as bool) ? Colors.blue : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: _getAvatarColor(currentUser.firstName as String),
              child: Text(
                '${(currentUser.firstName as String)[0]}${(currentUser.lastName as String)[0]}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

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
}