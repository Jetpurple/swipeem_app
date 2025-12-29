import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt, required this.updatedAt, this.profileImageUrl,
    this.companyName,
    this.jobTitle,
    this.bio,
    this.skills = const [],
    this.softSkills = const [],
    this.hardSkills = const [],
    this.isRecruiter = false,
    this.isAdmin = false,
    this.isOnline = false,
    this.lastSeen,
  });

  // Factory constructor pour créer un UserModel depuis Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    // Utiliser le champ 'uid' du document s'il existe (UID Firebase Auth),
    // sinon utiliser doc.id (qui peut être l'email ou l'UID selon la structure)
    final uid = (data['uid'] as String?) ?? doc.id;
    return UserModel(
      uid: uid,
      email: (data['email'] as String?) ?? '',
      firstName: (data['firstName'] as String?) ?? '',
      lastName: (data['lastName'] as String?) ?? '',
      profileImageUrl: data['profileImageUrl'] as String?,
      companyName: data['companyName'] as String?,
      jobTitle: data['jobTitle'] as String?,
      bio: data['bio'] as String?,
      skills: List<String>.from((data['skills'] as List<dynamic>?) ?? []),
      softSkills: (data['softSkills'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
      hardSkills: (data['hardSkills'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
      isRecruiter: (data['isRecruiter'] as bool?) ?? false,
      isAdmin: (data['isAdmin'] as bool?) ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOnline: (data['isOnline'] as bool?) ?? false,
      lastSeen: data['lastSeen'] != null 
          ? (data['lastSeen'] as Timestamp).toDate() 
          : null,
    );
  }
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String? companyName;
  final String? jobTitle;
  final String? bio;
  final List<String> skills;
  final List<Map<String, dynamic>> softSkills;
  final List<Map<String, dynamic>> hardSkills;
  final bool isRecruiter;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOnline;
  final DateTime? lastSeen;

  // Méthode pour convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'bio': bio,
      'skills': skills,
      'softSkills': softSkills,
      'hardSkills': hardSkills,
      'isRecruiter': isRecruiter,
      'isAdmin': isAdmin,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }

  // Méthode pour obtenir le nom complet
  String get fullName => '$firstName $lastName';

  // Méthode pour obtenir les initiales
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  // Méthode pour copier avec des modifications
  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    String? companyName,
    String? jobTitle,
    String? bio,
    List<String>? skills,
    List<Map<String, dynamic>>? softSkills,
    List<Map<String, dynamic>>? hardSkills,
    bool? isRecruiter,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      softSkills: softSkills ?? this.softSkills,
      hardSkills: hardSkills ?? this.hardSkills,
      isRecruiter: isRecruiter ?? this.isRecruiter,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
