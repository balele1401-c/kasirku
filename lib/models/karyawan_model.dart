import 'package:cloud_firestore/cloud_firestore.dart';

class KaryawanModel {
  final String id;
  final String nama;
  final String role; // 'owner' atau 'kasir'
  final String email;
  final String? tokoId;

  KaryawanModel({
    required this.id,
    required this.nama,
    required this.role,
    required this.email,
    this.tokoId,
  });

  bool get isOwner => role.toLowerCase() == 'owner';
  bool get isKasir => role.toLowerCase() == 'kasir';

  factory KaryawanModel.fromMap(Map<String, dynamic> map, String docId) {
    return KaryawanModel(
      id: docId,
      nama: map['nama'] ?? '',
      role: map['role'] ?? 'kasir',
      email: map['email'] ?? '',
      tokoId: map['tokoId'],
    );
  }

  factory KaryawanModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return KaryawanModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'role': role,
      'email': email,
      if (tokoId != null) 'tokoId': tokoId,
    };
  }
}
