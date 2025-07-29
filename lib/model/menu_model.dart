import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String id;
  final String namaMenu;
  final int harga;
  final String kategori;
  final bool isTersedia;
  final String gambar;

  MenuModel({
    required this.id,
    required this.namaMenu,
    required this.harga,
    required this.kategori,
    required this.isTersedia,
    required this.gambar,
  });

  factory MenuModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MenuModel(
      id: doc.id,
      namaMenu: data['namaMenu'] ?? 'Nama Menu',
      harga: data['harga'] ?? 18000,
      kategori: data['kategori'] ?? 'Minuman',
      isTersedia: data['isTersedia'] ?? true,
      gambar:
          data['gambar'] ??
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQP7PzXpj11ISpb2pI5WjxOaFayqiv2w4qZxA&s',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaMenu': namaMenu,
      'harga': harga,
      'kategori': kategori,
      'isTersedia': isTersedia,
      'gambar': gambar,
    };
  }
}
