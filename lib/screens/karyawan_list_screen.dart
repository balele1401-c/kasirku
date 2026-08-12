import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/karyawan_model.dart';
import '../providers/auth_provider.dart';
import '../providers/karyawan_provider.dart';
import '../utils/app_colors.dart';

class KaryawanListScreen extends StatefulWidget {
  const KaryawanListScreen({super.key});

  @override
  State<KaryawanListScreen> createState() => _KaryawanListScreenState();
}

class _KaryawanListScreenState extends State<KaryawanListScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showAddKasirDialog(BuildContext context, String tokoId) {
    _namaController.clear();
    _emailController.clear();
    _passwordController.clear();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Tambah Akun Kasir'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Kasir'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(hintText: 'Siti Aminah'),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                const Text('Email Kasir'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(hintText: 'kasir1@toko.com'),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                    if (!val.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                const Text('Password Kasir'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Minimal 6 karakter'),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Wajib diisi';
                    if (val.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              final karyawanProvider =
                  Provider.of<KaryawanProvider>(context, listen: false);
              final success = await karyawanProvider.addKasir(
                tokoId: tokoId,
                nama: _namaController.text,
                email: _emailController.text,
                password: _passwordController.text,
              );

              if (dialogCtx.mounted) {
                Navigator.of(dialogCtx).pop();
              }

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Akun kasir baru berhasil dibuat'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          karyawanProvider.errorMessage ?? 'Gagal membuat akun'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, String tokoId, KaryawanModel karyawan) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Akun Karyawan'),
        content: Text('Apakah Anda yakin ingin menghapus "${karyawan.nama}"?'),
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
              final karyawanProvider =
                  Provider.of<KaryawanProvider>(context, listen: false);
              final success = await karyawanProvider.deleteKasir(
                tokoId: tokoId,
                karyawanId: karyawan.id,
              );
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kasir "${karyawan.nama}" telah dihapus'),
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
    final karyawanProvider = Provider.of<KaryawanProvider>(context);
    final tokoId = authProvider.tokoId;

    if (tokoId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kelola Karyawan')),
        body: const Center(child: Text('Data Toko tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Kelola Karyawan & Kasir'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Kasir'),
        onPressed: () => _showAddKasirDialog(context, tokoId),
      ),
      body: StreamBuilder<List<KaryawanModel>>(
        stream: karyawanProvider.getKaryawanStream(tokoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = karyawanProvider.karyawanList;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final k = list[index];
              final isOwner = k.isOwner;

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isOwner
                        ? AppColors.primaryContainer
                        : AppColors.secondaryContainer,
                    child: Icon(
                      isOwner ? Icons.admin_panel_settings : Icons.person,
                      color: isOwner
                          ? AppColors.onPrimaryContainer
                          : AppColors.onSecondaryContainer,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        k.nama,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOwner
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          k.role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(k.email),
                  ),
                  trailing: !isOwner
                      ? IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          onPressed: () =>
                              _showDeleteDialog(context, tokoId, k),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
