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

  void _showDeleteDialog(
      BuildContext context, String tokoId, ProdukModel produk) {
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
            icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

          final produkList = produkProvider.filteredProdukList;
          final categories = ['Semua', ...produkProvider.categories];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Context Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manajemen Produk',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola katalog dan stok barang Anda.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              // Product List (Stitch exact list item format)
              Expanded(
                child: produkList.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada produk.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: 90,
                        ),
                        itemCount: produkList.length,
                        itemBuilder: (context, index) {
                          final produk = produkList[index];
                          final isLowStock = produk.isStokMenipis;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isLowStock
                                    ? AppColors.errorContainer
                                    : AppColors.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Red indicator line on left for low stock
                                if (isLowStock)
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 4,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Product Image Thumbnail
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainerHigh,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: produk.fotoUrl != null &&
                                                produk.fotoUrl!.isNotEmpty
                                            ? Image.network(
                                                produk.fotoUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stackTrace) =>
                                                        const Icon(
                                                  Icons.fastfood_outlined,
                                                  color:
                                                      AppColors.onSurfaceVariant,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.fastfood_outlined,
                                                color:
                                                    AppColors.onSurfaceVariant,
                                              ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Product Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              produk.nama,
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.onSurface,
                                                fontSize: 15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              produk.kategori,
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                color:
                                                    AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              currencyFormatter
                                                  .format(produk.hargaJual),
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Stock Status Badge & Edit/Delete Action Icons
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isLowStock
                                                  ? AppColors.errorContainer
                                                  : AppColors.secondaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isLowStock
                                                  ? 'Stok Rendah (${produk.stok})'
                                                  : 'Stok: ${produk.stok}',
                                              style: TextStyle(
                                                color: isLowStock
                                                    ? AppColors.onErrorContainer
                                                    : AppColors
                                                        .onSecondaryContainer,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          ProdukFormScreen(
                                                        produk: produk,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Icon(
                                                    Icons.edit_outlined,
                                                    size: 20,
                                                    color: AppColors
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () => _showDeleteDialog(
                                                    context, tokoId, produk),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Icon(
                                                    Icons.delete_outline_rounded,
                                                    size: 20,
                                                    color: AppColors.error,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
