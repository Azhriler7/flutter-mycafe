import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  // Login user
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage.value = e.message ?? 'Terjadi kesalahan';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Registrasi user baru
  Future<bool> signUp({required String email, required String password}) async {
    _isLoading.value = true;
    _errorMessage.value = '';

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
      _errorMessage.value = e.message ?? 'Terjadi kesalahan';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage.value = e.message ?? 'Terjadi kesalahan';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Hapus akun user
  Future<bool> deleteAccount({required String password}) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        _errorMessage.value = 'Pengguna tidak ditemukan.';
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
        _errorMessage.value = 'Password salah.';
      } else if (e.code == 'requires-recent-login') {
        _errorMessage.value = 'Silakan login ulang sebelum menghapus akun.';
      } else {
        _errorMessage.value = e.message ?? 'Terjadi kesalahan';
      }
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Hapus pesan error
  void clearError() {
    _errorMessage.value = '';
  }
}