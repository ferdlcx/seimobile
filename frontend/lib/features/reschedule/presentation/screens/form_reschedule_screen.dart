import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/reschedule_provider.dart';

/// Layar Pengajuan Reschedule Baru oleh Sales.
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
  DateTime _jadwalBaru = DateTime(2026, 11, 3); // Sel, 03 Nov 2026
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
      firstDate: DateTime(2026, 10, 30),
      lastDate: DateTime(2027, 12, 31),
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
    final config = ref.watch(appConfigProvider);

    final tokoList = masterState.tokoList;
    if (_selectedNoJo == null && tokoList.isNotEmpty) {
      final hasBintangTerang = tokoList.any((t) => t.noJo == 'JO-0501');
      _selectedNoJo = hasBintangTerang ? 'JO-0501' : tokoList.first.noJo;
    }

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
      menuTitle: 'Reschedule',
      accentColor: AppColors.salesOrange,
      navItems: navItems,
      currentNavIndex: 2,
      onNavTap: (idx) => context.go(navItems[idx].route),
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go('/pilih-peran');
        }
      },
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // Back link "< Reschedule"
            InkWell(
              onTap: () => context.go('/sales/reschedule'),
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
                      'Reschedule',
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

            const Text(
              'Pengajuan Reschedule Baru',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            if (rescheduleState.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.statusDitolakBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.statusDitolakText.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  rescheduleState.errorMessage!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.statusDitolakText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Toko
            const Text(
              'Toko',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              initialValue: _selectedNoJo,
              isExpanded: true,
              icon: const SizedBox.shrink(),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              items: tokoList.map((t) {
                return DropdownMenuItem<String>(
                  value: t.noJo,
                  child: Text(
                    t.nama,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedNoJo = val);
                }
              },
              validator: (val) => val == null ? 'Silakan pilih toko' : null,
            ),
            const SizedBox(height: 12),

            // Jadwal pengganti
            const Text(
              'Jadwal pengganti',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 5),
            InkWell(
              onTap: () => _pilihTanggal(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.borderStrong),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppFormat.formatTanggalHariSingkat(_jadwalBaru),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Alasan
            const Text(
              'Alasan',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 5),
            TextFormField(
              controller: _alasanController,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Jelaskan kenapa jadwal perlu diganti',
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
            const SizedBox(height: 16),

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
                    context.go('/sales/reschedule');
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
