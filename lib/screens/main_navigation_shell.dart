import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import 'karyawan_list_screen.dart';
import 'kasir_home_screen.dart';
import 'owner_dashboard_screen.dart';
import 'pengaturan_toko_screen.dart';
import 'produk_list_screen.dart';
import 'riwayat_transaksi_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;
  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.karyawan?.isOwner ?? false;

    // Defined Navigation items based on role
    final List<Widget> pages = isOwner
        ? [
            const OwnerDashboardScreen(),
            const KasirHomeScreen(),
            const ProdukListScreen(),
            const RiwayatTransaksiScreen(),
            const KaryawanListScreen(),
            const PengaturanTokoScreen(),
          ]
        : [
            const KasirHomeScreen(),
            const RiwayatTransaksiScreen(),
            const ProdukListScreen(),
            const PengaturanTokoScreen(),
          ];

    final List<NavigationDestination> destinations = isOwner
        ? const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined),
              selectedIcon: Icon(Icons.point_of_sale_rounded),
              label: 'Kasir POS',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2_rounded),
              label: 'Produk',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Transaksi',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Kasir',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Pengaturan',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined),
              selectedIcon: Icon(Icons.point_of_sale_rounded),
              label: 'Kasir POS',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Transaksi',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2_rounded),
              label: 'Produk',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Pengaturan',
            ),
          ];

    // Ensure _currentIndex is within bounds when switching roles
    final safeIndex = _currentIndex < pages.length ? _currentIndex : 0;

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.surfaceVariant, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.surfaceContainerLowest,
          indicatorColor: AppColors.secondaryContainer,
          elevation: 0,
          destinations: destinations,
        ),
      ),
    );
  }
}
