import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../mapping/presentation/providers/mapping_hari_ini_provider.dart';
import '../../data/models/jurnal_kunjungan_model.dart';
import '../providers/kunjungan_provider.dart';

/// Wizard 2-Langkah Jurnal Kunjungan Sales:
/// Step 0: HASIL KUNJUNGAN 1/3
/// Step 1: ORDER & BUKTI 3/3
class WizardJurnalScreen extends ConsumerStatefulWidget {
  final String noJo;

  const WizardJurnalScreen({
    super.key,
    required this.noJo,
  });

  @override
  ConsumerState<WizardJurnalScreen> createState() => _WizardJurnalScreenState();
}

class _WizardJurnalScreenState extends ConsumerState<WizardJurnalScreen> {
  int _currentStep = 0; // 0 = Hasil Kunjungan (1/3), 1 = Order & Bukti (3/3)
  late final TextEditingController _catatanController;

  @override
  void initState() {
    super.initState();
    _catatanController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(jurnalFormProvider.notifier);
      await notifier.loadDraft(widget.noJo);
      final current = ref.read(jurnalFormProvider);
      if (current.catatan.isNotEmpty) {
        _catatanController.text = current.catatan;
      }
    });
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _simulasiPilihFoto(bool isNotaPo) {
    final notifier = ref.read(jurnalFormProvider.notifier);
    if (isNotaPo) {
      notifier.setFotoNotaPo('mock://foto_nota_po_${widget.noJo}.jpg');
    } else {
      notifier.setFotoDisplay('mock://foto_display_${widget.noJo}.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(jurnalFormProvider);
    final gpsState = ref.watch(kunjunganGpsProvider);
    final masterState = ref.watch(masterDataProvider);
    final config = ref.watch(appConfigProvider);

    final toko = masterState.tokoList.firstWhere(
      (t) => t.noJo == widget.noJo,
      orElse: () => masterState.tokoList.first,
    );

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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Progress bar 3 segmen tipis di bagian atas
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: AppColors.salesOrange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: _currentStep == 1
                        ? AppColors.salesOrange
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: _currentStep == 1
                        ? AppColors.salesOrange
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (formState.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.statusDitolakBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.statusDitolakText.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                formState.errorMessage!,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.statusDitolakText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          if (_currentStep == 0) ...[
            // STEP 1: HASIL KUNJUNGAN 1/3
            const Text(
              'HASIL KUNJUNGAN 1/3',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              toko.nama,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            _HasilRadioCard(
              label: 'Ada Order',
              selected: formState.hasil == HasilKunjungan.adaOrder,
              onTap: () => ref
                  .read(jurnalFormProvider.notifier)
                  .setHasil(HasilKunjungan.adaOrder),
            ),
            const SizedBox(height: 8),
            _HasilRadioCard(
              label: 'Tidak Ada Order',
              selected: formState.hasil == HasilKunjungan.tidakAdaOrder,
              onTap: () => ref
                  .read(jurnalFormProvider.notifier)
                  .setHasil(HasilKunjungan.tidakAdaOrder),
            ),
            const SizedBox(height: 8),
            _HasilRadioCard(
              label: 'Toko Tutup',
              selected: formState.hasil == HasilKunjungan.tokoTutup,
              onTap: () => ref
                  .read(jurnalFormProvider.notifier)
                  .setHasil(HasilKunjungan.tokoTutup),
            ),
            const SizedBox(height: 16),

            PrimaryButton(
              label: 'Lanjut',
              backgroundColor: AppColors.salesOrange,
              onPressed: () {
                setState(() => _currentStep = 1);
              },
            ),
          ] else ...[
            // STEP 2: ORDER & BUKTI 3/3
            const Text(
              'ORDER & BUKTI 3/3',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              toko.nama,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Badge hasil terpilih (bisa diketuk untuk ubah ke langkah 1)
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => setState(() => _currentStep = 0),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _hasilLabel(formState.hasil),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.manajerBlue,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Catatan jurnal
            const Text(
              'Catatan jurnal',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 5),
            TextFormField(
              controller: _catatanController,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Permintaan toko, kondisi stok, atau hal penting lain',
              ),
              onChanged: (text) {
                ref.read(jurnalFormProvider.notifier).setCatatan(text);
              },
            ),
            const SizedBox(height: 12),

            // 2 Kotak Upload berdampingan 50:50
            Row(
              children: [
                Expanded(
                  child: _UploadBox(
                    label: 'Foto display',
                    isUploaded: formState.fotoDisplay != null,
                    onTap: () => _simulasiPilihFoto(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _UploadBox(
                    label: 'Foto nota PO',
                    isUploaded: formState.fotoNotaPo != null,
                    isRequired: formState.hasil == HasilKunjungan.adaOrder,
                    onTap: () => _simulasiPilihFoto(true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tombol Simpan Jurnal Kunjungan
            PrimaryButton(
              label: 'Simpan Jurnal Kunjungan',
              backgroundColor: AppColors.salesOrange,
              isLoading: formState.isLoading,
              onPressed: () async {
                final ok =
                    await ref.read(jurnalFormProvider.notifier).simpanFinal(
                          noJo: widget.noJo,
                          lat: gpsState.currentLat,
                          lng: gpsState.currentLng,
                          jarakM: gpsState.jarakM,
                        );
                if (ok && context.mounted) {
                  ref
                      .read(mappingHariIniProvider.notifier)
                      .loadMappingHariIni();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jurnal kunjungan berhasil disimpan.'),
                      backgroundColor: AppColors.salesOrange,
                    ),
                  );
                  context.go('/sales/kunjungan');
                }
              },
            ),
            const SizedBox(height: 8),

            // Tombol Simpan Sebagai Draft
            PrimaryButton(
              label: 'Simpan Sebagai Draft',
              isSoftSecondary: true,
              onPressed: formState.isLoading
                  ? null
                  : () async {
                      final ok = await ref
                          .read(jurnalFormProvider.notifier)
                          .simpanDraft(
                            noJo: widget.noJo,
                            lat: gpsState.currentLat,
                            lng: gpsState.currentLng,
                            jarakM: gpsState.jarakM,
                          );
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Draft kunjungan berhasil disimpan di perangkat.',
                            ),
                          ),
                        );
                      }
                    },
            ),
          ],
        ],
      ),
    );
  }

  String _hasilLabel(HasilKunjungan hasil) {
    switch (hasil) {
      case HasilKunjungan.adaOrder:
        return 'Ada Order';
      case HasilKunjungan.tidakAdaOrder:
        return 'Tidak Ada Order';
      case HasilKunjungan.tokoTutup:
        return 'Toko Tutup';
    }
  }
}

class _HasilRadioCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HasilRadioCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFF7ED) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.salesOrange : AppColors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.salesOrange
                        : AppColors.borderStrong,
                    width: selected ? 4.5 : 1.4,
                  ),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String label;
  final bool isUploaded;
  final bool isRequired;
  final VoidCallback onTap;

  const _UploadBox({
    required this.label,
    required this.isUploaded,
    this.isRequired = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isUploaded ? AppColors.statusSudahBg : AppColors.softSlate,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 68,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isUploaded
                  ? AppColors.statusSudahText.withValues(alpha: 0.5)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUploaded) ...[
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.statusSudahText,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isUploaded
                        ? AppColors.statusSudahText
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
