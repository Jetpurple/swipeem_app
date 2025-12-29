import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hire_me/models/message_model.dart';
import 'package:hire_me/services/firebase_match_service.dart';

class FirebaseMessageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'messages';

  // Envoyer un message
  static Future<String> sendMessage({
    required String matchId,
    required String senderUid,
    required String receiverUid,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'matchId': matchId,
        'senderUid': senderUid,
        'receiverUid': receiverUid,
        'content': content,
        'type': type.name,
        'sentAt': FieldValue.serverTimestamp(),
        'readAt': null,
        'isRead': false,
        'imageUrl': null,
        'metadata': <String, dynamic>{},
      });

      // Mettre à jour le dernier message du match
      await FirebaseMatchService.updateLastMessage(
        matchId: matchId,
        content: content,
        senderUid: senderUid,
      );

      return docRef.id;
    } catch (e) {
      throw Exception("Erreur lors de l'envoi du message: $e");
    }
  }

  // Récupérer les messages d'un match
  static Future<List<MessageModel>> getMessages(String matchId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
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
        .collection(_collection)
        .where('matchId', isEqualTo: matchId)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(MessageModel.fromFirestore)
          .toList();
    });
  }

  // Marquer un message comme lu
  static Future<void> markAsRead(String messageId) async {
    try {
      await _firestore.collection(_collection).doc(messageId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors du marquage comme lu: $e');
    }
  }

  // Marquer tous les messages d'un match comme lus
  static Future<void> markAllAsRead(String matchId, String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('matchId', isEqualTo: matchId)
          .where('receiverUid', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors du marquage de tous les messages comme lus: $e');
    }
  }

  // Supprimer un message
  static Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection(_collection).doc(messageId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du message: $e');
    }
  }

  // Récupérer le nombre de messages non lus pour un utilisateur
  static Future<int> getUnreadCount(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('receiverUid', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du nombre de messages non lus: $e');
    }
  }

  // Stream du nombre de messages non lus
  static Stream<int> getUnreadCountStream(String uid) {
    return _firestore
        .collection(_collection)
        .where('receiverUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Marquer tous les messages d'un match comme lus pour un utilisateur spécifique
  static Future<void> markMatchMessagesAsRead(String matchId, String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('matchId', isEqualTo: matchId)
          .where('receiverUid', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors du marquage des messages comme lus: $e');
    }
  }

  // Envoyer un message avec image
  static Future<String> sendImageMessage({
    required String matchId,
    required String senderUid,
    required String receiverUid,
    required String imageUrl,
    String? caption,
  }) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'matchId': matchId,
        'senderUid': senderUid,
        'receiverUid': receiverUid,
        'content': caption ?? '',
        'type': MessageType.image.name,
        'sentAt': FieldValue.serverTimestamp(),
        'readAt': null,
        'isRead': false,
        'imageUrl': imageUrl,
        'metadata': <String, dynamic>{},
      });

      // Mettre à jour le dernier message du match
      await FirebaseMatchService.updateLastMessage(
        matchId: matchId,
        content: caption ?? '📷 Image',
        senderUid: senderUid,
      );

      return docRef.id;
    } catch (e) {
      throw Exception("Erreur lors de l'envoi de l'image: $e");
    }
  }

  // Obtenir les statistiques des messages pour un utilisateur
  static Future<Map<String, int>> getMessageStats(String uid) async {
    try {
      final sentMessages = await _firestore
          .collection(_collection)
          .where('senderUid', isEqualTo: uid)
          .get();

      final receivedMessages = await _firestore
          .collection(_collection)
          .where('receiverUid', isEqualTo: uid)
          .get();

      final unreadMessages = await _firestore
          .collection(_collection)
          .where('receiverUid', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();

      return {
        'sent': sentMessages.docs.length,
        'received': receivedMessages.docs.length,
        'unread': unreadMessages.docs.length,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}
