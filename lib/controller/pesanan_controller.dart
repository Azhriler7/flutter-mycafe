import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycafe/model/pesanan_model.dart';
import 'package:get/get.dart';

class PesananController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'pesanan';

  // Stream pesanan baru
  Stream<List<PesananModel>> getNewOrdersStream() {
    try {
      return _firestore
          .collection(_collectionPath)
          .where('statusPesanan', isEqualTo: 'baru')
          .orderBy('waktuPesan', descending: true)
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

  // Stream semua pesanan
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

  // Stream pesanan selesai
  Stream<List<PesananModel>> getCompletedOrdersStream() {
    try {
      return _firestore
          .collection(_collectionPath)
          .where('statusPesanan', isEqualTo: 'selesai')
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
        
        // Sort berdasarkan waktuSelesai
        orders.sort((a, b) {
          final timeA = a.waktuSelesai ?? a.waktuPesan;
          final timeB = b.waktuSelesai ?? b.waktuPesan;
          return timeB.compareTo(timeA);
        });
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
      // Ambil username dari collection users
      String username = namaPemesan; 
      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          username = userData['username'] ?? namaPemesan;
        }
      } catch (e) {
        // Jika gagal ambil username, pakai namaPemesan sebagai fallback
      }

      await _firestore.collection(_collectionPath).add({
        'userId': userId.toString(),
        'namaPemesan': username, 
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
      Map<String, dynamic> updateData = {
        'statusPesanan': newStatus.toString(),
      };
      
      // Tambah waktu selesai jika status selesai
      if (newStatus == 'selesai') {
        updateData['waktuSelesai'] = Timestamp.now();
      }
      
      await _firestore.collection(_collectionPath).doc(docId).update(updateData);
    } catch (e) {
      rethrow;
    }
  }
}