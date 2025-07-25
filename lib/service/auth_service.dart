import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get userChanges => firebaseAuth.authStateChanges();

  // --- checkAdminStatus ---
  Future<bool> checkAdminStatus() async {
    try {
      final user = currentUser;
      if (user == null) return false;
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['isAdmin'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // --- signIn ---
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // --- createAccount ---
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // --- TAMBAHAN PENTING ---
    // Buat dokumen user di Firestore setelah registrasi
    await firestore.collection('users').doc(userCredential.user!.uid).set({
      'username': email.split('@')[0], // Nama default dari email
      'email': email,
      'gender': '',
      'createdAt': Timestamp.now(),
      'isAdmin': false, // Semua user baru defaultnya bukan admin
    });
    // -----------------------

    return userCredential;
  }

  // --- signOut ---
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  // --- resetPassword ---
  Future<void> resetPassword({
    required String email,
  }) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // --- updateUsername ---
  Future<void> updateUsername({
    required String username,
  }) async {
    await currentUser?.updateDisplayName(username);
  }

  // --- deleteAccount ---
  Future<void> deleteAccount({
    required String password,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }
}