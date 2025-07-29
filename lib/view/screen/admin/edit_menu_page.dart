import 'package:flutter/material.dart';
import 'package:mycafe/controller/menu_controller.dart';
import 'package:mycafe/view/widget/custom_text_field.dart';
import 'package:mycafe/view/widget/primary_button.dart';
import 'package:mycafe/view/screen/admin/manajemen_menu_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class EditMenuPage extends StatefulWidget {
  final String docId;

  const EditMenuPage({super.key, required this.docId});

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _kategoriController = TextEditingController();
  bool _isLoading = false;
  
  // Ambil data menu
  Future<void> _fetchMenuData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('menu').doc(widget.docId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _namaController.text = data['namaMenu'];
        _hargaController.text = data['harga'].toString();
        _kategoriController.text = data['kategori'];
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal mengambil data: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMenuData().then((_) {
      if(mounted) setState(() {});
    });
  }


  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _kategoriController.dispose();
    super.dispose();
  }

  // Update menu
  Future<void> _updateMenu() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    final menuController = Get.find<CafeMenuController>();

    try {
      await menuController.updateMenu(
        docId: widget.docId,
        namaMenu: _namaController.text,
        harga: int.parse(_hargaController.text),
        kategori: _kategoriController.text,
      );

      if (mounted) {
        Get.off(() => const ManajemenMenuPage());
        
        Get.snackbar(
          'Berhasil',
          'Menu berhasil diperbarui.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal memperbarui menu: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 240),
      appBar: AppBar(
        title: const Text(
          'Update Menu', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: const Color.fromARGB(255, 78, 52, 46),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _namaController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  CustomTextField(
                    controller: _namaController,
                    labelText: 'Nama Produk',
                    hintText: 'ex: Kopi Susu',
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama produk tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _hargaController,
                    labelText: 'Harga',
                    hintText: 'ex: 20000',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
      
                      if (int.tryParse(value) == null) {
                        return 'Harga harus berupa angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _kategoriController,
                    labelText: 'Kategori',
                    hintText: 'ex: kopi (jika kosong akan menjadi "lainnya")',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    text: 'Update Menu',
                    isLoading: _isLoading,
                    onPressed: _updateMenu,
                  ),
                ],
              ),
            ),
    );
  }
}