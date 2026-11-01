import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/progress_card.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../mapping/presentation/providers/mapping_hari_ini_provider.dart';

enum FilterKunjunganStatus { semua, belum, sudah }

class SalesKunjunganScreen extends ConsumerStatefulWidget {
  const SalesKunjunganScreen({super.key});

  @override
  ConsumerState<SalesKunjunganScreen> createState() =>
      _SalesKunjunganScreenState();
}

class _SalesKunjunganScreenState extends ConsumerState<SalesKunjunganScreen> {
  FilterKunjunganStatus _filter = FilterKunjunganStatus.semua;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mappingHariIniProvider);
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
    final tanggalStr = AppFormat.formatTanggalHari(config.mockToday);

    final data = state.data;
    final total = data?.totalTarget ?? 6;
    final sudah = data?.sudahDikunjungi ?? 4;
    final belum = (total - sudah).clamp(0, total);
    final progress = total > 0 ? (sudah / total) : 0.0;

    final daftarToko = (data?.daftarToko ?? []).where((toko) {
      if (_filter == FilterKunjunganStatus.belum) {
        return !toko.sudahDikunjungiBulanIni;
      }
      if (_filter == FilterKunjunganStatus.sudah) {
        return toko.sudahDikunjungiBulanIni;
      }
      return true;
    }).toList();

    return AppScaffold(
      roleLabel: 'Sales',
      menuTitle: 'Kunjungan',
      accentColor: AppColors.salesOrange,
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
        isLoading: state.isLoading && data == null,
        errorMessage: state.errorMessage,
        onRetry: () =>
            ref.read(mappingHariIniProvider.notifier).loadMappingHariIni(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            const Text(
              'Progress Rute Kunjungan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$tanggalStr · $salesNama',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Kartu Ringkasan Progres
            ProgressCard(
              title: 'PROGRES RUTE KUNJUNGAN',
              mainValue: '$sudah / $total',
              subtitle: belum == 0
                  ? 'Semua target kunjungan telah selesai!'
                  : '$belum toko menunggu untuk dikunjungi',
              progress: progress,
              progressColor: AppColors.salesOrange,
            ),
            const SizedBox(height: 16),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _filter == FilterKunjunganStatus.semua,
                    selectedColor: AppColors.salesOrange,
                    labelStyle: TextStyle(
                      color: _filter == FilterKunjunganStatus.semua
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _filter = FilterKunjunganStatus.semua);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Belum Dikunjungi'),
                    selected: _filter == FilterKunjunganStatus.belum,
                    selectedColor: AppColors.salesOrange,
                    labelStyle: TextStyle(
                      color: _filter == FilterKunjunganStatus.belum
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _filter = FilterKunjunganStatus.belum);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Selesai Dikunjungi'),
                    selected: _filter == FilterKunjunganStatus.sudah,
                    selectedColor: AppColors.salesOrange,
                    labelStyle: TextStyle(
                      color: _filter == FilterKunjunganStatus.sudah
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _filter = FilterKunjunganStatus.sudah);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (daftarToko.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: const Text(
                  'Tidak ada toko dalam kategori ini.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              )
            else
              ...daftarToko.map((toko) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      context.push('/sales/kunjungan/detail/${toko.noJo}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: toko.sudahDikunjungiBulanIni
                                  ? AppColors.statusSudahBg
                                  : AppColors.statusBelumBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              toko.sudahDikunjungiBulanIni
                                  ? Icons.check_circle_outline
                                  : Icons.storefront_outlined,
                              color: toko.sudahDikunjungiBulanIni
                                  ? AppColors.statusSudahText
                                  : AppColors.statusBelumText,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  toko.nama,
                                  style: const TextStyle(
                                    fontSize: 14,
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
                                const SizedBox(height: 4),
                                Text(
                                  toko.alamat,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StatusBadge.kunjungan(
                                toko.sudahDikunjungiBulanIni,
                              ),
                              const SizedBox(height: 6),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
