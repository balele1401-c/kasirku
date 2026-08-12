import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/produk_model.dart';
import '../models/transaksi_model.dart';
import '../providers/auth_provider.dart';
import '../providers/produk_provider.dart';
import '../providers/toko_provider.dart';
import '../providers/transaksi_provider.dart';
import '../utils/app_colors.dart';
import 'karyawan_list_screen.dart';
import 'login_screen.dart';
import 'pengaturan_toko_screen.dart';
import 'produk_list_screen.dart';
import 'riwayat_transaksi_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final tokoProvider = Provider.of<TokoProvider>(context);
    final produkProvider = Provider.of<ProdukProvider>(context);
    final transaksiProvider = Provider.of<TransaksiProvider>(context);

    final tokoId = authProvider.tokoId;
    final toko = tokoProvider.toko;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (tokoId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard Owner')),
        body: const Center(child: Text('Data Toko tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'KasirKu',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
            tooltip: 'Pengaturan Toko',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PengaturanTokoScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Keluar (Logout)',
            onPressed: () async {
              debugPrint('[LOGOUT] Tombol logout di OwnerDashboardScreen diklik.');
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ProdukModel>>(
        stream: produkProvider.getProdukStream(tokoId),
        builder: (context, snapshotProduk) {
          return StreamBuilder<List<TransaksiModel>>(
            stream: transaksiProvider.getTransaksiStream(tokoId),
            builder: (context, snapshotTransaksi) {
              if (snapshotProduk.connectionState == ConnectionState.waiting &&
                      !snapshotProduk.hasData &&
                      produkProvider.produkList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshotTransaksi.connectionState == ConnectionState.waiting &&
                      !snapshotTransaksi.hasData &&
                      transaksiProvider.transaksiList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final produkList = produkProvider.produkList;
              final stokMenipisList =
                  produkList.where((p) => p.isStokMenipis).toList();

              final totalHariIni = transaksiProvider.totalPenjualanHariIni;
              final countHariIni = transaksiProvider.jumlahTransaksiHariIni;
              final penjualanMingguan = transaksiProvider.penjualanMingguan;

              // Find top selling product
              Map<String, int> produkQtyMap = {};
              for (var t in transaksiProvider.transaksiList) {
                for (var item in t.items) {
                  produkQtyMap[item.nama] =
                      (produkQtyMap[item.nama] ?? 0) + item.qty;
                }
              }
              String topProdukNama = '-';
              int topProdukQty = 0;
              if (produkQtyMap.isNotEmpty) {
                var sorted = produkQtyMap.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                topProdukNama = sorted.first.key;
                topProdukQty = sorted.first.value;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Low Stock Alert Banner (In-App)
                    if (stokMenipisList.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.error),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${stokMenipisList.length} produk dengan stok menipis!',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppColors.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ProdukListScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Cek Stok',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Title Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard Overview',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              toko?.nama ?? 'Ringkasan performa bisnis Anda',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Nav Bar Action Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickActionButton(
                            context,
                            label: 'Kelola Produk',
                            icon: Icons.inventory_2_outlined,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const ProdukListScreen()),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildQuickActionButton(
                            context,
                            label: 'Kelola Kasir',
                            icon: Icons.people_outline,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const KaryawanListScreen()),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildQuickActionButton(
                            context,
                            label: 'Riwayat Transaksi',
                            icon: Icons.history_rounded,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const RiwayatTransaksiScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3 Summary Cards Column/Grid (Stitch Design exact replica)
                    Column(
                      children: [
                        // Card 1: Penjualan Hari Ini
                        _buildStitchSummaryCard(
                          context,
                          title: 'Penjualan Hari Ini',
                          value: currencyFormatter.format(totalHariIni),
                          subtitle: '+15% dari statistik kemarin',
                          icon: Icons.payments_outlined,
                          iconBgColor: AppColors.primaryContainer,
                          iconColor: AppColors.onPrimaryContainer,
                        ),
                        const SizedBox(height: 12),

                        // Card 2: Total Transaksi
                        _buildStitchSummaryCard(
                          context,
                          title: 'Total Transaksi',
                          value: '$countHariIni Transaksi',
                          subtitle: 'Diperbarui real-time',
                          icon: Icons.receipt_long_outlined,
                          iconBgColor: AppColors.secondaryContainer,
                          iconColor: AppColors.onSecondaryContainer,
                        ),
                        const SizedBox(height: 12),

                        // Card 3: Produk Terlaris
                        _buildStitchSummaryCard(
                          context,
                          title: 'Produk Terlaris',
                          value: topProdukNama,
                          subtitle: topProdukQty > 0
                              ? '$topProdukQty Terjual'
                              : 'Belum ada data',
                          icon: Icons.star_outline_rounded,
                          iconBgColor: AppColors.tertiaryContainer,
                          iconColor: AppColors.onTertiaryContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weekly Sales Bar Chart Container
                    Card(
                      elevation: 0,
                      color: AppColors.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                            color: AppColors.surfaceVariant, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tren Penjualan (Sen - Min)',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Minggu Ini',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 180,
                              child: BarChart(
                                BarChartData(
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          const days = [
                                            'Sen',
                                            'Sel',
                                            'Rab',
                                            'Kam',
                                            'Jum',
                                            'Sab',
                                            'Min'
                                          ];
                                          int index = value.toInt() - 1;
                                          if (index >= 0 && index < 7) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                days[index],
                                                style: theme.textTheme.labelMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.onSurfaceVariant,
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: [1, 2, 3, 4, 5, 6, 7].map((day) {
                                    final val = penjualanMingguan[day] ?? 0;
                                    return BarChartGroupData(
                                      x: day,
                                      barRods: [
                                        BarChartRodData(
                                          toY: val > 0 ? val : 20000,
                                          color: day == DateTime.now().weekday
                                              ? AppColors.primary
                                              : AppColors.surfaceContainerHighest,
                                          width: 18,
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(6),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Peringatan Stok Rendah (Stitch exact list view)
                    Card(
                      elevation: 0,
                      color: AppColors.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                            color: AppColors.surfaceVariant, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Peringatan Stok Rendah',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.error,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            stokMenipisList.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: Center(
                                      child: Text(
                                        'Semua stok produk mencukupi 👍',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: stokMenipisList.map((produk) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainerLow,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: AppColors.outlineVariant),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceContainerHigh,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.inventory_2_outlined,
                                                color: AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    produk.nama,
                                                    style: theme.textTheme
                                                        .labelLarge
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Kategori: ${produk.kategori}',
                                                    style: theme.textTheme
                                                        .labelMedium
                                                        ?.copyWith(
                                                      color: AppColors
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.errorContainer,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'Stok: ${produk.stok}',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.onErrorContainer,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _buildStitchSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
