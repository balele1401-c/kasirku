import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/produk_model.dart';
import '../providers/auth_provider.dart';
import '../providers/produk_provider.dart';
import '../utils/app_colors.dart';

class ProdukFormScreen extends StatefulWidget {
  final ProdukModel? produk;

  const ProdukFormScreen({super.key, this.produk});

  @override
  State<ProdukFormScreen> createState() => _ProdukFormScreenState();
}

class _ProdukFormScreenState extends State<ProdukFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _hargaModalController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _thresholdController = TextEditingController(text: '5');

  File? _selectedFotoFile;
  Uint8List? _selectedFotoBytes;
  String? _existingFotoUrl;

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      final p = widget.produk!;
      _namaController.text = p.nama;
      _kategoriController.text = p.kategori;
      _hargaJualController.text = p.hargaJual.toInt().toString();
      _hargaModalController.text = p.hargaModal.toInt().toString();
      _stokController.text = p.stok.toString();
      _thresholdController.text = p.thresholdStokMinim.toString();
      _existingFotoUrl = p.fotoUrl;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _hargaJualController.dispose();
    _hargaModalController.dispose();
    _stokController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _pickFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedFotoBytes = bytes;
        });
      } else {
        setState(() {
          _selectedFotoFile = File(picked.path);
        });
      }
    }
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final produkProvider = Provider.of<ProdukProvider>(context, listen: false);
    final tokoId = authProvider.tokoId;

    if (tokoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID Toko tidak ditemukan.')),
      );
      return;
    }

    final success = await produkProvider.saveProduk(
      tokoId: tokoId,
      produkId: widget.produk?.id,
      nama: _namaController.text,
      kategori: _kategoriController.text,
      hargaJual: double.parse(_hargaJualController.text),
      hargaModal: double.parse(_hargaModalController.text),
      stok: int.parse(_stokController.text),
      thresholdStokMinim: int.parse(_thresholdController.text),
      fotoFile: _selectedFotoFile,
      fotoBytes: _selectedFotoBytes,
      existingFotoUrl: _existingFotoUrl,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.produk == null
                ? 'Produk berhasil ditambahkan'
                : 'Produk berhasil diperbarui',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final produkProvider = Provider.of<ProdukProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(widget.produk == null ? 'Tambah Produk' : 'Edit Produk'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Upload Area
                GestureDetector(
                  onTap: _pickFoto,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant),
                      image: _selectedFotoBytes != null
                          ? DecorationImage(
                              image: MemoryImage(_selectedFotoBytes!),
                              fit: BoxFit.cover,
                            )
                          : _selectedFotoFile != null
                              ? DecorationImage(
                                  image: FileImage(_selectedFotoFile!),
                                  fit: BoxFit.cover,
                                )
                              : _existingFotoUrl != null &&
                                      _existingFotoUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(_existingFotoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                    ),
                    child: _selectedFotoBytes == null &&
                            _selectedFotoFile == null &&
                            (_existingFotoUrl == null ||
                                _existingFotoUrl!.isEmpty)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: AppColors.outline,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Upload Foto Produk',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Nama Produk
                Text('Nama Produk', style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Es Kopi Susu Aren',
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Kategori
                Text('Kategori', style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _kategoriController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Minuman, Makanan, Snack',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Kategori wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // Harga Jual & Harga Modal Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harga Jual (Rp)', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _hargaJualController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '18000'),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                              if (double.tryParse(val) == null) return 'Angka saja';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harga Modal (Rp)', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _hargaModalController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '10000'),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                              if (double.tryParse(val) == null) return 'Angka saja';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stok Awal & Threshold Min Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Stok Awal', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _stokController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '50'),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                              if (int.tryParse(val) == null) return 'Angka saja';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Batas Stok Minim', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _thresholdController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '5'),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                              if (int.tryParse(val) == null) return 'Angka saja';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: produkProvider.isLoading ? null : _handleSave,
                  child: produkProvider.isLoading
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
                      : Text(widget.produk == null ? 'Simpan Produk' : 'Update Produk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
