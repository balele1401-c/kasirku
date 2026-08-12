import 'package:cloud_firestore/cloud_firestore.dart';

class ProdukModel {
  final String id;
  final String nama;
  final String kategori;
  final double hargaJual;
  final double hargaModal;
  final int stok;
  final String? fotoUrl;
  final int thresholdStokMinim;

  ProdukModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.hargaJual,
    required this.hargaModal,
    required this.stok,
    this.fotoUrl,
    this.thresholdStokMinim = 5,
  });

  factory ProdukModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProdukModel(
      id: docId,
      nama: map['nama'] ?? '',
      kategori: map['kategori'] ?? '',
      hargaJual: (map['hargaJual'] ?? 0).toDouble(),
      hargaModal: (map['hargaModal'] ?? 0).toDouble(),
      stok: (map['stok'] ?? 0).toInt(),
      fotoUrl: map['fotoUrl'],
      thresholdStokMinim: (map['thresholdStokMinim'] ?? 5).toInt(),
    );
  }

  factory ProdukModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProdukModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'kategori': kategori,
      'hargaJual': hargaJual,
      'hargaModal': hargaModal,
      'stok': stok,
      'fotoUrl': fotoUrl,
      'thresholdStokMinim': thresholdStokMinim,
    };
  }

  bool get isStokMenipis => stok <= thresholdStokMinim;
}
