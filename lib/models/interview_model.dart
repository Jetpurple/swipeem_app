import 'package:cloud_firestore/cloud_firestore.dart';

/// Interview status enum
enum InterviewStatus {
  pending,
  confirmed,
  declined,
  cancelled;

  String toJson() => name;
  
  static InterviewStatus fromJson(String value) {
    return InterviewStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => InterviewStatus.pending,
    );
  }
}

/// Model representing an interview between a recruiter and candidate
class InterviewModel {
  InterviewModel({
    required this.id,
    required this.matchId,
    required this.recruiterId,
    required this.candidateId,
    required this.proposedDateTime,
    required this.location,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore document ID
  final String id;
  
  /// ID of the match this interview belongs to
  final String matchId;
  
  /// UID of the recruiter who proposed the interview
  final String recruiterId;
  
  /// UID of the candidate
  final String candidateId;
  
  /// Proposed date and time for the interview
  final DateTime proposedDateTime;
  
  /// Location of the interview (can be physical address or video call link)
  final String location;
  
  /// Additional notes or description about the interview
  final String notes;
  
  /// Current status of the interview
  final InterviewStatus status;
  
  /// When the interview was created
  final DateTime createdAt;
  
  /// When the interview was last updated
  final DateTime updatedAt;

  /// Create from Firestore document
  factory InterviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return InterviewModel(
      id: doc.id,
      matchId: data['matchId'] as String? ?? '',
      recruiterId: data['recruiterId'] as String? ?? '',
      candidateId: data['candidateId'] as String? ?? '',
      proposedDateTime: (data['proposedDateTime'] as Timestamp).toDate(),
      location: data['location'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      status: InterviewStatus.fromJson(data['status'] as String? ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'matchId': matchId,
      'recruiterId': recruiterId,
      'candidateId': candidateId,
      'proposedDateTime': Timestamp.fromDate(proposedDateTime),
      'location': location,
      'notes': notes,
      'status': status.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with updated fields
  InterviewModel copyWith({
    String? id,
    String? matchId,
    String? recruiterId,
    String? candidateId,
    DateTime? proposedDateTime,
    String? location,
    String? notes,
    InterviewStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InterviewModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      recruiterId: recruiterId ?? this.recruiterId,
      candidateId: candidateId ?? this.candidateId,
      proposedDateTime: proposedDateTime ?? this.proposedDateTime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
