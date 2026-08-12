import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/toko_provider.dart';
import '../utils/app_colors.dart';
import 'owner_dashboard_screen.dart';

class SetupTokoScreen extends StatefulWidget {
  const SetupTokoScreen({super.key});

  @override
  State<SetupTokoScreen> createState() => _SetupTokoScreenState();
}

class _SetupTokoScreenState extends State<SetupTokoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  File? _selectedLogoFile;
  Uint8List? _selectedLogoBytes;

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedLogoBytes = bytes;
        });
      } else {
        setState(() {
          _selectedLogoFile = File(picked.path);
        });
      }
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tokoProvider = Provider.of<TokoProvider>(context, listen: false);

    if (authProvider.user == null) return;

    final success = await tokoProvider.setupToko(
      user: authProvider.user!,
      namaToko: _namaController.text,
      alamat: _alamatController.text,
      logoFile: _selectedLogoFile,
      logoBytes: _selectedLogoBytes,
    );

    if (!mounted) return;

    if (success) {
      // Refresh AuthProvider data to link user to the created toko
      await authProvider.fetchUserData(authProvider.user!.uid);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokoProvider = Provider.of<TokoProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Setup Toko Anda'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Selamat Datang di KasirKu!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lengkapi informasi toko Anda untuk mulai mengelola produk dan transaksi.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Logo Upload Container
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.outlineVariant,
                                  width: 2,
                                ),
                                image: _selectedLogoBytes != null
                                    ? DecorationImage(
                                        image: MemoryImage(_selectedLogoBytes!),
                                        fit: BoxFit.cover,
                                      )
                                    : _selectedLogoFile != null
                                        ? DecorationImage(
                                            image: FileImage(_selectedLogoFile!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: _selectedLogoBytes == null &&
                                      _selectedLogoFile == null
                                  ? const Icon(
                                      Icons.storefront_rounded,
                                      size: 48,
                                      color: AppColors.outline,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Logo Toko (Opsional)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Error Message Banner
                    if (tokoProvider.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tokoProvider.errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Nama Toko Field
                    Text(
                      'Nama Toko',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Toko Kopi Sejahtera',
                        prefixIcon: Icon(Icons.store_outlined, color: AppColors.outline),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nama toko wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Alamat Toko Field
                    Text(
                      'Alamat Toko',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _alamatController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Jl. Merdeka No. 12, Jakarta',
                        prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.outline),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Alamat toko wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: tokoProvider.isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: tokoProvider.isLoading
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
                          : const Text('Simpan & Lanjutkan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
