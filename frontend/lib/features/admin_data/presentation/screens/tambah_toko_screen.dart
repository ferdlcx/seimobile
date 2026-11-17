import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pill_filter_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/master_data_provider.dart';

/// Layar Tambah Data Toko Baru oleh Admin Tagihan.
class TambahTokoScreen extends ConsumerStatefulWidget {
  const TambahTokoScreen({super.key});

  @override
  ConsumerState<TambahTokoScreen> createState() => _TambahTokoScreenState();
}

class _TambahTokoScreenState extends ConsumerState<TambahTokoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _noJoController = TextEditingController();
  final _alamatController = TextEditingController();
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

    const navItems = [
      RoleNavItem(
        label: 'Akun',
        icon: Icons.people_outline,
        route: '/admin/akun',
      ),
      RoleNavItem(
        label: 'Data',
        icon: Icons.storage_outlined,
        route: '/admin/data',
      ),
      RoleNavItem(
        label: 'Mapping',
        icon: Icons.grid_on_outlined,
        route: '/admin/mapping',
      ),
      RoleNavItem(
        label: 'Laporan',
        icon: Icons.assessment_outlined,
        route: '/admin/laporan',
      ),
    ];

    return AppScaffold(
      roleLabel: 'Admin Tagihan',
      menuTitle: 'Data',
      accentColor: AppColors.adminTeal,
      navItems: navItems,
      currentNavIndex: 1,
      onNavTap: (idx) => context.go(navItems[idx].route),
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go('/pilih-peran');
        }
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        size: 18,
                        color: AppColors.adminTeal,
                      ),
                      Text(
                        'Data master',
                        style: TextStyle(
                          color: AppColors.adminTeal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Tambah Data Toko',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

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
                const SizedBox(height: 14),
              ],

              // Nama Toko
              const Text(
                'Nama toko',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _namaController,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
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
              const SizedBox(height: 12),

              // Nomor JO
              const Text(
                'Nomor JO',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _noJoController,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
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
              const SizedBox(height: 12),

              // Wilayah (Pill Chips)
              const Text(
                'Wilayah',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              WilayahFilterBar(
                wilayahList: state.wilayahList,
                selectedWilayahId: _selectedWilayahId,
                includeAll: false,
                activeColor: AppColors.adminTeal,
                onSelected: (id) {
                  if (id != null) {
                    setState(() => _selectedWilayahId = id);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Alamat
              const Text(
                'Alamat',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _alamatController,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
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
              const SizedBox(height: 18),

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
