import 'package:flutter/material.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/controller/menu_controller.dart';
import 'package:mycafe/model/menu_model.dart';
import 'package:mycafe/view/screen/admin/admin_dashboard_page.dart';
import 'package:mycafe/view/screen/admin/admin_profile_page.dart';
import 'package:mycafe/view/screen/admin/create_menu_page.dart';
import 'package:mycafe/view/screen/admin/edit_menu_page.dart';
import 'package:mycafe/view/widget/admin_menu_tile.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:mycafe/view/screen/auth/auth_wrapper.dart';

class ManajemenMenuPage extends StatefulWidget {
  const ManajemenMenuPage({super.key});

  @override
  State<ManajemenMenuPage> createState() => _ManajemenMenuPageState();
}

class _ManajemenMenuPageState extends State<ManajemenMenuPage> {
  final List<String> _selectedItemIds = [];
  bool _isDeleteMode = false;

  // Hapus item yang dipilih
  Future<void> _deleteSelectedItems() async {
    final menuController = Provider.of<CafeMenuController>(context, listen: false);
    try {
      await menuController.deleteMenus(_selectedItemIds);
      if (mounted) {
        setState(() {
          _selectedItemIds.clear();
          _isDeleteMode = false;
        });
        Get.snackbar(
          'Berhasil',
          'Item berhasil dihapus.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal menghapus item: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // Dialog konfirmasi hapus item
  Widget _buildDeleteConfirmationDialog() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Card(
        margin: const EdgeInsets.all(32.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hapus Pilihan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Apakah Anda yakin ingin menghapus ${_selectedItemIds.length} item?', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 40),
                    onPressed: () => setState(() => _isDeleteMode = false),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green, size: 40),
                    onPressed: _deleteSelectedItems,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<CafeMenuController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Manajemen Menu', style: TextStyle(color: Colors.white)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedItemIds.isNotEmpty) {
            setState(() => _isDeleteMode = true);
          } else {
            Get.to(() => const CreateMenuPage());
          }
        },
        backgroundColor: _selectedItemIds.isNotEmpty ? Colors.redAccent : const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        tooltip: _selectedItemIds.isNotEmpty ? 'Hapus' : 'Tambah Menu',
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: Icon(
            _selectedItemIds.isNotEmpty ? Icons.delete : Icons.add,
            key: ValueKey<bool>(_selectedItemIds.isNotEmpty),
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<List<MenuModel>>(
            stream: menuController.getMenusStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Terjadi kesalahan', style: TextStyle(color: Colors.red)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Belum ada menu.', style: TextStyle(color: Colors.white70)));
              }

              final menuItems = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final menu = menuItems[index];
                  final isSelected = _selectedItemIds.contains(menu.id);

                  return AdminMenuTile(
                    namaMenu: menu.namaMenu,
                    harga: menu.harga,
                    isChecked: isSelected,
                    onCheckboxChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedItemIds.add(menu.id);
                        } else {
                          _selectedItemIds.remove(menu.id);
                        }
                      });
                    },
                    onEditPressed: () {
                      Get.to(() => EditMenuPage(docId: menu.id));
                    },
                  );
                },
              );
            },
          ),
          if (_isDeleteMode) _buildDeleteConfirmationDialog(),
        ],
      ),
    );
  }
}