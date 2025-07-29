import 'package:flutter/material.dart';
import 'package:mycafe/controller/menu_controller.dart';
import 'package:mycafe/controller/menu_selection_controller.dart';
import 'package:mycafe/model/menu_model.dart';
import 'package:mycafe/view/screen/admin/create_menu_page.dart';
import 'package:mycafe/view/screen/admin/edit_menu_page.dart';
import 'package:mycafe/view/widget/admin_menu_tile.dart';
import 'package:mycafe/view/widget/confirmation_dialog.dart';
import 'package:get/get.dart';
import 'package:mycafe/view/widget/drawer.dart';

class ManajemenMenuPage extends StatelessWidget {
  const ManajemenMenuPage({super.key});

  // Hapus item terpilih
  Future<void> _deleteSelectedItems(MenuSelectionController selectionController) async {
    final menuController = Get.find<CafeMenuController>();
    try {
      await menuController.deleteMenus(selectionController.selectedItemIds.toList());
      selectionController.clearSelection();
      Get.snackbar(
        'Berhasil',
        'Item berhasil dihapus.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus item: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Dialog konfirmasi hapus
  Widget _buildDeleteConfirmationDialog(MenuSelectionController selectionController) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: ConfirmationDialog(
          title: 'Hapus Pilihan',
          message: 'Apakah Anda yakin ingin menghapus ${selectionController.selectedCount} item?',
          icon: Icons.delete,
          confirmText: 'Hapus',
          cancelText: 'Batal',
          confirmColor: Colors.red,
          onConfirm: () => _deleteSelectedItems(selectionController),
          onCancel: () => selectionController.setDeleteMode(false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuController = Get.find<CafeMenuController>();
    final selectionController = Get.put(MenuSelectionController());

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 240),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 78, 52, 46),
        elevation: 0,
        title: const Text(
          'Manajemen Menu', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
      drawer: const AppDrawer(userRole: UserRole.admin),
      floatingActionButton: Obx(() => FloatingActionButton(
        onPressed: () {
          if (selectionController.hasSelection) {
            selectionController.setDeleteMode(true);
          } else {
            Get.to(() => const CreateMenuPage());
          }
        },
        backgroundColor: selectionController.hasSelection ? Colors.redAccent : const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        tooltip: selectionController.hasSelection ? 'Hapus' : 'Tambah Menu',
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: Icon(
            selectionController.hasSelection ? Icons.delete : Icons.add,
            key: ValueKey<bool>(selectionController.hasSelection),
          ),
        ),
      )),
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
                return const Center(child: Text('Belum ada menu.', style: TextStyle(color: Colors.black)));
              }

              final menuItems = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final menu = menuItems[index];

                  return Obx(() => AdminMenuTile(
                    namaMenu: menu.namaMenu,
                    harga: menu.harga,
                    isChecked: selectionController.isSelected(menu.id),
                    onCheckboxChanged: (bool? value) {
                      selectionController.toggleSelection(menu.id);
                    },
                    onEditPressed: () {
                      Get.to(() => EditMenuPage(docId: menu.id));
                    },
                  ));
                },
              );
            },
          ),
          Obx(() => selectionController.isDeleteMode.value 
            ? _buildDeleteConfirmationDialog(selectionController) 
            : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
