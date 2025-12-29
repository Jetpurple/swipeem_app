import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {

  const PostModel({
    required this.id,
    required this.authorUid,
    required this.title,
    required this.content,
    required this.createdAt, this.imageUrl,
    this.tags = const [],
    this.updatedAt,
    this.isActive = true,
    this.authorIsRecruiter = false,
    this.softSkills = const [],
    this.hardSkills = const [],
    this.domain,
  });

  factory PostModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return PostModel(
      id: doc.id,
      authorUid: data['authorUid'] as String? ?? '',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      tags: List<String>.from((data['tags'] as List<dynamic>?) ?? const []),
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['createdAt'] as DateTime? ?? DateTime.now()),
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : (data['updatedAt'] as DateTime?),
      isActive: data['isActive'] as bool? ?? true,
      authorIsRecruiter: data['authorIsRecruiter'] as bool? ?? false,
      softSkills: List<String>.from((data['softSkills'] as List<dynamic>?) ?? const []),
      hardSkills: List<String>.from((data['hardSkills'] as List<dynamic>?) ?? const []),
      domain: data['domain'] as String?,
    );
  }
  final String id;
  final String authorUid;
  final String title;
  final String content;
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool authorIsRecruiter;
  final List<String> softSkills;
  final List<String> hardSkills;
  final String? domain;

  Map<String, dynamic> toFirestore() {
    return {
      'authorUid': authorUid,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      'isActive': isActive,
      'authorIsRecruiter': authorIsRecruiter,
      'softSkills': softSkills,
      'hardSkills': hardSkills,
      if (domain != null) 'domain': domain,
    };
  }
}


