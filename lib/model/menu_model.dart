import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String id;
  final String namaMenu;
  final int harga;
  final String kategori;
  final bool isTersedia;

  MenuModel({
    required this.id,
    required this.namaMenu,
    required this.harga,
    required this.kategori,
    required this.isTersedia,
  });

  factory MenuModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MenuModel(
      id: doc.id,
      namaMenu: data['namaMenu'] ?? 'Tanpa Nama',
      harga: data['harga'] ?? 0,
      kategori: data['kategori'] ?? 'lainnya',
      isTersedia: data['isTersedia'] ?? true,
    );
  }
}