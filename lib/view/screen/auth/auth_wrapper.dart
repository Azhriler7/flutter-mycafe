import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycafe/service/auth_service.dart';
import 'package:mycafe/view/screen/auth/login_page.dart';
import 'package:mycafe/view/screen/admin/admin_dashboard_page.dart';
import 'package:mycafe/view/screen/user/user_dashboard_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.value.userChanges,
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
                .snapshots(), // .snapshots() bersifat realtime
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!userDocSnapshot.hasData || !userDocSnapshot.data!.exists) {
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