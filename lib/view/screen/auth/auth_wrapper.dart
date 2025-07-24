import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import '../dashboard/dashboard_page.dart';
import 'package:mycafe/service/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.value.userChanges,
      builder: (context, snapshot) {
        // Tampilkan loading saat menunggu status auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A1A1A),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            ),
          );
        }
        
        // Jika user sudah login, tampilkan dashboard
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardPage();
        }
        
        // Jika user belum login, tampilkan halaman login
        return const LoginPage();
      },
    );
  }
}
