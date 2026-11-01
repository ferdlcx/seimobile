import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/master_data_provider.dart';

/// Layar Tambah Data Toko Baru oleh Admin Tagihan.
class TambahTokoScreen extends ConsumerStatefulWidget {
  const TambahTokoScreen({super.key});

  @override
  ConsumerState<TambahTokoScreen> createState() => _TambahTokoScreenState();
}

class _TambahTokoScreenState extends ConsumerState<TambahTokoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController(text: 'Toko Maju Bersama');
  final _noJoController = TextEditingController(text: 'JO-0450');
  final _alamatController =
      TextEditingController(text: 'Jl. Kombas No. 10, Purwokerto');
  int _selectedWilayahId = 1; // Default Purwokerto Timur

  @override
  void dispose() {
    _namaController.dispose();
    _noJoController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(masterDataProvider.notifier).tambahToko(
          nama: _namaController.text.trim(),
          noJo: _noJoController.text.trim().toUpperCase(),
          wilayahId: _selectedWilayahId,
          alamat: _alamatController.text.trim(),
        );

    if (ok && mounted) {
      context.go('/admin/data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterDataProvider);

    return AppScaffold(
      roleLabel: 'Admin Tagihan',
      menuTitle: 'Tambah Toko',
      accentColor: AppColors.adminTeal,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol Kembali
              InkWell(
                onTap: () => context.go('/admin/data'),
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 20,
                        color: Color(0xFF2563EB),
                      ),
                      Text(
                        'Data master',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Tambah Data Toko',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              if (state.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.statusDitolakBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.statusDitolakText.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.statusDitolakText,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Nama Toko
              const Text(
                'Nama toko',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  hintText: 'contoh: Toko Maju Bersama',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama toko wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Nomor JO
              const Text(
                'Nomor JO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noJoController,
                decoration: const InputDecoration(
                  hintText: 'contoh: JO-0450',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nomor JO wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Wilayah (Chip)
              const Text(
                'Wilayah',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.wilayahList.map((w) {
                  final isSelected = _selectedWilayahId == w.id;
                  return ChoiceChip(
                    label: Text(w.nama),
                    selected: isSelected,
                    selectedColor: AppColors.adminTeal,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedWilayahId = w.id);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Alamat
              const Text(
                'Alamat',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _alamatController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Detail jalan, nomor, kecamatan',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Alamat wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                label: 'Simpan Data Toko',
                backgroundColor: AppColors.adminTeal,
                isLoading: state.isLoading,
                onPressed: _handleSimpan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
