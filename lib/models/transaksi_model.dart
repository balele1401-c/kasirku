import 'package:cloud_firestore/cloud_firestore.dart';

class TransaksiItemModel {
  final String produkId;
  final String nama;
  final int qty;
  final double hargaSatuan;

  TransaksiItemModel({
    required this.produkId,
    required this.nama,
    required this.qty,
    required this.hargaSatuan,
  });

  double get subtotal => qty * hargaSatuan;

  factory TransaksiItemModel.fromMap(Map<String, dynamic> map) {
    return TransaksiItemModel(
      produkId: map['produkId'] ?? '',
      nama: map['nama'] ?? '',
      qty: (map['qty'] ?? 0).toInt(),
      hargaSatuan: (map['hargaSatuan'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'produkId': produkId,
      'nama': nama,
      'qty': qty,
      'hargaSatuan': hargaSatuan,
    };
  }
}

class TransaksiModel {
  final String id;
  final List<TransaksiItemModel> items;
  final double total;
  final String metodeBayar; // Tunai, Transfer, QRIS
  final double uangDiterima;
  final double kembalian;
  final String kasirId;
  final DateTime timestamp;

  TransaksiModel({
    required this.id,
    required this.items,
    required this.total,
    required this.metodeBayar,
    required this.uangDiterima,
    required this.kembalian,
    required this.kasirId,
    required this.timestamp,
  });

  factory TransaksiModel.fromMap(Map<String, dynamic> map, String docId) {
    var rawItems = map['items'] as List<dynamic>? ?? [];
    List<TransaksiItemModel> itemList = rawItems
        .map((item) => TransaksiItemModel.fromMap(item as Map<String, dynamic>))
        .toList();

    DateTime parsedDate;
    if (map['timestamp'] is Timestamp) {
      parsedDate = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      parsedDate = DateTime.tryParse(map['timestamp']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return TransaksiModel(
      id: docId,
      items: itemList,
      total: (map['total'] ?? 0).toDouble(),
      metodeBayar: map['metodeBayar'] ?? 'Tunai',
      uangDiterima: (map['uangDiterima'] ?? 0).toDouble(),
      kembalian: (map['kembalian'] ?? 0).toDouble(),
      kasirId: map['kasirId'] ?? '',
      timestamp: parsedDate,
    );
  }

  factory TransaksiModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TransaksiModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'metodeBayar': metodeBayar,
      'uangDiterima': uangDiterima,
      'kembalian': kembalian,
      'kasirId': kasirId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
