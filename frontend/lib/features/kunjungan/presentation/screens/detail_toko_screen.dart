import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../admin_data/data/models/master_models.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/jurnal_kunjungan_model.dart';
import '../providers/kunjungan_provider.dart';

/// Layar Detail Toko & Validasi Radius GPS sebelum Check-in.
class DetailTokoScreen extends ConsumerStatefulWidget {
  final String noJo;

  const DetailTokoScreen({
    super.key,
    required this.noJo,
  });

  @override
  ConsumerState<DetailTokoScreen> createState() => _DetailTokoScreenState();
}

class _DetailTokoScreenState extends ConsumerState<DetailTokoScreen> {
  Toko? _toko;
  JurnalKunjungan? _latestFinalJournal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initToko();
    });
  }

  Future<void> _initToko() async {
    final masterState = ref.read(masterDataProvider);
    final match = masterState.tokoList.where((t) => t.noJo == widget.noJo);
    if (match.isNotEmpty) {
      final t = match.first;
      setState(() => _toko = t);
      ref.read(kunjunganGpsProvider.notifier).perbaruiLokasi(t);
    }
    await _loadLatestJournal();
  }

  Future<void> _loadLatestJournal() async {
    final latest =
        await ref.read(jurnalRepositoryProvider).getLatestFinal(widget.noJo);
    if (mounted) {
      setState(() => _latestFinalJournal = latest);
    }
  }

  void _toggleSimulasiGps(Toko toko, bool currentlyInRadius) {
    if (currentlyInRadius) {
      ref.read(kunjunganGpsProvider.notifier).setSimulasiLuarRadius(toko);
    } else {
      ref.read(kunjunganGpsProvider.notifier).perbaruiLokasi(toko);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gpsState = ref.watch(kunjunganGpsProvider);
    final config = ref.watch(appConfigProvider);

    if (_toko == null) {
      final masterState = ref.watch(masterDataProvider);
      final match = masterState.tokoList.where((t) => t.noJo == widget.noJo);
      if (match.isNotEmpty) {
        _toko = match.first;
      }
    }

    final toko = _toko;

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
      body: toko == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.salesOrange),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // Back link "< Rute hari ini"
                InkWell(
                  onTap: () => context.go('/sales/kunjungan'),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chevron_left_rounded,
                          size: 18,
                          color: AppColors.salesOrange,
                        ),
                        Text(
                          'Rute hari ini',
                          style: TextStyle(
                            color: AppColors.salesOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Nama Toko & Subjudul JO + Alamat
                Text(
                  toko.nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${toko.noJo} · ${toko.alamat}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),

                // Kartu Lokasi GPS Ringkas
                GestureDetector(
                  onLongPress: () => _toggleSimulasiGps(toko, gpsState.isInRadius),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: gpsState.isInRadius
                          ? AppColors.softSurface
                          : AppColors.statusDitolakBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: gpsState.isInRadius
                            ? AppColors.border
                            : AppColors.statusDitolakText.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LOKASI GPS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: gpsState.isInRadius
                                    ? AppColors.textSecondary
                                    : AppColors.statusDitolakText,
                              ),
                            ),
                            InkWell(
                              key: const Key('gps_sim_toggle'),
                              onTap: () =>
                                  _toggleSimulasiGps(toko, gpsState.isInRadius),
                              borderRadius: BorderRadius.circular(4),
                              child: Icon(
                                gpsState.isLoadingGps
                                    ? Icons.sync
                                    : Icons.my_location,
                                size: 15,
                                color: gpsState.isInRadius
                                    ? AppColors.textSecondary
                                    : AppColors.statusDitolakText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Jarak ke toko ${gpsState.jarakM.round()} m',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: gpsState.isInRadius
                                ? AppColors.textPrimary
                                : AppColors.statusDitolakText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          gpsState.isInRadius
                              ? 'Anda berada di dalam radius check-in.'
                              : 'Di luar radius check-in (maks. ${config.radiusCheckinMeter.round()} m).',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: gpsState.isInRadius
                                ? AppColors.textSecondary
                                : AppColors.statusDitolakText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Tombol Check-in di Toko Ini
                PrimaryButton(
                  label: 'Check-in di Toko Ini',
                  backgroundColor: AppColors.salesOrange,
                  onPressed: gpsState.isInRadius
                      ? () async {
                          await context
                              .push('/sales/kunjungan/wizard/${toko.noJo}');
                          await _loadLatestJournal();
                        }
                      : null,
                ),
                const SizedBox(height: 10),

                // Tombol Ajukan Reschedule
                if (config.enableReschedule)
                  PrimaryButton(
                    label: 'Ajukan Reschedule',
                    isOutlined: true,
                    backgroundColor: AppColors.salesOrange,
                    onPressed: () {
                      context.push('/sales/reschedule/tambah?noJo=${toko.noJo}');
                    },
                  ),

                if (_latestFinalJournal != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JURNAL TERCATAT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_latestFinalJournal!.jenisAktivitas} · ${_latestFinalJournal!.hasil.label}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_latestFinalJournal!.catatan.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _latestFinalJournal!.catatan,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        PrimaryButton(
                          label: 'Edit Jurnal yang Sudah Dibuat',
                          icon: Icons.edit_outlined,
                          isOutlined: true,
                          backgroundColor: AppColors.salesOrange,
                          onPressed: () async {
                            await context.push(
                              '/sales/kunjungan/wizard/${toko.noJo}?editId=${_latestFinalJournal!.id}',
                            );
                            await _loadLatestJournal();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
