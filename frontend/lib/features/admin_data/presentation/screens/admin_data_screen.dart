import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pill_filter_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/master_data_provider.dart';

/// Layar Pengelolaan Data Master (Sales, Toko, Wilayah, Kriteria) oleh Admin Tagihan.
class AdminDataScreen extends ConsumerStatefulWidget {
  const AdminDataScreen({super.key});

  @override
  ConsumerState<AdminDataScreen> createState() => _AdminDataScreenState();
}

class _AdminDataScreenState extends ConsumerState<AdminDataScreen> {
  int _selectedTab = 1; // Default tab Toko sesuai mockup

  Future<void> _showTambahWilayahDialog() async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Tambah Wilayah Baru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nama Wilayah',
                hintText: 'contoh: Banyumas Utara',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Nama wilayah wajib diisi';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.adminTeal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text('Simpan Wilayah'),
            ),
          ],
        );
      },
    );

    final nama = controller.text.trim();
    controller.dispose();

    if (saved == true && nama.isNotEmpty) {
      final ok = await ref.read(masterDataProvider.notifier).tambahWilayah(nama);
      if (!ok && mounted) {
        final err = ref.read(masterDataProvider).errorMessage;
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err),
              backgroundColor: AppColors.statusDitolakText,
            ),
          );
        }
      }
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

    const tabs = ['Sales', 'Toko', 'Wilayah', 'Kriteria'];

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
      body: StateView(
        isLoading: state.isLoading && state.tokoList.isEmpty,
        errorMessage: state.tokoList.isEmpty && state.wilayahList.isEmpty
            ? state.errorMessage
            : null,
        onRetry: () => ref.read(masterDataProvider.notifier).loadAll(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            const Text(
              'Data master',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Data acuan yang harus ada sebelum mapping disusun.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // 4 Pill Chips: Sales, Toko, Wilayah, Kriteria
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(tabs.length, (idx) {
                return PillChip(
                  label: tabs[idx],
                  selected: _selectedTab == idx,
                  activeColor: AppColors.adminTeal,
                  onTap: () => setState(() => _selectedTab = idx),
                );
              }),
            ),
            const SizedBox(height: 14),

            if (state.successBanner != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.successBannerBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.successBanner!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.successBannerText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          ref.read(masterDataProvider.notifier).clearBanner(),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.successBannerText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (_selectedTab == 0)
              // Tab 0: Sales
              ...state.salesList.map((sales) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sales.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${sales.labelPeran} · @${sales.username}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(
                        text: sales.aktif ? 'Aktif' : 'Nonaktif',
                        type: sales.aktif
                            ? StatusBadgeType.sudah
                            : StatusBadgeType.belum,
                      ),
                    ],
                  ),
                );
              })
            else if (_selectedTab == 1) ...[
              // Tab 1: Toko
              ...state.tokoList.map((toko) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toko.nama,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${toko.noJo} · ${toko.wilayah.nama}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge.kunjungan(
                        toko.sudahDikunjungiBulanIni,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              PrimaryButton(
                label: '+ Tambah Data Toko',
                backgroundColor: AppColors.adminTeal,
                onPressed: () {
                  ref.read(masterDataProvider.notifier).clearBanner();
                  context.go('/admin/data/tambah-toko');
                },
              ),
            ] else if (_selectedTab == 2) ...[
              // Tab 2: Wilayah
              ...state.wilayahList.map((w) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.adminTeal,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        w.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              PrimaryButton(
                label: '+ Tambah Wilayah',
                backgroundColor: AppColors.adminTeal,
                onPressed: _showTambahWilayahDialog,
              ),
            ] else
              // Tab 3: Kriteria
              ...state.kriteriaList.map((k) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${k.urutan}.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          k.nama,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
