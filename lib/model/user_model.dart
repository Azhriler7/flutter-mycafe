import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String gender;
  final Timestamp createdAt;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.gender,
    required this.createdAt,
    this.isAdmin = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isAdmin: data['isAdmin'] ?? false,
    );
  }
}