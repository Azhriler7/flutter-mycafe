import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/view/screen/admin/admin_dashboard_page.dart';
import 'package:mycafe/view/screen/admin/manajemen_menu_page.dart';
import 'package:mycafe/view/screen/admin/admin_profile_page.dart';
import 'package:mycafe/view/screen/user/user_dashboard_page.dart';
import 'package:mycafe/view/screen/user/user_profile_page.dart';
import 'package:mycafe/view/screen/auth/auth_wrapper.dart';


enum UserRole {
  admin,
  user,
}

class AppDrawer extends StatelessWidget {
  final UserRole userRole;

  const AppDrawer({
    super.key,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    if (userRole == UserRole.admin) {
      return const _AdminDrawerContent();
    } else {
      return const _UserDrawerContent();
    }
  }
}

class _AdminDrawerContent extends StatelessWidget {
  const _AdminDrawerContent();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4E342E);
    const Color backgroundColor = Color(0xFFFFF8F0);

    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            child: Text(
              'Menu Admin',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_customize, color: primaryColor),
            title: const Text('Dashboard', style: TextStyle(color: primaryColor)),
            onTap: () {
              Get.back();
              Get.to(() => const AdminDashboardPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu, color: primaryColor),
            title: const Text('Manajemen Menu', style: TextStyle(color: primaryColor)),
            onTap: () {
              Get.back();
              Get.to(() => const ManajemenMenuPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: primaryColor),
            title: const Text('Profil', style: TextStyle(color: primaryColor)),
            onTap: () {
              Get.back();
              Get.to(() => const AdminProfilePage());
            },
          ),
          const Divider(color: Colors.black12, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: primaryColor),
            title: const Text('Logout', style: TextStyle(color: primaryColor)),
            onTap: () async {
              final authController = Get.find<AuthController>();
              await authController.signOut();
              Get.offAll(() => const AuthWrapper());
            },
          ),
        ],
      ),
    );
  }
}

class _UserDrawerContent extends StatelessWidget {
  const _UserDrawerContent();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4E342E);
    const Color backgroundColor = Color(0xFFFFF8F0);
    
    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            child: Text(
              'Menu User',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: primaryColor),
            title: const Text('Dashboard', style: TextStyle(color: primaryColor)),
            onTap: () {
              Get.back();
              Get.to(() => const UserDashboardPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: primaryColor),
            title: const Text('Profil', style: TextStyle(color: primaryColor)),
            onTap: () {
              Get.back();
              Get.to(() => const UserProfilePage());
            },
          ),
          const Divider(color: Colors.black12, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: primaryColor),
            title: const Text('Logout', style: TextStyle(color: primaryColor)),
            onTap: () async {
              final authController = Get.find<AuthController>();
              await authController.signOut();
              Get.offAll(() => const AuthWrapper());
            },
          ),
        ],
      ),
    );
  }
}