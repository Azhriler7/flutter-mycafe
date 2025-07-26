import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycafe/model/pesanan_model.dart';

class PesananController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'pesanan';

  // Ambil stream pesanan baru
  Stream<List<PesananModel>> getNewOrdersStream() {
    try {
      return _firestore
          .collection(_collectionPath)
          .where('statusPesanan', isEqualTo: 'baru')
          .snapshots()
          .map((snapshot) {
        
        List<PesananModel> orders = [];
        for (var doc in snapshot.docs) {
          try {
            final order = PesananModel.fromFirestore(doc);
            orders.add(order);
          } catch (e) {
            continue;
          }
        }
        
        orders.sort((a, b) => b.waktuPesan.compareTo(a.waktuPesan));
        return orders;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Ambil stream semua pesanan
  Stream<List<PesananModel>> getAllOrdersStream() {
    try {
      return _firestore
          .collection(_collectionPath)
          .snapshots()
          .map((snapshot) {
        
        List<PesananModel> orders = [];
        for (var doc in snapshot.docs) {
          try {
            final order = PesananModel.fromFirestore(doc);
            orders.add(order);
          } catch (e) {
            continue;
          }
        }
        
        orders.sort((a, b) => b.waktuPesan.compareTo(a.waktuPesan));
        return orders;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Buat pesanan baru
  Future<void> placeOrder({
    required String userId,
    required String namaPemesan,
    required String noMeja,
    required List<Map<String, dynamic>> items,
    required double totalHarga,
  }) async {
    try {
      await _firestore.collection(_collectionPath).add({
        'userId': userId.toString(),
        'namaPemesan': namaPemesan.toString(),
        'noMeja': noMeja.toString(),
        'items': items,
        'totalHarga': totalHarga.toInt(),
        'statusPesanan': 'baru',
        'waktuPesan': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update status pesanan
  Future<void> updateOrderStatus({
    required String docId,
    required String newStatus,
  }) async {
    try {
      await _firestore.collection(_collectionPath).doc(docId).update({
        'statusPesanan': newStatus.toString(),
      });
    } catch (e) {
      rethrow;
    }
  }
}