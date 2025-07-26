import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Login user dengan email dan password
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Terjadi kesalahan';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registrasi user baru
  Future<bool> signUp({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': email.split('@')[0],
        'email': email,
        'gender': '',
        'createdAt': Timestamp.now(),
        'isAdmin': false,
      });
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Terjadi kesalahan';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> signOut() async {
    await _auth.signOut();
    // Navigation handled in UI layer
  }

  // Reset password via email
  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Terjadi kesalahan';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hapus akun user
  Future<bool> deleteAccount({required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        _errorMessage = 'Pengguna tidak ditemukan.';
        return false;
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      await _firestore.collection('users').doc(user.uid).delete();

      await user.delete();
      
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _errorMessage = 'Password salah.';
      } else if (e.code == 'requires-recent-login') {
        _errorMessage = 'Silakan login ulang sebelum menghapus akun.';
      } else {
        _errorMessage = e.message ?? 'Terjadi kesalahan';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}