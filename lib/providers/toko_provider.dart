import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/karyawan_model.dart';
import '../models/toko_model.dart';
import '../services/cloudinary_service.dart';
import '../services/firebase_service.dart';

class TokoProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  TokoModel? _toko;
  bool _isLoading = false;
  String? _errorMessage;

  TokoModel? get toko => _toko;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setTokoId(String tokoId) {
    fetchToko(tokoId);
  }

  Future<void> fetchToko(String tokoId) async {
    try {
      final doc = await _firestore.collection('toko').doc(tokoId).get();
      if (doc.exists) {
        _toko = TokoModel.fromDocument(doc);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching toko: $e');
    }
  }

  Future<bool> setupToko({
    required User user,
    required String namaToko,
    required String alamat,
    File? logoFile,
    Uint8List? logoBytes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokoRef = _firestore.collection('toko').doc();
      String? logoUrl;

      // Upload logo to Cloudinary if provided
      if (logoFile != null || logoBytes != null) {
        try {
          final uploadedUrl = await CloudinaryService.instance.uploadImage(
            imageFile: logoFile,
            imageBytes: logoBytes,
            fileName: 'logo_${tokoRef.id}.jpg',
          );
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            logoUrl = uploadedUrl;
          }
        } catch (cloudinaryError) {
          debugPrint('Cloudinary logo upload error: $cloudinaryError');
          logoUrl = null;
        }
      }

      // 1. Create Toko document
      final newToko = TokoModel(
        id: tokoRef.id,
        nama: namaToko.trim(),
        alamat: alamat.trim(),
        logoUrl: logoUrl,
        ownerId: user.uid,
      );

      await tokoRef.set(newToko.toMap());

      // 2. Create Owner Karyawan document inside /toko/{tokoId}/karyawan/{userId}
      final karyawanOwner = KaryawanModel(
        id: user.uid,
        nama: user.displayName ?? user.email?.split('@').first ?? 'Owner Toko',
        role: 'owner',
        email: user.email ?? '',
        tokoId: tokoRef.id,
      );

      await tokoRef
          .collection('karyawan')
          .doc(user.uid)
          .set(karyawanOwner.toMap());

      _toko = newToko;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menyimpan data toko: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateToko({
    required String tokoId,
    required String namaToko,
    required String alamat,
    File? logoFile,
    Uint8List? logoBytes,
    String? existingLogoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? logoUrl = existingLogoUrl;

      if (logoFile != null || logoBytes != null) {
        try {
          final uploadedUrl = await CloudinaryService.instance.uploadImage(
            imageFile: logoFile,
            imageBytes: logoBytes,
            fileName: 'logo_$tokoId.jpg',
          );
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            logoUrl = uploadedUrl;
          }
        } catch (cloudinaryError) {
          debugPrint('Cloudinary logo upload error: $cloudinaryError');
          logoUrl = existingLogoUrl;
        }
      }

      final updatedToko = TokoModel(
        id: tokoId,
        nama: namaToko.trim(),
        alamat: alamat.trim(),
        logoUrl: logoUrl,
        ownerId: _toko?.ownerId ?? '',
      );

      await _firestore.collection('toko').doc(tokoId).update(updatedToko.toMap());

      _toko = updatedToko;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memperbarui profil toko: $e';
      notifyListeners();
      return false;
    }
  }
}
