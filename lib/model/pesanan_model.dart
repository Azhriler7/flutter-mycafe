import 'package:cloud_firestore/cloud_firestore.dart';

class PesananItemModel {
  final String namaMenu;
  final int harga;
  final int jumlah;

  PesananItemModel({
    required this.namaMenu,
    required this.harga,
    required this.jumlah,
  });

  factory PesananItemModel.fromMap(Map<String, dynamic> map) {
    return PesananItemModel(
      namaMenu: map['namaMenu']?.toString() ?? 'N/A',
      harga: _parseInt(map['harga']),
      jumlah: _parseInt(map['jumlah']),
    );
  }

  // Helper method untuk convert ke int
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class PesananModel {
  final String id;
  final String userId;
  final String namaPemesan;
  final String noMeja;
  final List<PesananItemModel> items;
  final int totalHarga;
  final String statusPesanan;
  final Timestamp waktuPesan;

  PesananModel({
    required this.id,
    required this.userId,
    required this.namaPemesan,
    required this.noMeja,
    required this.items,
    required this.totalHarga,
    required this.statusPesanan,
    required this.waktuPesan,
  });

  factory PesananModel.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<PesananItemModel> itemsList = [];
      if (data['items'] != null) {
        try {
          for (var item in data['items']) {
            if (item is Map<String, dynamic>) {
              itemsList.add(PesananItemModel.fromMap(item));
            }
          }
        } catch (e) {
          // Continue without this item
        }
      }

      return PesananModel(
        id: doc.id,
        userId: _parseString(data['userId']),
        namaPemesan: _parseString(data['namaPemesan']),
        noMeja: _parseString(data['noMeja']),
        items: itemsList,
        totalHarga: _parseInt(data['totalHarga']),
        statusPesanan: _parseString(data['statusPesanan']),
        waktuPesan: data['waktuPesan'] as Timestamp? ?? Timestamp.now(),
      );
    } catch (e) {
      return PesananModel(
        id: doc.id,
        userId: 'unknown',
        namaPemesan: 'Error Loading',
        noMeja: 'N/A',
        items: [],
        totalHarga: 0,
        statusPesanan: 'error',
        waktuPesan: Timestamp.now(),
      );
    }
  }

  // Helper methods untuk type conversion
  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}