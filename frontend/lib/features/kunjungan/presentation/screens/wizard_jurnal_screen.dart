import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../../../mapping/presentation/providers/mapping_hari_ini_provider.dart';
import '../../data/models/jurnal_kunjungan_model.dart';
import '../providers/kunjungan_provider.dart';

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

  void _hapusFoto(bool isNotaPo) {
    final notifier = ref.read(jurnalFormProvider.notifier);
    if (isNotaPo) {
      notifier.setFotoNotaPo(null);
    } else {
      notifier.setFotoDisplay(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(jurnalFormProvider);
    final gpsState = ref.watch(kunjunganGpsProvider);
    final masterState = ref.watch(masterDataProvider);

    final toko = masterState.tokoList.firstWhere(
      (t) => t.noJo == widget.noJo,
      orElse: () => masterState.tokoList.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jurnal Kunjungan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              '${toko.nama} (${widget.noJo})',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (formState.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.statusDitolakBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.statusDitolakText),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.statusDitolakText,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      formState.errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.statusDitolakText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Langkah 1: Hasil Kunjungan
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.salesOrange,
                        child: Text(
                          '1',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'HASIL KUNJUNGAN',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RadioGroup<HasilKunjungan>(
                    groupValue: formState.hasil,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(jurnalFormProvider.notifier).setHasil(val);
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<HasilKunjungan>(
                          title: const Text(
                            'Ada Order',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Toko melakukan pemesanan suku cadang (wajib foto nota PO)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          activeColor: AppColors.salesOrange,
                          value: HasilKunjungan.adaOrder,
                        ),
                        RadioListTile<HasilKunjungan>(
                          title: const Text(
                            'Tidak Ada Order',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Toko buka namun belum melakukan pemesanan',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          activeColor: AppColors.salesOrange,
                          value: HasilKunjungan.tidakAdaOrder,
                        ),
                        RadioListTile<HasilKunjungan>(
                          title: const Text(
                            'Toko Tutup',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Toko tutup saat sales berkunjung',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          activeColor: AppColors.salesOrange,
                          value: HasilKunjungan.tokoTutup,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Langkah 2: Catatan Kunjungan
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
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.salesOrange,
                      child: Text(
                        '2',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'CATATAN AKTIVITAS TOKO',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _catatanController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan catatan aktivitas kunjungan...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    ref.read(jurnalFormProvider.notifier).setCatatan(text);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Langkah 3: Foto Display & Nota PO
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
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.salesOrange,
                      child: Text(
                        '3',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'BUKTI FOTO KUNJUNGAN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Foto Display Toko
                const Text(
                  'Foto Display Toko (Opsional)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                if (formState.fotoDisplay != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.statusSudahBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.statusSudahText),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.image,
                          color: AppColors.statusSudahText,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Foto display terlampir',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.statusSudahText,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _hapusFoto(false),
                        ),
                      ],
                    ),
                  )
                else
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text(
                      'Ambil / Unggah Foto Display',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _simulasiPilihFoto(false),
                  ),

                const SizedBox(height: 14),

                // Foto Nota PO
                Row(
                  children: [
                    const Text(
                      'Foto Nota / Purchase Order (PO)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (formState.hasil == HasilKunjungan.adaOrder)
                      const Text(
                        ' *Wajib',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (formState.fotoNotaPo != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.statusSudahBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.statusSudahText),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: AppColors.statusSudahText,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Foto nota PO terlampir',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.statusSudahText,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _hapusFoto(true),
                        ),
                      ],
                    ),
                  )
                else
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      side: BorderSide(
                        color: formState.hasil == HasilKunjungan.adaOrder
                            ? AppColors.salesOrange
                            : AppColors.border,
                      ),
                    ),
                    icon: const Icon(Icons.receipt_outlined, size: 18),
                    label: Text(
                      formState.hasil == HasilKunjungan.adaOrder
                          ? 'Wajib: Ambil / Unggah Foto Nota PO'
                          : 'Ambil / Unggah Foto Nota PO',
                      style: TextStyle(
                        fontSize: 12,
                        color: formState.hasil == HasilKunjungan.adaOrder
                            ? AppColors.salesOrange
                            : AppColors.textPrimary,
                        fontWeight: formState.hasil == HasilKunjungan.adaOrder
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                    onPressed: () => _simulasiPilihFoto(true),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Simpan Final
          PrimaryButton(
            label: 'Simpan Jurnal Kunjungan',
            backgroundColor: AppColors.salesOrange,
            isLoading: formState.isLoading,
            onPressed: () async {
              final ok = await ref.read(jurnalFormProvider.notifier).simpanFinal(
                    noJo: widget.noJo,
                    lat: gpsState.currentLat,
                    lng: gpsState.currentLng,
                    jarakM: gpsState.jarakM,
                  );
              if (ok && context.mounted) {
                // Refresh data mapping sales
                ref.read(mappingHariIniProvider.notifier).loadMappingHariIni();
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
          const SizedBox(height: 10),

          // Tombol Simpan Draft
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.salesOrange),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: formState.isLoading
                ? null
                : () async {
                    final ok =
                        await ref.read(jurnalFormProvider.notifier).simpanDraft(
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
            child: const Text(
              'Simpan Sebagai Draft',
              style: TextStyle(
                color: AppColors.salesOrange,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
