import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
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

class _AdminDataScreenState extends ConsumerState<AdminDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1); // Default tab Toko
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterDataProvider);

    final navItems = const [
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
      body: StateView(
        isLoading: state.isLoading && state.tokoList.isEmpty,
        errorMessage: state.errorMessage,
        onRetry: () => ref.read(masterDataProvider.notifier).loadAll(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data master',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Data acuan yang harus ada sebelum mapping disusun.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tab selector: Sales | Toko | Wilayah | Kriteria
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      labelColor: AppColors.adminTeal,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Sales'),
                        Tab(text: 'Toko'),
                        Tab(text: 'Wilayah'),
                        Tab(text: 'Kriteria'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (state.successBanner != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successBannerBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.successBannerBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.successBannerText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.successBanner!,
                          style: const TextStyle(
                            fontSize: 12,
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
              ),
            ],

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 0: Sales
                  ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.salesList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final sales = state.salesList[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: AppColors.adminTeal,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sales.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${sales.labelPeran} · @${sales.username}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge.kunjungan(sales.aktif),
                          ],
                        ),
                      );
                    },
                  ),

                  // Tab 1: Toko
                  Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: state.tokoList.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final toko = state.tokoList[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          toko.nama,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${toko.noJo} · ${toko.wilayah.nama}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (toko.alamat.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            toko.alamat,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
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
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: PrimaryButton(
                          label: '+ Tambah Data Toko',
                          backgroundColor: AppColors.adminTeal,
                          onPressed: () => context.go('/admin/data/tambah-toko'),
                        ),
                      ),
                    ],
                  ),

                  // Tab 2: Wilayah
                  ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.wilayahList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final w = state.wilayahList[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
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
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              w.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Tab 3: Kriteria
                  ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.kriteriaList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final k = state.kriteriaList[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${k.urutan}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
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
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
