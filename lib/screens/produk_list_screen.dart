import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/produk_model.dart';
import '../providers/auth_provider.dart';
import '../providers/produk_provider.dart';
import '../utils/app_colors.dart';
import 'produk_form_screen.dart';

class ProdukListScreen extends StatelessWidget {
  const ProdukListScreen({super.key});

  void _showDeleteDialog(BuildContext context, String tokoId, ProdukModel produk) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus "${produk.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final produkProvider =
                  Provider.of<ProdukProvider>(context, listen: false);
              final success = await produkProvider.deleteProduk(
                tokoId: tokoId,
                produkId: produk.id,
              );
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Produk "${produk.nama}" telah dihapus'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final produkProvider = Provider.of<ProdukProvider>(context);
    final tokoId = authProvider.tokoId;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (tokoId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manajemen Produk')),
        body: const Center(child: Text('Data Toko tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProdukFormScreen()),
          );
        },
      ),
      body: StreamBuilder<List<ProdukModel>>(
        stream: produkProvider.getProdukStream(tokoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          final produkList = produkProvider.filteredProdukList;
          final categories = ['Semua', ...produkProvider.categories];

          return Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => produkProvider.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Cari produk atau kategori...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                        suffixIcon: produkProvider.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => produkProvider.setSearchQuery(''),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Chips Horizontal Scroll
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = (cat == 'Semua' &&
                                  produkProvider.selectedCategory == null) ||
                              cat == produkProvider.selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  produkProvider.setCategoryFilter(
                                      cat == 'Semua' ? null : cat);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Product List Grid
              Expanded(
                child: produkList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: AppColors.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada produk',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Klik tombol "Tambah Produk" di bawah untuk memulai.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: produkList.length,
                        itemBuilder: (context, index) {
                          final produk = produkList[index];
                          final isLowStock = produk.isStokMenipis;

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProdukFormScreen(produk: produk),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Photo Header
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          color: AppColors.surfaceContainerHigh,
                                          child: produk.fotoUrl != null &&
                                                  produk.fotoUrl!.isNotEmpty
                                              ? Image.network(
                                                  produk.fotoUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (context, error, stackTrace) =>
                                                          const Icon(
                                                    Icons.image_not_supported,
                                                    size: 40,
                                                    color: AppColors.outline,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.fastfood_rounded,
                                                  size: 48,
                                                  color: AppColors.outline,
                                                ),
                                        ),

                                        // Category Badge
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withAlpha(153),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              produk.kategori,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Delete Button
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: AppColors.error,
                                            ),
                                            onPressed: () => _showDeleteDialog(
                                                context, tokoId, produk),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Product Info Body
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          produk.nama,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          currencyFormatter.format(produk.hargaJual),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        // Stock Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isLowStock
                                                ? AppColors.errorContainer
                                                : AppColors.secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Stok: ${produk.stok}',
                                            style: TextStyle(
                                              color: isLowStock
                                                  ? AppColors.onErrorContainer
                                                  : AppColors.onSecondaryContainer,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
