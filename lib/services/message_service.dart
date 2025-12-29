import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hire_me/models/message_model.dart';

class MessageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _matchesCollection = 'matches';
  static const String _messagesCollection = 'messages';

  // Envoyer un message
  static Future<void> sendMessage({
    required String matchId,
    required String receiverUid,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Utilisateur non connecté');

      final messageId = _firestore.collection(_messagesCollection).doc().id;
      final message = MessageModel(
        id: messageId,
        matchId: matchId,
        senderUid: currentUser.uid,
        receiverUid: receiverUid,
        content: content,
        type: type,
        sentAt: DateTime.now(),
        imageUrl: imageUrl,
        metadata: metadata,
      );

      // Ajouter le message
      await _firestore
          .collection(_messagesCollection)
          .doc(messageId)
          .set(message.toFirestore());

      // Mettre à jour le match avec le dernier message
      await _firestore.collection(_matchesCollection).doc(matchId).update({
        'lastMessageAt': Timestamp.fromDate(DateTime.now()),
        'lastMessageContent': content,
        'lastMessageSenderUid': currentUser.uid,
        'readBy.${currentUser.uid}': true,
        'readBy.$receiverUid': false,
      });
    } catch (e) {
      throw Exception("Erreur lors de l'envoi du message: $e");
    }
  }

  // Récupérer les messages d'un match
  static Future<List<MessageModel>> getMessages(String matchId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_messagesCollection)
          .where('matchId', isEqualTo: matchId)
          .orderBy('sentAt', descending: false)
          .get();

      return querySnapshot.docs
          .map(MessageModel.fromFirestore)
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }

  // Stream des messages d'un match
  static Stream<List<MessageModel>> getMessagesStream(String matchId) {
    return _firestore
        .collection(_messagesCollection)
        .where('matchId', isEqualTo: matchId)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(MessageModel.fromFirestore)
            .toList());
  }

  // Marquer un message comme lu
  static Future<void> markMessageAsRead(String messageId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Utilisateur non connecté');

      await _firestore.collection(_messagesCollection).doc(messageId).update({
        'isRead': true,
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors du marquage du message comme lu: $e');
    }
  }

  // Marquer tous les messages d'un match comme lus
  static Future<void> markMatchMessagesAsRead(String matchId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Utilisateur non connecté');

      // Mettre à jour le statut de lecture dans le match
      await _firestore.collection(_matchesCollection).doc(matchId).update({
        'readBy.$currentUser.uid': true,
      });

      // Marquer tous les messages non lus comme lus
      final unreadMessages = await _firestore
          .collection(_messagesCollection)
          .where('matchId', isEqualTo: matchId)
          .where('receiverUid', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.fromDate(DateTime.now()),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors du marquage des messages comme lus: $e');
    }
  }

  // Supprimer un message
  static Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection(_messagesCollection).doc(messageId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du message: $e');
    }
  }

  // Récupérer le nombre de messages non lus
  static Future<int> getUnreadMessageCount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      final querySnapshot = await _firestore
          .collection(_messagesCollection)
          .where('receiverUid', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Erreur lors du comptage des messages non lus: $e');
    }
  }

  // Stream du nombre de messages non lus
  static Stream<int> getUnreadMessageCountStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    return _firestore
        .collection(_messagesCollection)
        .where('receiverUid', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
