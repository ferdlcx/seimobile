import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

/// Layar Login untuk masing-masing peran (Admin Tagihan, Sales, Manajer Sales).
/// Menampilkan form username, password, opsi mode masuk (khusus Manajer),
/// dan validasi pesan error merah jika kredensial tidak sesuai.
class LoginScreen extends ConsumerStatefulWidget {
  final String role; // 'admin_tagihan' | 'sales' | 'manajer_sales'

  const LoginScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  String _selectedMode = 'manajer'; // Khusus manajer_sales: 'manajer' | 'sales'

  @override
  void initState() {
    super.initState();
    // Default pre-fill akun demo sesuai peran
    String defaultUser = 'budi.santoso';
    if (widget.role == 'admin_tagihan') {
      defaultUser = 'andi.tagihan';
    } else if (widget.role == 'manajer_sales') {
      defaultUser = 'maya.kusuma';
    }

    _usernameController = TextEditingController(text: defaultUser);
    _passwordController = TextEditingController(text: 'password123');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _roleLabel {
    switch (widget.role) {
      case 'admin_tagihan':
        return 'Admin Tagihan';
      case 'manajer_sales':
        return 'Manajer Sales';
      case 'sales':
      default:
        return 'Sales';
    }
  }

  Color get _accentColor {
    switch (widget.role) {
      case 'admin_tagihan':
        return AppColors.adminTeal;
      case 'manajer_sales':
        return AppColors.manajerBlue;
      case 'sales':
      default:
        return AppColors.salesOrange;
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final mode = widget.role == 'manajer_sales' ? _selectedMode : null;

    final success = await ref.read(authProvider.notifier).login(
          username: username,
          password: password,
          role: widget.role,
          mode: mode,
        );

    if (success && mounted) {
      context.go('/login-berhasil');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return AppScaffold(
      roleLabel: _roleLabel,
      menuTitle: 'Masuk',
      accentColor: _accentColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol "‹ Ganti peran"
              InkWell(
                onTap: () => context.go('/pilih-peran'),
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
                        'Ganti peran',
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

              // Judul & Teks Penjelas
              Text(
                'Masuk sebagai $_roleLabel',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Akun contoh sudah terisi. Salah isi akan menampilkan pesan merah dan tetap di halaman login.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Kotak pesan error jika autentikasi gagal
              if (auth.errorMessage != null && auth.errorMessage!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusDitolakBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.statusDitolakText.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: AppColors.statusDitolakText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          auth.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.statusDitolakText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Field Username
              const Text(
                'Username',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan username',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Field Password
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Masukkan password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pilihan Mode Masuk (khusus Manajer Sales)
              if (widget.role == 'manajer_sales') ...[
                const Text(
                  'Mode masuk (akun rangkap Sales)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ModeOptionButton(
                        label: 'Manajer',
                        isSelected: _selectedMode == 'manajer',
                        activeColor: AppColors.manajerBlue,
                        onTap: () {
                          setState(() {
                            _selectedMode = 'manajer';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeOptionButton(
                        label: 'Sales',
                        isSelected: _selectedMode == 'sales',
                        activeColor: AppColors.salesOrange,
                        onTap: () {
                          setState(() {
                            _selectedMode = 'sales';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Tombol Masuk
              PrimaryButton(
                label: 'Masuk',
                backgroundColor: _accentColor,
                isLoading: auth.isLoading,
                onPressed: _handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeOptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _ModeOptionButton({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
