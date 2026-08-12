import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/payment_bottom_sheet.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final cartItems = cartProvider.cartItemList;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        elevation: 0,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => cartProvider.clearCart(),
              child: const Text(
                'Kosongkan',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: AppColors.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keranjang Masih Kosong',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih produk dari halaman kasir untuk menambahkan.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Item List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final produk = item.produk;

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Product Thumbnail
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                  image: produk.fotoUrl != null &&
                                          produk.fotoUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(produk.fotoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: produk.fotoUrl == null ||
                                        produk.fotoUrl!.isEmpty
                                    ? const Icon(
                                        Icons.fastfood_rounded,
                                        color: AppColors.outline,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),

                              // Item Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      produk.nama,
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFormatter.format(produk.hargaJual),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Stepper Controls
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () {
                                      cartProvider.decrementQuantity(produk.id);
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      color: item.quantity < produk.stok
                                          ? AppColors.primary
                                          : AppColors.outlineVariant,
                                    ),
                                    onPressed: item.quantity < produk.stok
                                        ? () {
                                            cartProvider
                                                .incrementQuantity(produk.id);
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Checkout Summary Bar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Pembayaran', style: theme.textTheme.titleLarge),
                          Text(
                            currencyFormatter.format(cartProvider.totalAmount),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const PaymentBottomSheet(),
                          );
                        },
                        child: const Text('Lanjut ke Pembayaran'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
