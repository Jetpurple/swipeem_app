import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hire_me/models/post_model.dart';
import 'package:hire_me/services/firebase_user_service.dart';

class PostService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'posts';

  static Future<String> createPost({
    required String title,
    required String content,
    String? imageUrl,
    List<String> softSkills = const [],
    List<String> hardSkills = const [],
    String? domain,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Utilisateur non connecté');

    // Récupérer le type d'utilisateur (recruteur ou candidat)
    bool authorIsRecruiter = false;
    try {
      final user = await FirebaseUserService.getUser(currentUser.uid);
      if (user != null) {
        authorIsRecruiter = user.isRecruiter;
        print('👤 Utilisateur récupéré: ${user.email}, isRecruiter: ${user.isRecruiter}');
      } else {
        print('⚠️ Utilisateur non trouvé dans Firestore pour UID: ${currentUser.uid}');
      }
    } catch (e) {
      // Si on ne peut pas récupérer l'utilisateur, on laisse false par défaut
      print('⚠️ Impossible de récupérer le type d\'utilisateur: $e');
    }

    try {
      final id = _firestore.collection(_collection).doc().id;
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

      final postData = post.toFirestore();
      print('💾 Enregistrement du post dans Firestore...');
      print('   Collection: $_collection');
      print('   ID: $id');
      print('   Données: $postData');

      await _firestore.collection(_collection).doc(id).set(postData);
      
      print('✅ Post enregistré avec succès dans Firestore');
      return id;
    } catch (e, stackTrace) {
      print('❌ Erreur lors de l\'enregistrement dans Firestore: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> updatePost({
    required String id,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? tags,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{
      'title': ?title,
      'content': ?content,
      'imageUrl': ?imageUrl,
      'tags': ?tags,
      'isActive': ?isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    await _firestore.collection(_collection).doc(id).update(data);
  }

  static Future<void> deletePost(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  static Future<PostModel?> getPost(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return PostModel.fromFirestore(doc);
  }

  static Future<List<PostModel>> listPosts({
    int limit = 50,
    String? authorUid,
    List<String>? withTags,
    bool onlyActive = true,
    bool? filterByUserType = true,
  }) async {
    // Récupérer le type d'utilisateur connecté pour filtrer
    bool? currentUserIsRecruiter;
    if (filterByUserType == true) {
      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          final user = await FirebaseUserService.getUser(currentUser.uid);
          if (user != null) {
            currentUserIsRecruiter = user.isRecruiter;
          }
        }
      } catch (e) {
        print('⚠️ Impossible de récupérer le type d\'utilisateur: $e');
      }
    }

    var q = _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (onlyActive) {
      q = q.where('isActive', isEqualTo: true);
    }
    
    // Filtrer selon le type d'utilisateur :
    // - Les recruteurs voient uniquement les posts des candidats (authorIsRecruiter = false)
    // - Les candidats voient uniquement les posts des recruteurs (authorIsRecruiter = true)
    if (currentUserIsRecruiter != null && filterByUserType == true) {
      q = q.where('authorIsRecruiter', isEqualTo: !currentUserIsRecruiter);
    }
    
    if (authorUid != null) {
      q = q.where('authorUid', isEqualTo: authorUid);
    }
    // Firestore cannot filter by array contains any of multiple tags in one query easily.
    if (withTags != null && withTags.isNotEmpty) {
      q = q.where('tags', arrayContainsAny: withTags.take(10).toList());
    }

    final snap = await q.get();
    return snap.docs.map(PostModel.fromFirestore).toList();
  }

  static Stream<List<PostModel>> streamRecentPosts({
    int limit = 50,
    bool onlyActive = true,
    bool? filterByUserType = true,
  }) {
    // Récupérer le type d'utilisateur connecté pour filtrer
    Future<bool?> getCurrentUserType() async {
      if (filterByUserType != true) return null;
      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          final user = await FirebaseUserService.getUser(currentUser.uid);
          if (user != null) {
            return user.isRecruiter;
          }
        }
      } catch (e) {
        print('⚠️ Impossible de récupérer le type d\'utilisateur: $e');
      }
      return null;
    }

    return Stream.fromFuture(getCurrentUserType()).asyncExpand((currentUserIsRecruiter) {
      var q = _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (onlyActive) {
        q = q.where('isActive', isEqualTo: true);
      }
      
      // Filtrer selon le type d'utilisateur :
      // - Les recruteurs voient uniquement les posts des candidats (authorIsRecruiter = false)
      // - Les candidats voient uniquement les posts des recruteurs (authorIsRecruiter = true)
      if (currentUserIsRecruiter != null && filterByUserType == true) {
        q = q.where('authorIsRecruiter', isEqualTo: !currentUserIsRecruiter);
      }
      
      return q.snapshots().map((s) => s.docs.map(PostModel.fromFirestore).toList());
    });
  }
}


