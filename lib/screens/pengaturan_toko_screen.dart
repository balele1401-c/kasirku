import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/toko_provider.dart';
import '../utils/app_colors.dart';

class PengaturanTokoScreen extends StatefulWidget {
  const PengaturanTokoScreen({super.key});

  @override
  State<PengaturanTokoScreen> createState() => _PengaturanTokoScreenState();
}

class _PengaturanTokoScreenState extends State<PengaturanTokoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _alamatController;

  File? _selectedLogoFile;
  Uint8List? _selectedLogoBytes;
  String? _existingLogoUrl;

  @override
  void initState() {
    super.initState();
    final toko = Provider.of<TokoProvider>(context, listen: false).toko;
    _namaController = TextEditingController(text: toko?.nama ?? '');
    _alamatController = TextEditingController(text: toko?.alamat ?? '');
    _existingLogoUrl = toko?.logoUrl;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
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

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tokoProvider = Provider.of<TokoProvider>(context, listen: false);

    final tokoId = authProvider.tokoId;
    if (tokoId == null) return;

    final success = await tokoProvider.updateToko(
      tokoId: tokoId,
      namaToko: _namaController.text,
      alamat: _alamatController.text,
      logoFile: _selectedLogoFile,
      logoBytes: _selectedLogoBytes,
      existingLogoUrl: _existingLogoUrl,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil toko berhasil diperbarui'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final tokoProvider = Provider.of<TokoProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Pengaturan Toko'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Toko Upload Area
              Center(
                child: GestureDetector(
                  onTap: _pickLogo,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.outlineVariant, width: 2),
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
                                  : _existingLogoUrl != null &&
                                          _existingLogoUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(_existingLogoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                        ),
                        child: _selectedLogoBytes == null &&
                                _selectedLogoFile == null &&
                                (_existingLogoUrl == null ||
                                    _existingLogoUrl!.isEmpty)
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
              Center(
                child: Text(
                  'Ubah Logo Toko',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info Toko Section
              Text('Informasi Toko', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),

              Text('Nama Toko', style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  hintText: 'Nama Toko Anda',
                  prefixIcon: Icon(Icons.store, color: AppColors.outline),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Nama toko wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              Text('Alamat Toko', style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              TextFormField(
                controller: _alamatController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Alamat lengkap toko',
                  prefixIcon: Icon(Icons.location_on, color: AppColors.outline),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Alamat wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // Info Owner Section
              Text('Info Akun Owner', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(Icons.person, color: AppColors.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.karyawan?.nama ?? 'Owner',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              authProvider.karyawan?.email ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: tokoProvider.isLoading ? null : _handleSave,
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
                    : const Text('Simpan Perubahan'),
              ),
              const SizedBox(height: 16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Keluar (Logout)'),
                  onPressed: () async {
                    await authProvider.logout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
