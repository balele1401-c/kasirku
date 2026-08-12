import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/produk_model.dart';
import '../services/cloudinary_service.dart';
import '../services/firebase_service.dart';

class ProdukProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  List<ProdukModel> _produkList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  String _searchQuery = '';

  List<ProdukModel> get produkList => _produkList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<String> get categories {
    final set = _produkList.map((p) => p.kategori).where((k) => k.isNotEmpty).toSet();
    return set.toList();
  }

  List<ProdukModel> get filteredProdukList {
    return _produkList.where((produk) {
      final matchesCategory = _selectedCategory == null ||
          _selectedCategory!.isEmpty ||
          produk.kategori.toLowerCase() == _selectedCategory!.toLowerCase();

      final matchesQuery = _searchQuery.isEmpty ||
          produk.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          produk.kategori.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesQuery;
    }).toList();
  }

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Real-time Stream of Products for a given Toko ID
  Stream<List<ProdukModel>> getProdukStream(String tokoId) {
    return _firestore
        .collection('toko')
        .doc(tokoId)
        .collection('produk')
        .snapshots()
        .map((snapshot) {
      _produkList = snapshot.docs.map((doc) => ProdukModel.fromDocument(doc)).toList();
      return _produkList;
    });
  }

  Future<bool> saveProduk({
    required String tokoId,
    String? produkId,
    required String nama,
    required String kategori,
    required double hargaJual,
    required double hargaModal,
    required int stok,
    required int thresholdStokMinim,
    File? fotoFile,
    Uint8List? fotoBytes,
    String? existingFotoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final collectionRef = _firestore
          .collection('toko')
          .doc(tokoId)
          .collection('produk');

      final docRef = produkId != null && produkId.isNotEmpty
          ? collectionRef.doc(produkId)
          : collectionRef.doc();

      String? fotoUrl = existingFotoUrl;

      // Upload product image to Cloudinary if selected
      if (fotoFile != null || fotoBytes != null) {
        try {
          final uploadedUrl = await CloudinaryService.instance.uploadImage(
            imageFile: fotoFile,
            imageBytes: fotoBytes,
            fileName: 'produk_${tokoId}_${docRef.id}.jpg',
          );
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            fotoUrl = uploadedUrl;
          }
        } catch (cloudinaryError) {
          debugPrint('Cloudinary upload error: $cloudinaryError');
          _errorMessage =
              'Gagal mengunggah foto ke Cloudinary. Periksa koneksi internet Anda.';
          // Fallback to existing url
          fotoUrl = existingFotoUrl;
        }
      }

      final produkData = ProdukModel(
        id: docRef.id,
        nama: nama.trim(),
        kategori: kategori.trim(),
        hargaJual: hargaJual,
        hargaModal: hargaModal,
        stok: stok,
        fotoUrl: fotoUrl,
        thresholdStokMinim: thresholdStokMinim,
      );

      await docRef.set(produkData.toMap());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menyimpan produk: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduk({
    required String tokoId,
    required String produkId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore
          .collection('toko')
          .doc(tokoId)
          .collection('produk')
          .doc(produkId)
          .delete();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menghapus produk: $e';
      notifyListeners();
      return false;
    }
  }
}
