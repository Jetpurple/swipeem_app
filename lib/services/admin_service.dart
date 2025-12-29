import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hire_me/models/message_model.dart';
import 'package:hire_me/models/post_model.dart';
import 'package:hire_me/models/user_model.dart';
import 'package:hire_me/services/firebase_user_service.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Vérifier si l'utilisateur actuel est admin
  static Future<bool> isCurrentUserAdmin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;
      return userData['isAdmin'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer l'utilisateur actuel avec ses informations
  static Future<UserModel?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      return null;
    }
  }

  /// Créer un post en tant qu'admin
  static Future<String> createPostAsAdmin({
    required String title,
    required String content,
    String? imageUrl,
    List<String> softSkills = const [],
    List<String> hardSkills = const [],
    String? domain,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Utilisateur non connecté');

    // Vérifier que l'utilisateur est admin
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) throw Exception('Accès refusé : droits administrateur requis');

    // Récupérer le type d'utilisateur (recruteur ou candidat)
    bool authorIsRecruiter = false;
    try {
      final user = await FirebaseUserService.getUser(currentUser.uid);
      if (user != null) {
        authorIsRecruiter = user.isRecruiter;
      }
    } catch (e) {
      print('⚠️ Impossible de récupérer le type d\'utilisateur: $e');
    }

    final id = _firestore.collection('posts').doc().id;
    final post = PostModel(
      id: id,
      authorUid: currentUser.uid,
      title: title,
      content: content,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      authorIsRecruiter: authorIsRecruiter,
      softSkills: softSkills,
      hardSkills: hardSkills,
      domain: domain,
    );

    await _firestore.collection('posts').doc(id).set(post.toFirestore());
    return id;
  }

  /// Créer un message entre deux utilisateurs (admin)
  static Future<String> createMessageAsAdmin({
    required String senderUid,
    required String receiverUid,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Utilisateur non connecté');

    // Vérifier que l'utilisateur est admin
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) throw Exception('Accès refusé : droits administrateur requis');

    // Vérifier que les utilisateurs existent
    final senderDoc = await _firestore.collection('users').doc(senderUid).get();
    final receiverDoc = await _firestore.collection('users').doc(receiverUid).get();
    
    if (!senderDoc.exists) throw Exception('Utilisateur expéditeur introuvable');
    if (!receiverDoc.exists) throw Exception('Utilisateur destinataire introuvable');

    // Créer ou récupérer le match entre les deux utilisateurs
    String matchId = await _getOrCreateMatch(senderUid, receiverUid);

    final messageId = _firestore.collection('messages').doc().id;
    final message = MessageModel(
      id: messageId,
      matchId: matchId,
      senderUid: senderUid,
      receiverUid: receiverUid,
      content: content,
      type: type,
      sentAt: DateTime.now(),
      imageUrl: imageUrl,
      metadata: metadata,
    );

    // Ajouter le message
    await _firestore
        .collection('messages')
        .doc(messageId)
        .set(message.toFirestore());

    // Mettre à jour le match avec le dernier message
    await _firestore.collection('matches').doc(matchId).update({
      'lastMessageAt': Timestamp.fromDate(DateTime.now()),
      'lastMessageContent': content,
      'lastMessageSenderUid': senderUid,
      'readBy.$senderUid': true,
      'readBy.$receiverUid': false,
    });

    return messageId;
  }

  /// Récupérer ou créer un match entre deux utilisateurs
  static Future<String> _getOrCreateMatch(String user1Uid, String user2Uid) async {
    // Chercher un match existant
    final existingMatch = await _firestore
        .collection('matches')
        .where('candidateUid', isEqualTo: user1Uid)
        .where('recruiterUid', isEqualTo: user2Uid)
        .limit(1)
        .get();

    if (existingMatch.docs.isNotEmpty) {
      return existingMatch.docs.first.id;
    }

    // Chercher dans l'autre sens
    final existingMatchReverse = await _firestore
        .collection('matches')
        .where('candidateUid', isEqualTo: user2Uid)
        .where('recruiterUid', isEqualTo: user1Uid)
        .limit(1)
        .get();

    if (existingMatchReverse.docs.isNotEmpty) {
      return existingMatchReverse.docs.first.id;
    }

    // Créer un nouveau match
    final matchDoc = await _firestore.collection('matches').add({
      'candidateUid': user1Uid,
      'recruiterUid': user2Uid,
      'matchedAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'readBy': {user1Uid: false, user2Uid: false},
    });

    return matchDoc.id;
  }

  /// Récupérer tous les utilisateurs
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  /// Récupérer les utilisateurs par type
  static Future<List<UserModel>> getUsersByType({
    bool? isRecruiter,
    bool? isAdmin,
  }) async {
    try {
      Query query = _firestore.collection('users');

      if (isRecruiter != null) {
        query = query.where('isRecruiter', isEqualTo: isRecruiter);
      }
      if (isAdmin != null) {
        query = query.where('isAdmin', isEqualTo: isAdmin);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  /// Récupérer tous les posts
  static Future<List<PostModel>> getAllPosts() async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des posts: $e');
    }
  }

  /// Supprimer un post (admin)
  static Future<void> deletePost(String postId) async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) throw Exception('Accès refusé : droits administrateur requis');

    await _firestore.collection('posts').doc(postId).delete();
  }

  /// Supprimer un message (admin)
  static Future<void> deleteMessage(String messageId) async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) throw Exception('Accès refusé : droits administrateur requis');

    await _firestore.collection('messages').doc(messageId).delete();
  }

  /// Récupérer les statistiques admin
  static Future<Map<String, int>> getAdminStats() async {
    try {
      final usersCount = await _firestore.collection('users').count().get();
      final postsCount = await _firestore.collection('posts').count().get();
      final messagesCount = await _firestore.collection('messages').count().get();
      final matchesCount = await _firestore.collection('matches').count().get();

      return {
        'users': usersCount.count ?? 0,
        'posts': postsCount.count ?? 0,
        'messages': messagesCount.count ?? 0,
        'matches': matchesCount.count ?? 0,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}
