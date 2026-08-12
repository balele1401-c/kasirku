import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/produk_model.dart';
import '../models/transaksi_model.dart';
import '../services/firebase_service.dart';

class CartItem {
  final ProdukModel produk;
  int quantity;

  CartItem({
    required this.produk,
    this.quantity = 1,
  });

  double get subtotal => produk.hargaJual * quantity;
}

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  final Map<String, CartItem> _items = {};
  bool _isProcessingTransaction = false;
  String? _errorMessage;

  Map<String, CartItem> get items => {..._items};
  List<CartItem> get cartItemList => _items.values.toList();
  bool get isProcessingTransaction => _isProcessingTransaction;
  String? get errorMessage => _errorMessage;

  int get totalItemCount {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.subtotal;
    });
    return total;
  }

  void addItem(ProdukModel produk) {
    if (_items.containsKey(produk.id)) {
      final existing = _items[produk.id]!;
      if (existing.quantity < produk.stok) {
        existing.quantity += 1;
      }
    } else {
      if (produk.stok > 0) {
        _items[produk.id] = CartItem(produk: produk, quantity: 1);
      }
    }
    notifyListeners();
  }

  void incrementQuantity(String produkId) {
    if (_items.containsKey(produkId)) {
      final item = _items[produkId]!;
      if (item.quantity < item.produk.stok) {
        item.quantity += 1;
        notifyListeners();
      }
    }
  }

  void decrementQuantity(String produkId) {
    if (!_items.containsKey(produkId)) return;
    if (_items[produkId]!.quantity > 1) {
      _items[produkId]!.quantity -= 1;
    } else {
      _items.remove(produkId);
    }
    notifyListeners();
  }

  void removeItem(String produkId) {
    _items.remove(produkId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _errorMessage = null;
    notifyListeners();
  }

  // Atomically process transaction and deduct stock in a Firestore Transaction
  Future<TransaksiModel?> processTransaction({
    required String tokoId,
    required String kasirId,
    required String metodeBayar,
    required double uangDiterima,
  }) async {
    if (_items.isEmpty) return null;

    _isProcessingTransaction = true;
    _errorMessage = null;
    notifyListeners();

    final total = totalAmount;
    final kembalian = uangDiterima - total;
    final timestamp = DateTime.now();

    final transaksiRef = _firestore
        .collection('toko')
        .doc(tokoId)
        .collection('transaksi')
        .doc();

    final List<TransaksiItemModel> transaksiItems = cartItemList.map((item) {
      return TransaksiItemModel(
        produkId: item.produk.id,
        nama: item.produk.nama,
        qty: item.quantity,
        hargaSatuan: item.produk.hargaJual,
      );
    }).toList();

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Read Phase: Perform all reads first (MUST be done before any writes in Firestore)
        final Map<String, DocumentSnapshot<Map<String, dynamic>>> produkSnapshots = {};
        for (var item in cartItemList) {
          final produkRef = _firestore
              .collection('toko')
              .doc(tokoId)
              .collection('produk')
              .doc(item.produk.id);

          final produkSnapshot = await transaction.get(produkRef);
          produkSnapshots[item.produk.id] = produkSnapshot;
        }

        // 2. Validate Phase: Check stock validity for all items
        for (var item in cartItemList) {
          final snapshot = produkSnapshots[item.produk.id];
          if (snapshot == null || !snapshot.exists) {
            throw Exception('Produk ${item.produk.nama} tidak ditemukan.');
          }

          final currentStok = (snapshot.data()?['stok'] ?? 0) as int;
          if (currentStok < item.quantity) {
            throw Exception(
                'Stok ${item.produk.nama} tidak mencukupi (sisa: $currentStok).');
          }
        }

        // 3. Write Phase: Perform all writes (updates & sets) after all reads are complete
        for (var item in cartItemList) {
          final produkRef = _firestore
              .collection('toko')
              .doc(tokoId)
              .collection('produk')
              .doc(item.produk.id);
          final snapshot = produkSnapshots[item.produk.id]!;
          final currentStok = (snapshot.data()?['stok'] ?? 0) as int;

          transaction.update(produkRef, {
            'stok': currentStok - item.quantity,
          });
        }

        // 4. Write Transaksi Document
        final newTransaksi = TransaksiModel(
          id: transaksiRef.id,
          items: transaksiItems,
          total: total,
          metodeBayar: metodeBayar,
          uangDiterima: uangDiterima,
          kembalian: kembalian,
          kasirId: kasirId,
          timestamp: timestamp,
        );

        transaction.set(transaksiRef, newTransaksi.toMap());
      });

      final createdTransaksi = TransaksiModel(
        id: transaksiRef.id,
        items: transaksiItems,
        total: total,
        metodeBayar: metodeBayar,
        uangDiterima: uangDiterima,
        kembalian: kembalian,
        kasirId: kasirId,
        timestamp: timestamp,
      );

      _isProcessingTransaction = false;
      notifyListeners();
      return createdTransaksi;
    } catch (e, stack) {
      debugPrint('================ DETAIL TRANSACTION ERROR ================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stack');
      debugPrint('==========================================================');

      _isProcessingTransaction = false;
      String msg = e.toString();
      if (msg.contains('Exception: ')) {
        msg = msg.split('Exception: ').last;
      }
      _errorMessage = 'Gagal memproses transaksi: $msg';
      notifyListeners();
      return null;
    }
  }
}
