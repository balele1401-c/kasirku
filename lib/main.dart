import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/karyawan_provider.dart';
import 'providers/produk_provider.dart';
import 'providers/toko_provider.dart';
import 'providers/transaksi_provider.dart';
import 'screens/kasir_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/owner_dashboard_screen.dart';
import 'screens/setup_toko_screen.dart';
import 'services/firebase_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  bool firebaseInitialized = false;
  try {
    firebaseInitialized = await FirebaseService.initialize();
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
  }

  runApp(KasirKuApp(firebaseInitialized: firebaseInitialized));
}

class KasirKuApp extends StatelessWidget {
  final bool firebaseInitialized;

  const KasirKuApp({
    super.key,
    required this.firebaseInitialized,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<TokoProvider>(create: (_) => TokoProvider()),
        ChangeNotifierProvider<ProdukProvider>(create: (_) => ProdukProvider()),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<TransaksiProvider>(create: (_) => TransaksiProvider()),
        ChangeNotifierProvider<KaryawanProvider>(create: (_) => KaryawanProvider()),
      ],
      child: MaterialApp(
        title: 'KasirKu UMKM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: firebaseInitialized
            ? const AuthWrapper()
            : const FirebaseErrorScreen(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    if (authProvider.tokoId == null && authProvider.user != null) {
      return const SetupTokoScreen();
    }

    if (authProvider.karyawan == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.karyawan!.isOwner) {
      return const OwnerDashboardScreen();
    } else {
      return const KasirHomeScreen();
    }
  }
}

class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Koneksi Firebase Gagal',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gagal menghubungkan ke Firebase. Pastikan file konfigurasi (firebase_options.dart / google-services.json) telah dikonfigurasi dan perangkat terhubung ke internet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    main();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
