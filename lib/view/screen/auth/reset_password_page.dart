import 'package:flutter/material.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:mycafe/view/widget/custom_text_field.dart';
import 'package:mycafe/view/widget/primary_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Proses reset password
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Get.find<AuthController>();

    final success = await authController.resetPassword(
      email: _emailController.text.trim(),
    );
    
    if (mounted) {
      if (success) {
        Get.back();
        
        Get.snackbar(
          'Berhasil',
          'Email reset password telah dikirim!',
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
          'Reset Password',
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
                      Icons.lock_reset,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 78, 52, 46),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masukkan email untuk reset password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 78, 52, 46),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Note: Email mungkin saja masuk ke spam',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 78, 52, 46),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  Obx(() {
                    final authController = Get.find<AuthController>();
                    return PrimaryButton(
                      text: 'Kirim Email Reset',
                      onPressed: _resetPassword,
                      isLoading: authController.isLoading,
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