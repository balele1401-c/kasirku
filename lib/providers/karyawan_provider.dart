import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../models/karyawan_model.dart';
import '../services/firebase_service.dart';

class KaryawanProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  List<KaryawanModel> _karyawanList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<KaryawanModel> get karyawanList => _karyawanList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<List<KaryawanModel>> getKaryawanStream(String tokoId) {
    return _firestore
        .collection('toko')
        .doc(tokoId)
        .collection('karyawan')
        .snapshots()
        .map((snapshot) {
      _karyawanList =
          snapshot.docs.map((doc) => KaryawanModel.fromDocument(doc)).toList();
      return _karyawanList;
    });
  }

  // Create new cashier using secondary Firebase app to avoid logging out current owner session
  Future<bool> addKasir({
    required String tokoId,
    required String nama,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    FirebaseApp? secondaryApp;

    try {
      // Initialize secondary Firebase App instance for cashier creation
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryAuthApp_${DateTime.now().millisecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final newUserId = credential.user!.uid;

      // Save cashier document to /toko/{tokoId}/karyawan/{userId}
      final kasirData = KaryawanModel(
        id: newUserId,
        nama: nama.trim(),
        role: 'kasir',
        email: email.trim(),
        tokoId: tokoId,
      );

      await _firestore
          .collection('toko')
          .doc(tokoId)
          .collection('karyawan')
          .doc(newUserId)
          .set(kasirData.toMap());

      await secondaryApp.delete();

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (secondaryApp != null) await secondaryApp.delete();
      _isLoading = false;
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'Email sudah terdaftar.';
          break;
        case 'weak-password':
          _errorMessage = 'Password minimal 6 karakter.';
          break;
        default:
          _errorMessage = e.message ?? 'Gagal membuat akun kasir.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      if (secondaryApp != null) await secondaryApp.delete();
      _isLoading = false;
      _errorMessage = 'Gagal memproses data: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteKasir({
    required String tokoId,
    required String karyawanId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore
          .collection('toko')
          .doc(tokoId)
          .collection('karyawan')
          .doc(karyawanId)
          .delete();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menghapus karyawan: $e';
      notifyListeners();
      return false;
    }
  }
}
