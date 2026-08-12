import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/toko_model.dart';
import '../models/transaksi_model.dart';
import '../providers/cart_provider.dart';
import '../providers/toko_provider.dart';
import '../utils/app_colors.dart';
import 'kasir_home_screen.dart';

class StrukScreen extends StatelessWidget {
  final TransaksiModel transaksi;

  const StrukScreen({super.key, required this.transaksi});

  void _shareReceipt(BuildContext context, TokoModel? toko) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id');

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('===========================');
    buffer.writeln(toko?.nama.toUpperCase() ?? 'KASIRKU POS');
    if (toko?.alamat != null && toko!.alamat.isNotEmpty) {
      buffer.writeln(toko.alamat);
    }
    buffer.writeln('===========================');
    buffer.writeln('No. Struk: #${transaksi.id.substring(0, 8)}');
    buffer.writeln('Tanggal: ${dateFormatter.format(transaksi.timestamp)}');
    buffer.writeln('Metode: ${transaksi.metodeBayar}');
    buffer.writeln('---------------------------');

    for (var item in transaksi.items) {
      buffer.writeln(
        '${item.nama}\n  ${item.qty} x ${currencyFormatter.format(item.hargaSatuan)} = ${currencyFormatter.format(item.subtotal)}',
      );
    }

    buffer.writeln('---------------------------');
    buffer.writeln('Total: ${currencyFormatter.format(transaksi.total)}');
    buffer.writeln('Diterima: ${currencyFormatter.format(transaksi.uangDiterima)}');
    buffer.writeln('Kembalian: ${currencyFormatter.format(transaksi.kembalian)}');
    buffer.writeln('===========================');
    buffer.writeln('Terima kasih telah berbelanja!');

    Share.share(buffer.toString(), subject: 'Struk Pembayaran #${transaksi.id.substring(0, 6)}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokoProvider = Provider.of<TokoProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final toko = tokoProvider.toko;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Struk Digital'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      color: AppColors.surfaceContainerLowest,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            // Store Header Logo & Info
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: toko?.logoUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Image.network(
                                        toko!.logoUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.storefront_rounded,
                                      size: 32,
                                      color: AppColors.onPrimaryContainer,
                                    ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              toko?.nama ?? 'Nama Toko',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (toko?.alamat != null && toko!.alamat.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                toko.alamat,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 16),
                            const Divider(thickness: 1, color: AppColors.outlineVariant),
                            const SizedBox(height: 12),

                            // Meta Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Waktu',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  dateFormatter.format(transaksi.timestamp),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Metode Bayar',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    transaksi.metodeBayar,
                                    style: const TextStyle(
                                      color: AppColors.onSecondaryContainer,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(thickness: 1, color: AppColors.outlineVariant),
                            const SizedBox(height: 16),

                            // Items List
                            Column(
                              children: transaksi.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.nama,
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${item.qty} x ${currencyFormatter.format(item.hargaSatuan)}',
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                color: AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        currencyFormatter.format(item.subtotal),
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                            const Divider(thickness: 1, color: AppColors.outlineVariant),
                            const SizedBox(height: 12),

                            // Payment Totals
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total', style: theme.textTheme.titleLarge),
                                Text(
                                  currencyFormatter.format(transaksi.total),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Uang Diterima', style: theme.textTheme.bodyMedium),
                                Text(
                                  currencyFormatter.format(transaksi.uangDiterima),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Kembalian', style: theme.textTheme.bodyMedium),
                                Text(
                                  currencyFormatter.format(transaksi.kembalian),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Terima kasih atas kunjungan Anda!',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.outline,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Action Buttons Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Bagikan Struk'),
                      onPressed: () => _shareReceipt(context, toko),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text('Transaksi Baru'),
                      onPressed: () {
                        cartProvider.clearCart();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const KasirHomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
