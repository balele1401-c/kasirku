import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaksi_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/struk_screen.dart';
import '../utils/app_colors.dart';

class PaymentBottomSheet extends StatefulWidget {
  const PaymentBottomSheet({super.key});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final TextEditingController _bayarController = TextEditingController();
  String _selectedMetode = 'Tunai';

  @override
  void initState() {
    super.initState();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    _bayarController.text = cartProvider.totalAmount.toInt().toString();
  }

  @override
  void dispose() {
    _bayarController.dispose();
    super.dispose();
  }

  void _setNominal(double amount) {
    setState(() {
      _bayarController.text = amount.toInt().toString();
    });
  }

  void _confirmPayment() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final tokoId = authProvider.tokoId;
    final user = authProvider.user;

    if (tokoId == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID Toko atau Kasir tidak valid.')),
      );
      return;
    }

    final double uangDiterima = double.tryParse(_bayarController.text) ?? 0;
    if (uangDiterima < cartProvider.totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang yang diterima kurang dari total belanja.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final TransaksiModel? result = await cartProvider.processTransaction(
      tokoId: tokoId,
      kasirId: user.uid,
      metodeBayar: _selectedMetode,
      uangDiterima: uangDiterima,
    );

    if (!mounted) return;

    if (result != null) {
      Navigator.of(context).pop(); // Close bottom sheet
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => StrukScreen(transaksi: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final double total = cartProvider.totalAmount;
    final double uangDiterima = double.tryParse(_bayarController.text) ?? 0;
    final double kembalian = uangDiterima >= total ? uangDiterima - total : 0;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Pembayaran',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Total Tagihan Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Tagihan',
                    style: TextStyle(
                      color: AppColors.onPrimaryContainer,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    currencyFormatter.format(total),
                    style: const TextStyle(
                      color: AppColors.onPrimaryContainer,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pilih Metode Pembayaran
            Text('Metode Pembayaran', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: ['Tunai', 'Transfer', 'QRIS'].map((metode) {
                final isSelected = _selectedMetode == metode;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Center(child: Text(metode)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedMetode = metode;
                          });
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Input Uang Diterima
            Text('Uang Diterima', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _bayarController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
              ),
            ),
            const SizedBox(height: 12),

            // Quick Nominal Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: {
                  total,
                  (total / 10000).ceil() * 10000.0,
                  (total / 20000).ceil() * 20000.0,
                  (total / 50000).ceil() * 50000.0,
                  100000.0,
                }.where((nominal) => nominal >= total).map((nominal) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                      onPressed: () => _setNominal(nominal),
                      child: Text(currencyFormatter.format(nominal)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Kembalian Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kembalian',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    currencyFormatter.format(kembalian),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            if (cartProvider.errorMessage != null) ...[
              Text(
                cartProvider.errorMessage!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            // Confirm Button
            ElevatedButton(
              onPressed: cartProvider.isProcessingTransaction ||
                      uangDiterima < total
                  ? null
                  : _confirmPayment,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: cartProvider.isProcessingTransaction
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onPrimary,
                        ),
                      ),
                    )
                  : const Text('Konfirmasi & Cetak Struk'),
            ),
          ],
        ),
      ),
    );
  }
}
