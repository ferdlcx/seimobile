import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pill_filter_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/akun_provider.dart';

/// Layar Tambah Akun Baru oleh Admin Tagihan.
class TambahAkunScreen extends ConsumerStatefulWidget {
  const TambahAkunScreen({super.key});

  @override
  ConsumerState<TambahAkunScreen> createState() => _TambahAkunScreenState();
}

class _TambahAkunScreenState extends ConsumerState<TambahAkunScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'sales'; // 'sales' | 'manajer_sales'
  bool _aktif = true;

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(akunProvider.notifier).tambahAkun(
          nama: _namaController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
          aktif: _aktif,
        );

    if (ok && mounted) {
      context.go('/admin/akun');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(akunProvider);

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

    return AppScaffold(
      roleLabel: 'Admin Tagihan',
      menuTitle: 'Akun',
      accentColor: AppColors.adminTeal,
      navItems: navItems,
      currentNavIndex: 0,
      onNavTap: (idx) => context.go(navItems[idx].route),
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go('/pilih-peran');
        }
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol Kembali
              InkWell(
                onTap: () => context.go('/admin/akun'),
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 18,
                        color: AppColors.adminTeal,
                      ),
                      Text(
                        'Daftar akun',
                        style: TextStyle(
                          color: AppColors.adminTeal,
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
                'Tambah Akun Baru',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              if (state.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.statusDitolakBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.statusDitolakText.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.statusDitolakText,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Nama lengkap
              const Text(
                'Nama lengkap',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _namaController,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'contoh: Rudi Hartono',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama lengkap wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Username
              const Text(
                'Username',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'contoh: rudi.hartono',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Username wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Password
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'minimal 6 karakter',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  if (val.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Peran (Pill chips)
              const Text(
                'Peran',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  PillChip(
                    label: 'Sales',
                    selected: _selectedRole == 'sales',
                    activeColor: AppColors.adminTeal,
                    onTap: () => setState(() => _selectedRole = 'sales'),
                  ),
                  PillChip(
                    label: 'Manajer Sales',
                    selected: _selectedRole == 'manajer_sales',
                    activeColor: AppColors.adminTeal,
                    onTap: () => setState(() => _selectedRole = 'manajer_sales'),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Status akun aktif di dalam card putih
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status akun aktif',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: _aktif,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.adminTeal,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColors.border,
                        trackOutlineColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onChanged: (val) => setState(() => _aktif = val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tombol Batal & Simpan
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Batal',
                      isSoftSecondary: true,
                      onPressed: () => context.go('/admin/akun'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Simpan Akun',
                      backgroundColor: AppColors.adminTeal,
                      isLoading: state.isLoading,
                      onPressed: _handleSimpan,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
