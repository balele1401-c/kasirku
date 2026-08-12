import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/produk_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/produk_provider.dart';
import '../providers/toko_provider.dart';
import '../utils/app_colors.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'owner_dashboard_screen.dart';

class KasirHomeScreen extends StatefulWidget {
  const KasirHomeScreen({super.key});

  @override
  State<KasirHomeScreen> createState() => _KasirHomeScreenState();
}

class _KasirHomeScreenState extends State<KasirHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.tokoId != null) {
        Provider.of<TokoProvider>(context, listen: false)
            .setTokoId(authProvider.tokoId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final tokoProvider = Provider.of<TokoProvider>(context);
    final produkProvider = Provider.of<ProdukProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    final tokoId = authProvider.tokoId;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (tokoId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kasir POS')),
        body: const Center(child: Text('Data Toko tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: AppColors.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tokoProvider.toko?.nama ?? 'KasirKu POS',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      authProvider.karyawan?.nama ?? "Kasir Active",
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (authProvider.karyawan != null && authProvider.karyawan!.isOwner)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.dashboard_outlined,
                  color: AppColors.onSecondaryContainer,
                  size: 20,
                ),
              ),
              tooltip: 'Dashboard Owner',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<ProdukModel>>(
            stream: produkProvider.getProdukStream(tokoId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final produkList = produkProvider.filteredProdukList;
              final categories = ['Semua', ...produkProvider.categories];

              return Column(
                children: [
                  // Search & Category Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (val) => produkProvider.setSearchQuery(val),
                          decoration: InputDecoration(
                            hintText: 'Cari produk...',
                            prefixIcon:
                                const Icon(Icons.search, color: AppColors.outline),
                            suffixIcon: produkProvider.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () =>
                                        produkProvider.setSearchQuery(''),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Horizontal Category Filter
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

                  // Product Grid
                  Expanded(
                    child: produkList.isEmpty
                        ? const Center(
                            child: Text(
                              'Produk tidak ditemukan atau stok habis.',
                              style: TextStyle(color: AppColors.outline),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 8,
                              bottom: 100, // Space for floating cart bar
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 180,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: produkList.length,
                            itemBuilder: (context, index) {
                              final produk = produkList[index];
                              final isOutOfStock = produk.stok <= 0;
                              final inCartQty =
                                  cartProvider.items[produk.id]?.quantity ?? 0;

                              return Card(
                                elevation: 0,
                                color: AppColors.surface,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                      color: AppColors.surfaceVariant, width: 1),
                                ),
                                child: InkWell(
                                  onTap: isOutOfStock
                                      ? null
                                      : () => cartProvider.addItem(produk),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product Image Container
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
                                                      errorBuilder: (context, error, stackTrace) =>
                                                          const Icon(
                                                        Icons.fastfood_rounded,
                                                        size: 40,
                                                        color: AppColors.outline,
                                                      ),
                                                    )
                                                  : const Center(
                                                      child: Icon(
                                                        Icons.fastfood_rounded,
                                                        size: 40,
                                                        color: AppColors.outlineVariant,
                                                      ),
                                                    ),
                                            ),
                                            if (inCartQty > 0)
                                              Positioned(
                                                top: 6,
                                                right: 6,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '$inCartQty',
                                                    style: const TextStyle(
                                                      color: AppColors.onPrimary,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Product Info & Add Button
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
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.onSurface,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    currencyFormatter
                                                        .format(produk.hargaJual),
                                                    style: theme.textTheme.labelLarge
                                                        ?.copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: isOutOfStock
                                                      ? null
                                                      : () => cartProvider
                                                          .addItem(produk),
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: const BoxDecoration(
                                                      color: AppColors
                                                          .secondaryContainer,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      size: 20,
                                                      color: AppColors
                                                          .onSecondaryContainer,
                                                    ),
                                                  ),
                                                ),
                                              ],
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

          // Floating Cart Bar (Bottom)
          if (cartProvider.totalItemCount > 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Card(
                elevation: 8,
                color: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cartProvider.totalItemCount}',
                            style: const TextStyle(
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Keranjang Belanja',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          currencyFormatter.format(cartProvider.totalAmount),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
