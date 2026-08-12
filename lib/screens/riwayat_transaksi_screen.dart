import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaksi_model.dart';
import '../providers/auth_provider.dart';
import '../providers/transaksi_provider.dart';
import '../screens/struk_screen.dart';
import '../utils/app_colors.dart';

class RiwayatTransaksiScreen extends StatelessWidget {
  const RiwayatTransaksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final transaksiProvider = Provider.of<TransaksiProvider>(context);
    final tokoId = authProvider.tokoId;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id');

    final filterOptions = ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Semua'];

    if (tokoId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Transaksi')),
        body: const Center(child: Text('Data Toko tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        elevation: 0,
      ),
      body: StreamBuilder<List<TransaksiModel>>(
        stream: transaksiProvider.getTransaksiStream(tokoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transaksiList = transaksiProvider.filteredTransaksiList;

          return Column(
            children: [
              // Filter Chip Row
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterOptions.map((periode) {
                      final isSelected =
                          transaksiProvider.filterPeriode == periode;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(periode),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              transaksiProvider.setFilterPeriode(periode);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Transaction List
              Expanded(
                child: transaksiList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: AppColors.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada transaksi',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Transaksi yang telah selesai akan muncul di sini.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: transaksiList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final t = transaksiList[index];

                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_rounded,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#${t.id.substring(0, t.id.length > 8 ? 8 : t.id.length)}',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(t.total),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateFormatter.format(t.timestamp),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        t.metodeBayar,
                                        style: const TextStyle(
                                          color: AppColors.onSecondaryContainer,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => StrukScreen(transaksi: t),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
