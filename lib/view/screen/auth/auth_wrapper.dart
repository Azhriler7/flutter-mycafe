import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/view/screen/auth/login_page.dart';
import 'package:mycafe/view/screen/admin/admin_dashboard_page.dart';
import 'package:mycafe/view/screen/user/user_dashboard_page.dart';
import 'package:get/get.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Stream untuk cek status autentikasi
    return StreamBuilder<User?>(
      stream: authController.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authSnapshot.hasData) {
          final user = authSnapshot.data!;
          // Stream untuk cek role user
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (userDocSnapshot.hasData && userDocSnapshot.data!.exists) {
                final userData = userDocSnapshot.data!.data() as Map<String, dynamic>;
                // Cek role admin
                if (userData['isAdmin'] == true) {
                  return const AdminDashboardPage();
                }
              }
              return const UserDashboardPage();
            },
          );
        }
        
        return const LoginPage();
      },
    );
  }
}
