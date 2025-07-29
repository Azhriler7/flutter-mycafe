import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String id;
  final String namaMenu;
  final int harga;
  final bool isTersedia;

  MenuModel({
    required this.id,
    required this.namaMenu,
    required this.harga,
    required this.isTersedia,
  });

  factory MenuModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MenuModel(
      id: doc.id,
      namaMenu: data['namaMenu'] ?? 'Nama Menu',
      harga: data['harga'] ?? 18000,
      isTersedia: data['isTersedia'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaMenu': namaMenu,
      'harga': harga,
      'isTersedia': isTersedia,
    };
  }
}
