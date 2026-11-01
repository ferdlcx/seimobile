import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../providers/reschedule_provider.dart';

class FormRescheduleScreen extends ConsumerStatefulWidget {
  final String? initialNoJo;

  const FormRescheduleScreen({
    super.key,
    this.initialNoJo,
  });

  @override
  ConsumerState<FormRescheduleScreen> createState() =>
      _FormRescheduleScreenState();
}

class _FormRescheduleScreenState extends ConsumerState<FormRescheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedNoJo;
  DateTime _jadwalBaru = DateTime.now().add(const Duration(days: 3));
  final _alasanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedNoJo = widget.initialNoJo;
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _jadwalBaru,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: 'PILIH JADWAL PENGGANTI',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
    );
    if (picked != null) {
      setState(() => _jadwalBaru = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final masterState = ref.watch(masterDataProvider);
    final rescheduleState = ref.watch(rescheduleProvider);

    final tokoList = masterState.tokoList;
    if (_selectedNoJo == null && tokoList.isNotEmpty) {
      _selectedNoJo = tokoList.first.noJo;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        foregroundColor: Colors.white,
        title: const Text(
          'Buat Pengajuan Reschedule',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (rescheduleState.errorMessage != null)
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
                        rescheduleState.errorMessage!,
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
                  const Text(
                    'Pilih Toko',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedNoJo,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: tokoList.map((t) {
                      return DropdownMenuItem<String>(
                        value: t.noJo,
                        child: Text(
                          '${t.nama} (${t.noJo})',
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedNoJo = val);
                      }
                    },
                    validator: (val) =>
                        val == null ? 'Silakan pilih toko' : null,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Jadwal Pengganti',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _pilihTanggal(context),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppFormat.formatTanggalHari(_jadwalBaru),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: AppColors.salesOrange,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Alasan Reschedule',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _alasanController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText:
                          'Contoh: Toko sedang renovasi hingga akhir pekan...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Alasan wajib diisi';
                      }
                      if (val.trim().length < 5) {
                        return 'Alasan minimal 5 karakter';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Ajukan Reschedule',
              backgroundColor: AppColors.salesOrange,
              isLoading: rescheduleState.isSubmitting,
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final ok = await ref
                      .read(rescheduleProvider.notifier)
                      .ajukanReschedule(
                        noJo: _selectedNoJo!,
                        jadwalBaru: _jadwalBaru,
                        alasan: _alasanController.text.trim(),
                      );

                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pengajuan reschedule berhasil dikirim ke Manajer.',
                        ),
                        backgroundColor: AppColors.salesOrange,
                      ),
                    );
                    context.pop();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
