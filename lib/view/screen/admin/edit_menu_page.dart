import 'package:flutter/material.dart';
import 'package:mycafe/controller/menu_controller.dart';
import 'package:mycafe/view/widget/custom_text_field.dart';
import 'package:mycafe/view/widget/primary_button.dart';
import 'package:provider/provider.dart';
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
  
  // Ambil data menu dari Firestore
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

  // Update data menu
  Future<void> _updateMenu() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    final menuController = Provider.of<CafeMenuController>(context, listen: false);

    try {
      await menuController.updateMenu(
        docId: widget.docId,
        namaMenu: _namaController.text,
        harga: int.parse(_hargaController.text),
        kategori: _kategoriController.text,
      );

      if (mounted) {
        Get.snackbar(
          'Berhasil',
          'Menu berhasil diperbarui.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
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
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Update Menu', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
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