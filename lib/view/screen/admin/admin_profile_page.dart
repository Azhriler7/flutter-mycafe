import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/view/screen/admin/admin_dashboard_page.dart';
import 'package:mycafe/view/screen/admin/manajemen_menu_page.dart';
import 'package:mycafe/view/screen/auth/reset_password_page.dart';
import 'package:mycafe/view/screen/auth/delete_account_page.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:mycafe/view/screen/auth/auth_wrapper.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Profil Admin', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF2C2C2C),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4CAF50)),
              child: Text(
                'Menu Admin', 
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_filled, color: Colors.white70),
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.to(() => const AdminDashboardPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: Colors.white70),
              title: const Text('Manajemen Menu', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.to(() => const ManajemenMenuPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white70),
              title: const Text('Profil', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.to(() => const AdminProfilePage());
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final authController = Provider.of<AuthController>(context, listen: false);
                await authController.signOut();
                
                // Perintah ini melakukan hal yang sama: membuka halaman baru
                // dan menghapus semua halaman sebelumnya.
                Get.offAll(() => const AuthWrapper());
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          if (currentUser != null) ...[
            const Text(
              'Informasi Akun',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF2C2C2C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email, 'Email', currentUser.email ?? 'N/A'),
                    const Divider(color: Colors.white24),
                    _buildInfoRow(Icons.verified_user, 'Status Email', currentUser.emailVerified ? 'Terverifikasi' : 'Belum Terverifikasi'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          const Text(
            'Aksi Akun',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            context: context,
            icon: Icons.lock_reset,
            title: 'Reset Password',
            onTap: () {
              Get.to(() => const ResetPasswordPage());
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            icon: Icons.delete_forever,
            title: 'Hapus Akun',
            color: Colors.red,
            onTap: () {
               Get.to(() => const DeleteAccountPage());
            },
          ),
          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () async {
              final authController = Provider.of<AuthController>(context, listen: false);
              await authController.signOut();
              
              // Perintah ini melakukan hal yang sama: membuka halaman baru
              // dan menghapus semua halaman sebelumnya.
              Get.offAll(() => const AuthWrapper());
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Tampilkan baris informasi user
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 16),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Tombol aksi profil
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    final actionColor = color ?? const Color(0xFF4CAF50);
    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: actionColor),
        title: Text(title, style: TextStyle(color: actionColor, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      ),
    );
  }
}