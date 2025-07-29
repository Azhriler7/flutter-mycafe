import 'package:flutter/material.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/view/screen/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mycafe/view/widget/custom_text_field.dart';
import 'package:mycafe/view/widget/confirmation_dialog.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // Konfirmasi hapus akun
  Future<void> _showDeleteConfirmation() async {
    if (!_formKey.currentState!.validate()) return;
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Konfirmasi Hapus Akun',
          message: 'Apakah Anda yakin? Tindakan ini tidak dapat dibatalkan.',
          icon: Icons.warning,
          confirmText: 'Hapus Akun',
          cancelText: 'Batal',
          confirmColor: Colors.red,
          onCancel: () => Get.back(),
          onConfirm: () {
            Get.back();
            _deleteAccount();
          },
        );
      },
    );
  }

  // Hapus akun
  Future<void> _deleteAccount() async {
    final authController = Get.find<AuthController>();

    final success = await authController.deleteAccount(
      password: _passwordController.text,
    );
    
    if (mounted) {
      if (success) {
        Get.offAll(() => const LoginPage());
        
        Get.snackbar(
          'Berhasil',
          'Akun berhasil dihapus!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      } else {
        Get.snackbar(
          'Error',
          authController.errorMessage.isEmpty ? 'Terjadi kesalahan' : authController.errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 240),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color.fromARGB(255, 78, 52, 46)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Hapus Akun',
          style: TextStyle(color: Color.fromARGB(255, 78, 52, 46)),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 78, 52, 46),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.warning,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Hapus Akun',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 78, 52, 46),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tindakan ini akan menghapus akun dan semua data Anda secara permanen.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 78, 52, 46),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Email: ${currentUser?.email ?? 'Tidak diketahui'}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 78, 52, 46),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomTextField(
                      controller: _passwordController,
                      labelText: 'Konfirmasi Password Anda',
                      isPassword: !_isPasswordVisible,
                      prefixIcon: Icons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: const Color.fromARGB(255, 78, 52, 46),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  Obx(() {
                    final authController = Get.find<AuthController>();
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authController.isLoading ? null : _showDeleteConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 78, 52, 46),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: authController.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'HAPUS AKUN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}