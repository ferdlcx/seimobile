import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/kondite_saya_provider.dart';

/// Layar Kondite Saya (Read-only) untuk peran Sales.
class KonditeSayaScreen extends ConsumerStatefulWidget {
  const KonditeSayaScreen({super.key});

  @override
  ConsumerState<KonditeSayaScreen> createState() => _KonditeSayaScreenState();
}

class _KonditeSayaScreenState extends ConsumerState<KonditeSayaScreen> {
  bool _showAllKriteria = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(konditeSayaProvider);
    final auth = ref.watch(authProvider);
    final config = ref.watch(appConfigProvider);

    final navItems = [
      const RoleNavItem(
        label: 'Mapping',
        icon: Icons.map_outlined,
        route: '/sales/mapping',
      ),
      const RoleNavItem(
        label: 'Kunjungan',
        icon: Icons.place_outlined,
        route: '/sales/kunjungan',
      ),
      if (config.enableReschedule)
        const RoleNavItem(
          label: 'Reschedule',
          icon: Icons.event_repeat_outlined,
          route: '/sales/reschedule',
        ),
      const RoleNavItem(
        label: 'Kondite',
        icon: Icons.star_outline,
        route: '/sales/kondite',
      ),
    ];

    final salesNama = auth.session?.user.nama ?? 'Budi Santoso';
    final penilaian = state.penilaian;
    final kriteriaList = state.kriteriaList;
    final visibleKriteria = _showAllKriteria
        ? kriteriaList
        : kriteriaList.take(6).toList();

    return AppScaffold(
      roleLabel: 'Sales',
      menuTitle: 'Kondite',
      accentColor: AppColors.salesOrange,
      navItems: navItems,
      currentNavIndex: config.enableReschedule ? 3 : 2,
      onNavTap: (idx) => context.go(navItems[idx].route),
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go('/pilih-peran');
        }
      },
      body: StateView(
        isLoading: state.isLoading && penilaian == null,
        errorMessage: state.errorMessage,
        onRetry: () =>
            ref.read(konditeSayaProvider.notifier).loadKonditeSaya(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            const Text(
              'Kondite saya',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sales hanya bisa melihat nilai. Penilaian dilakukan manajer.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Kartu Nilai Bulan Ini (Navy rata kiri)
            if (penilaian != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.navyHeader,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NILAI BULAN INI · OKT 2026',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      penilaian.nilaiAkhir.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${penilaian.label} · $salesNama',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '18 KRITERIA (6 TERATAS)',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
                if (kriteriaList.length > 6)
                  InkWell(
                    onTap: () =>
                        setState(() => _showAllKriteria = !_showAllKriteria),
                    child: Text(
                      _showAllKriteria ? 'Tampilkan 6 teratas' : 'Lihat semua',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.salesOrange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (kriteriaList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppColors.salesOrange),
                ),
              )
            else
              ...visibleKriteria.map((kriteria) {
                final kodeNilai = penilaian?.detail[kriteria.id] ?? 'B';
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
                        child: Text(
                          kriteria.nama,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      NilaiKonditeBadge(nilai: kodeNilai),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 4),
            const Text(
              'Tidak ada tombol ubah di layar ini.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
