import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/view/screen/auth/reset_password_page.dart';
import 'package:mycafe/view/screen/auth/delete_account_page.dart';
import 'package:get/get.dart';
import 'package:mycafe/view/screen/auth/auth_wrapper.dart';
import 'package:mycafe/view/widget/drawer.dart';
import 'package:mycafe/view/widget/primary_button.dart'; 
import 'package:mycafe/view/widget/info_card.dart'; 

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String _username = '';
  String _gender = '';
  DateTime? _createdAt;

  late TextEditingController _usernameController;
  String _selectedGender = '';

  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isEditing = false;
  bool _isProcessingAccountAction = false; 

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // Muat data user
  Future<void> _loadUserData() async {
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _username = data['username'] ?? '';
          _gender = data['gender'] ?? '';
          _createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          _isLoading = false;
          _usernameController.text = _username;
          _selectedGender = _gender;
        });
      } else {
        setState(() {
          _username = '';
          _gender = '';
          _createdAt = null;
          _isLoading = false;
          _usernameController.text = '';
          _selectedGender = '';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Gagal memuat data profil: ${e.toString()}');
    }
  }

  // Update data user
  Future<void> _updateUserData({required String newUsername, required String newGender}) async {
    if (currentUser == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      
      if (doc.exists) {
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'username': newUsername,
          'gender': newGender,
        });
      } else {
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'username': newUsername,
          'email': currentUser!.email ?? '',
          'gender': newGender,
          'createdAt': Timestamp.now(),
          'isAdmin': false,
        });
      }

      setState(() {
        _username = newUsername;
        _gender = newGender;
        _isEditing = false;
      });

      Get.snackbar(
        'Berhasil',
        'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // Batal edit
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _usernameController.text = _username;
      _selectedGender = _gender;
    });
  }

  // Handle aksi akun
  Future<void> _handleAccountAction(VoidCallback action) async {
    if (_isProcessingAccountAction) return;

    setState(() {
      _isProcessingAccountAction = true;
    });

    try {
      action(); 
    } finally {
      setState(() {
        _isProcessingAccountAction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 240),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 78, 52, 46),
        elevation: 0,
        title: const Text(
          'Profile User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.cancel : Icons.edit, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    _usernameController.text = _username;
                    _selectedGender = _gender;
                  } else {
                    _usernameController.text = _username;
                    _selectedGender = _gender;
                  }
                });
              },
              tooltip: _isEditing ? 'Batal Edit' : 'Edit Profil',
            ),
        ],
      ),
      drawer: const AppDrawer(userRole: UserRole.user),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                if (currentUser != null) ...[
                  const Text(
                    'Informasi Akun',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 78, 52, 46),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoCard( 
                    currentUser: currentUser,
                    username: _username,
                    gender: _gender,
                    createdAt: _createdAt,
                    isEditing: _isEditing,
                    isUpdating: _isUpdating,
                    usernameController: _usernameController,
                    selectedGender: _selectedGender,
                    onGenderChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                    onSave: (newUsername, newGender) async {
                      await _updateUserData(newUsername: newUsername, newGender: newGender);
                    },
                    onCancel: _cancelEdit,
                  ),
                  const SizedBox(height: 32),
                ],

                const Text(
                  'Aksi Akun',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 78, 52, 46),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Reset Password',
                  onPressed: _isProcessingAccountAction ? null : () {
                    _handleAccountAction(() async {
                      Get.to(() => const ResetPasswordPage());
                    });
                  },
                  isLoading: _isProcessingAccountAction, 
                  buttonType: ButtonType.secondary,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Hapus Akun',
                  onPressed: _isProcessingAccountAction ? null : () {
                    _handleAccountAction(() async {
                      Get.to(() => const DeleteAccountPage());
                    });
                  },
                  isLoading: _isProcessingAccountAction,
                  buttonType: ButtonType.primary, 
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  text: 'Logout',
                  onPressed: _isProcessingAccountAction ? null : () async {
                    if (_isProcessingAccountAction) return;
                    
                    setState(() {
                      _isProcessingAccountAction = true;
                    });

                    try {
                      final authController = Get.find<AuthController>();
                      await authController.signOut();
                      Get.offAll(() => const AuthWrapper());
                    } finally {
                      setState(() {
                        _isProcessingAccountAction = false; 
                      });
                    }
                  },
                  isLoading: _isProcessingAccountAction, 
                  buttonType: ButtonType.primary,
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}