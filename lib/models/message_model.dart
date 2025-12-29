import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {

  MessageModel({
    required this.id,
    required this.matchId,
    required this.senderUid,
    required this.receiverUid,
    required this.content,
    required this.sentAt, this.type = MessageType.text,
    this.readAt,
    this.isRead = false,
    this.imageUrl,
    this.metadata,
  });

  // Factory constructor pour créer un MessageModel depuis Firestore
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      matchId: (data['matchId'] as String?) ?? '',
      senderUid: (data['senderUid'] as String?) ?? '',
      receiverUid: (data['receiverUid'] as String?) ?? '',
      content: (data['content'] as String?) ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.text,
      ),
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: data['readAt'] != null 
          ? (data['readAt'] as Timestamp).toDate() 
          : null,
      isRead: (data['isRead'] as bool?) ?? false,
      imageUrl: data['imageUrl'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
  final String id;
  final String matchId;
  final String senderUid;
  final String receiverUid;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final DateTime? readAt;
  final bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  // Méthode pour convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'matchId': matchId,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'content': content,
      'type': type.name,
      'sentAt': Timestamp.fromDate(sentAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'isRead': isRead,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  // Méthode pour copier avec des modifications
  MessageModel copyWith({
    String? id,
    String? matchId,
    String? senderUid,
    String? receiverUid,
    String? content,
    MessageType? type,
    DateTime? sentAt,
    DateTime? readAt,
    bool? isRead,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      senderUid: senderUid ?? this.senderUid,
      receiverUid: receiverUid ?? this.receiverUid,
      content: content ?? this.content,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum MessageType {
  text,
  image,
  file,
  system,
}

class MatchModel {

  MatchModel({
    required this.id,
    required this.candidateUid,
    required this.recruiterUid,
    required this.matchedAt,
    this.lastMessageAt,
    this.lastMessageContent,
    this.lastMessageSenderUid,
    this.isActive = true,
    this.readBy = const {},
    this.jobOfferId,
  });

  // Factory constructor pour créer un MatchModel depuis Firestore
  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return MatchModel(
      id: doc.id,
      candidateUid: (data['candidateUid'] as String?) ?? '',
      recruiterUid: (data['recruiterUid'] as String?) ?? '',
      matchedAt: (data['matchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageAt: data['lastMessageAt'] != null 
          ? (data['lastMessageAt'] as Timestamp).toDate() 
          : null,
      lastMessageContent: data['lastMessageContent'] as String?,
      lastMessageSenderUid: data['lastMessageSenderUid'] as String?,
      isActive: (data['isActive'] as bool?) ?? true,
      readBy: Map<String, bool>.from((data['readBy'] as Map<dynamic, dynamic>?) ?? {}),
      jobOfferId: data['jobOfferId'] as String?,
    );
  }
  final String id;
  final String candidateUid;
  final String recruiterUid;
  final DateTime matchedAt;
  final DateTime? lastMessageAt;
  final String? lastMessageContent;
  final String? lastMessageSenderUid;
  final bool isActive;
  final Map<String, bool> readBy;
  final String? jobOfferId;

  // Méthode pour convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'candidateUid': candidateUid,
      'recruiterUid': recruiterUid,
      'matchedAt': Timestamp.fromDate(matchedAt),
      'lastMessageAt': lastMessageAt != null 
          ? Timestamp.fromDate(lastMessageAt!) 
          : null,
      'lastMessageContent': lastMessageContent,
      'lastMessageSenderUid': lastMessageSenderUid,
      'isActive': isActive,
      'readBy': readBy,
      if (jobOfferId != null) 'jobOfferId': jobOfferId,
    };
  }

  // Méthode pour copier avec des modifications
  MatchModel copyWith({
    String? id,
    String? candidateUid,
    String? recruiterUid,
    DateTime? matchedAt,
    DateTime? lastMessageAt,
    String? lastMessageContent,
    String? lastMessageSenderUid,
    bool? isActive,
    Map<String, bool>? readBy,
    String? jobOfferId,
  }) {
    return MatchModel(
      id: id ?? this.id,
      candidateUid: candidateUid ?? this.candidateUid,
      recruiterUid: recruiterUid ?? this.recruiterUid,
      matchedAt: matchedAt ?? this.matchedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageSenderUid: lastMessageSenderUid ?? this.lastMessageSenderUid,
      isActive: isActive ?? this.isActive,
      readBy: readBy ?? this.readBy,
      jobOfferId: jobOfferId ?? this.jobOfferId,
    );
  }
}
