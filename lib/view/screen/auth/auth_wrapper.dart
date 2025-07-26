import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/view/screen/auth/login_page.dart';
import 'package:mycafe/view/screen/admin/admin_dashboard_page.dart';
import 'package:mycafe/view/screen/user/user_dashboard_page.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil AuthController dari Provider
    final authController = Provider.of<AuthController>(context);

    return StreamBuilder<User?>(
      // Menggunakan stream dari AuthController
      stream: authController.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          final user = authSnapshot.data!;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!userDocSnapshot.hasData || !userDocSnapshot.data!.exists) {
                // Jika dokumen user belum ada (mungkin proses registrasi belum selesai),
                // anggap sebagai user biasa untuk sementara.
                return const UserDashboardPage();
              }

              final userData = userDocSnapshot.data!.data() as Map<String, dynamic>;
              
              if (userData['isAdmin'] == true) {
                return const AdminDashboardPage();
              } else {
                return const UserDashboardPage();
              }
            },
          );
        }
        
        return const LoginPage();
      },
    );
  }
}