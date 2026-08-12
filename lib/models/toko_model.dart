import 'package:cloud_firestore/cloud_firestore.dart';

class TokoModel {
  final String id;
  final String nama;
  final String alamat;
  final String? logoUrl;
  final String ownerId;

  TokoModel({
    required this.id,
    required this.nama,
    required this.alamat,
    this.logoUrl,
    required this.ownerId,
  });

  factory TokoModel.fromMap(Map<String, dynamic> map, String docId) {
    return TokoModel(
      id: docId,
      nama: map['nama'] ?? '',
      alamat: map['alamat'] ?? '',
      logoUrl: map['logoUrl'],
      ownerId: map['ownerId'] ?? '',
    );
  }

  factory TokoModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TokoModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'alamat': alamat,
      'logoUrl': logoUrl,
      'ownerId': ownerId,
    };
  }
}
