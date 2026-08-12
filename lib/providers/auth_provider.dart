import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/karyawan_model.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseService.instance.auth;
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  User? _user;
  KaryawanModel? _karyawan;
  String? _tokoId;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  KaryawanModel? get karyawan => _karyawan;
  String? get tokoId => _tokoId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _user = firebaseUser;
    if (firebaseUser != null) {
      await fetchUserData(firebaseUser.uid);
    } else {
      _karyawan = null;
      _tokoId = null;
    }
    notifyListeners();
  }

  Future<void> fetchUserData(String uid) async {
    try {
      // Find employee/karyawan document across toko collections or directly by query
      final tokoQuery = await _firestore.collection('toko').get();
      for (var tokoDoc in tokoQuery.docs) {
        final karyawanDoc = await _firestore
            .collection('toko')
            .doc(tokoDoc.id)
            .collection('karyawan')
            .doc(uid)
            .get();

        if (karyawanDoc.exists) {
          _tokoId = tokoDoc.id;
          _karyawan = KaryawanModel.fromDocument(karyawanDoc);
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = credential.user;

      if (_user != null) {
        await fetchUserData(_user!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Pengguna dengan email ini tidak ditemukan.';
          break;
        case 'wrong-password':
          _errorMessage = 'Password yang dimasukkan salah.';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid.';
          break;
        case 'user-disabled':
          _errorMessage = 'Akun ini telah dinonaktifkan.';
          break;
        case 'invalid-credential':
          _errorMessage = 'Email atau password salah.';
          break;
        default:
          _errorMessage = e.message ?? 'Gagal melakukan login.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan sistem: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String nama, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = credential.user;

      if (_user != null) {
        await _user!.updateDisplayName(nama.trim());
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'Email sudah terdaftar. Silakan login.';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid.';
          break;
        case 'weak-password':
          _errorMessage = 'Password terlalu lemah. Gunakan minimal 6 karakter.';
          break;
        default:
          _errorMessage = e.message ?? 'Gagal mendaftar akun.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan sistem: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _karyawan = null;
    _tokoId = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
