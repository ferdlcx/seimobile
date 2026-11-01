import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../admin_data/data/models/master_models.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../providers/kunjungan_provider.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initToko();
    });
  }

  void _initToko() {
    final masterState = ref.read(masterDataProvider);
    final match = masterState.tokoList.where((t) => t.noJo == widget.noJo);
    if (match.isNotEmpty) {
      final t = match.first;
      setState(() => _toko = t);
      ref.read(kunjunganGpsProvider.notifier).perbaruiLokasi(t);
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Toko & Check-in',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              widget.noJo,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: toko == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.salesOrange),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Kartu Informasi Toko
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              toko.nama,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          StatusBadge.kunjungan(toko.sudahDikunjungiBulanIni),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Nomor JO: ${toko.noJo}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Wilayah: ${toko.wilayah.nama}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(height: 20),
                      const Text(
                        'Alamat Lengkap',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        toko.alamat,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (toko.ket.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Catatan: ${toko.ket}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Titik Koordinat: ${toko.lat.toStringAsFixed(4)}, ${toko.lng.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Kartu GPS & Status Radius
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: gpsState.isInRadius
                          ? AppColors.statusSudahText
                          : AppColors.statusDitolakText,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.my_location,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'STATUS LOKASI GPS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: gpsState.isLoadingGps
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.salesOrange,
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh,
                                    size: 20,
                                    color: AppColors.salesOrange,
                                  ),
                            onPressed: gpsState.isLoadingGps
                                ? null
                                : () => ref
                                    .read(kunjunganGpsProvider.notifier)
                                    .perbaruiLokasi(toko),
                            tooltip: 'Perbarui GPS',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: gpsState.isInRadius
                              ? AppColors.statusSudahBg
                              : AppColors.statusDitolakBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              gpsState.isInRadius
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: gpsState.isInRadius
                                  ? AppColors.statusSudahText
                                  : AppColors.statusDitolakText,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gpsState.isInRadius
                                        ? 'DALAM RADIUS CHECK-IN'
                                        : 'DI LUAR RADIUS CHECK-IN',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: gpsState.isInRadius
                                          ? AppColors.statusSudahText
                                          : AppColors.statusDitolakText,
                                    ),
                                  ),
                                  Text(
                                    'Jarak Anda: ${gpsState.jarakM.toStringAsFixed(1)} m (Maks. ${config.radiusCheckinMeter} m)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: gpsState.isInRadius
                                          ? AppColors.statusSudahText
                                          : AppColors.statusDitolakText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              onPressed: () {
                                ref
                                    .read(kunjunganGpsProvider.notifier)
                                    .perbaruiLokasi(toko);
                              },
                              child: const Text(
                                'Simulasi Dekat (12 m)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              onPressed: () {
                                ref
                                    .read(kunjunganGpsProvider.notifier)
                                    .setSimulasiLuarRadius(toko);
                              },
                              child: const Text(
                                'Simulasi Jauh (550 m)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.statusDitolakText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Check-in di Toko Ini
                PrimaryButton(
                  label: 'Check-in di Toko Ini',
                  backgroundColor: AppColors.salesOrange,
                  onPressed: gpsState.isInRadius
                      ? () =>
                          context.push('/sales/kunjungan/wizard/${toko.noJo}')
                      : null,
                ),
                const SizedBox(height: 12),

                // Tombol Ajukan Reschedule
                if (config.enableReschedule)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.salesOrange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(
                      Icons.event_repeat,
                      color: AppColors.salesOrange,
                      size: 20,
                    ),
                    label: const Text(
                      'Ajukan Reschedule Jadwal',
                      style: TextStyle(
                        color: AppColors.salesOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () {
                      context.push('/sales/reschedule/tambah?noJo=${toko.noJo}');
                    },
                  ),
              ],
            ),
    );
  }
}
