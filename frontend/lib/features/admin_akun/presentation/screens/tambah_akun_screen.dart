import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/akun_provider.dart';

/// Layar Tambah Akun Baru oleh Admin Tagihan.
class TambahAkunScreen extends ConsumerStatefulWidget {
  const TambahAkunScreen({super.key});

  @override
  ConsumerState<TambahAkunScreen> createState() => _TambahAkunScreenState();
}

class _TambahAkunScreenState extends ConsumerState<TambahAkunScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController(text: 'Rudi Hartono');
  final _usernameController = TextEditingController(text: 'rudi.hartono');
  final _passwordController = TextEditingController(text: 'password123');
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

    return AppScaffold(
      roleLabel: 'Admin Tagihan',
      menuTitle: 'Tambah Akun',
      accentColor: AppColors.adminTeal,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        size: 20,
                        color: Color(0xFF2563EB),
                      ),
                      Text(
                        'Daftar akun',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Tambah Akun Baru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

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
                const SizedBox(height: 16),
              ],

              // Nama lengkap
              const Text(
                'Nama lengkap',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaController,
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
              const SizedBox(height: 14),

              // Username
              const Text(
                'Username',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _usernameController,
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
              const SizedBox(height: 14),

              // Password
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
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
              const SizedBox(height: 16),

              // Peran
              const Text(
                'Peran',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Sales'),
                    selected: _selectedRole == 'sales',
                    selectedColor: AppColors.adminTeal,
                    labelStyle: TextStyle(
                      color: _selectedRole == 'sales'
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedRole = 'sales');
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Manajer Sales'),
                    selected: _selectedRole == 'manajer_sales',
                    selectedColor: AppColors.adminTeal,
                    labelStyle: TextStyle(
                      color: _selectedRole == 'manajer_sales'
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedRole = 'manajer_sales');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status akun aktif
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status akun aktif',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Switch(
                    value: _aktif,
                    activeTrackColor: AppColors.adminTeal,
                    onChanged: (val) => setState(() => _aktif = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Batal & Simpan
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Batal',
                      isOutlined: true,
                      backgroundColor: AppColors.adminTeal,
                      onPressed: () => context.go('/admin/akun'),
                    ),
                  ),
                  const SizedBox(width: 12),
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
