import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycafe/model/menu_model.dart';
import 'package:get/get.dart';

class CafeMenuController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'menu';

  Stream<List<MenuModel>> getMenusStream() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('namaMenu')
        .snapshots()
        .map((snapshot) {
          debugPrint(
            "🔄 Mendapatkan ${snapshot.docs.length} dokumen menu dari Firestore",
          );
          return snapshot.docs
              .map((doc) {
                try {
                  final menu = MenuModel.fromFirestore(doc);
                  debugPrint(
                    "✅ Menu berhasil diparse: ${menu.namaMenu} (${doc.id})",
                  );
                  return menu;
                } catch (e) {
                  debugPrint("❌ Gagal parsing menu (${doc.id}): $e");
                  return null;
                }
              })
              .whereType<MenuModel>()
              .toList();
        });
  }

  // Tambah menu baru
  Future<void> addMenu({
    required String namaMenu,
    required int harga,
  }) async {
    try {
      await _firestore.collection(_collectionPath).add({
        'namaMenu': namaMenu,
        'harga': harga,
        'isTersedia': true,
      });
      debugPrint("✅ Menu '$namaMenu' berhasil ditambahkan ke Firestore");
    } catch (e) {
      debugPrint("❌ Error saat menambahkan menu: $e");
    }
  }

  // Update menu
  Future<void> updateMenu({
    required String docId,
    required String namaMenu,
    required int harga,
  }) async {
    try {
      await _firestore.collection(_collectionPath).doc(docId).update({
        'namaMenu': namaMenu,
        'harga': harga,
      });
      debugPrint("✅ Menu '$namaMenu' berhasil diupdate (ID: $docId)");
    } catch (e) {
      debugPrint("❌ Error saat update menu (ID: $docId): $e");
    }
  }

  // Hapus beberapa menu
  Future<void> deleteMenus(List<String> docIds) async {
    final batch = _firestore.batch();
    try {
      for (final docId in docIds) {
        batch.delete(_firestore.collection(_collectionPath).doc(docId));
      }
      await batch.commit();
      debugPrint("✅ ${docIds.length} menu berhasil dihapus.");
    } catch (e) {
      debugPrint("❌ Error saat menghapus menu: $e");
    }
  }
}
