import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

/// Layar Validasi / Login Berhasil
/// Menampilkan konfirmasi pencocokan peran dan tombol langsung menuju menu utama sesuai peran.
class LoginBerhasilScreen extends ConsumerWidget {
  const LoginBerhasilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.session?.user;
    final role = user?.role ?? 'sales';
    final mode = auth.activeMode ?? 'sales';

    String roleLabel = 'Sales';
    String destinationRoute = '/sales/mapping';
    String destinationButtonLabel = 'Langsung masuk ke Menu Mapping';
    Color accentColor = AppColors.salesOrange;

    if (role == 'admin_tagihan') {
      roleLabel = 'Admin Tagihan';
      destinationRoute = '/admin/akun';
      destinationButtonLabel = 'Langsung masuk ke Menu Akun';
      accentColor = AppColors.adminTeal;
    } else if (role == 'manajer_sales') {
      roleLabel = 'Manajer Sales';
      if (mode == 'sales') {
        destinationRoute = '/sales/mapping';
        destinationButtonLabel = 'Langsung masuk ke Menu Mapping (Mode Sales)';
        accentColor = AppColors.salesOrange;
      } else {
        destinationRoute = '/manajer/beranda';
        destinationButtonLabel = 'Langsung masuk ke Beranda';
        accentColor = AppColors.manajerBlue;
      }
    }

    return AppScaffold(
      roleLabel: roleLabel,
      menuTitle: 'Validasi Akses',
      accentColor: accentColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lingkaran Centang Hijau
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.statusSudahBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 40,
                  color: AppColors.statusSudahText,
                ),
              ),
              const SizedBox(height: 20),

              // Judul & Deskripsi
              const Text(
                'Login berhasil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sistem mencocokkan akun dengan peran $roleLabel. Hak akses dibuka sesuai peran.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Tombol Langsung Masuk
              PrimaryButton(
                label: destinationButtonLabel,
                backgroundColor: accentColor,
                onPressed: () {
                  context.go(destinationRoute);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
