import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycafe/model/menu_model.dart';

class CafeMenuController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'menu';

  // Ambil stream daftar menu
  Stream<List<MenuModel>> getMenusStream() {
    return _firestore.collection(_collectionPath).orderBy('namaMenu').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MenuModel.fromFirestore(doc)).toList();
    });
  }

  // Tambah menu baru
  Future<void> addMenu({
    required String namaMenu,
    required int harga,
    required String kategori,
  }) async {
    await _firestore.collection(_collectionPath).add({
      'namaMenu': namaMenu,
      'harga': harga,
      'kategori': kategori.isNotEmpty ? kategori.toLowerCase() : 'lainnya',
      'isTersedia': true,
    });
  }

  // Update data menu
  Future<void> updateMenu({
    required String docId,
    required String namaMenu,
    required int harga,
    required String kategori,
  }) async {
    await _firestore.collection(_collectionPath).doc(docId).update({
      'namaMenu': namaMenu,
      'harga': harga,
      'kategori': kategori.isNotEmpty ? kategori.toLowerCase() : 'lainnya',
    });
  }

  // Hapus beberapa menu sekaligus
  Future<void> deleteMenus(List<String> docIds) async {
    final batch = _firestore.batch();
    for (final docId in docIds) {
      batch.delete(_firestore.collection(_collectionPath).doc(docId));
    }
    await batch.commit();
  }
}