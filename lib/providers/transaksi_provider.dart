import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/transaksi_model.dart';
import '../services/firebase_service.dart';

class TransaksiProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  List<TransaksiModel> _transaksiList = [];
  String _filterPeriode = 'Hari Ini'; // Hari Ini, Minggu Ini, Bulan Ini, Semua

  List<TransaksiModel> get transaksiList => _transaksiList;
  String get filterPeriode => _filterPeriode;

  void setFilterPeriode(String periode) {
    _filterPeriode = periode;
    notifyListeners();
  }

  List<TransaksiModel> get filteredTransaksiList {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    return _transaksiList.where((t) {
      if (_filterPeriode == 'Hari Ini') {
        return t.timestamp.isAfter(todayStart.subtract(const Duration(seconds: 1)));
      } else if (_filterPeriode == 'Minggu Ini') {
        return t.timestamp.isAfter(weekStart.subtract(const Duration(seconds: 1)));
      } else if (_filterPeriode == 'Bulan Ini') {
        return t.timestamp.isAfter(monthStart.subtract(const Duration(seconds: 1)));
      }
      return true; // Semua
    }).toList();
  }

  // Real-time Stream of Transactions
  Stream<List<TransaksiModel>> getTransaksiStream(String tokoId) {
    return _firestore
        .collection('toko')
        .doc(tokoId)
        .collection('transaksi')
        .snapshots()
        .map((snapshot) {
      _transaksiList =
          snapshot.docs.map((doc) => TransaksiModel.fromDocument(doc)).toList();
      _transaksiList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return _transaksiList;
    });
  }

  // Dashboard Aggregation Helpers
  double get totalPenjualanHariIni {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    double sum = 0;
    for (var t in _transaksiList) {
      if (t.timestamp.isAfter(todayStart.subtract(const Duration(seconds: 1)))) {
        sum += t.total;
      }
    }
    return sum;
  }

  int get jumlahTransaksiHariIni {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    int count = 0;
    for (var t in _transaksiList) {
      if (t.timestamp.isAfter(todayStart.subtract(const Duration(seconds: 1)))) {
        count++;
      }
    }
    return count;
  }

  Map<int, double> get penjualanMingguan {
    // Map weekday 1..7 to total sales
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

    Map<int, double> result = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    for (var t in _transaksiList) {
      if (t.timestamp.isAfter(weekStart.subtract(const Duration(seconds: 1)))) {
        int day = t.timestamp.weekday;
        result[day] = (result[day] ?? 0) + t.total;
      }
    }
    return result;
  }
}
