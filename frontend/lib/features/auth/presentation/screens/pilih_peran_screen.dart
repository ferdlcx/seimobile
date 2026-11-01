import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';

/// Layar Pilih Peran: Menampilkan 3 kartu peran berwarna
/// (Admin Tagihan, Sales, Manajer Sales) sesuai desain ui-alur-bersama.png.
class PilihPeranScreen extends StatelessWidget {
  const PilihPeranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      roleLabel: 'Masuk',
      menuTitle: 'Pilih Peran',
      accentColor: AppColors.navyHeader,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masuk ke S.E.U.I Centre',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih peran Anda untuk melanjutkan.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Kartu 1: Admin Tagihan (Teal)
            _PeranCard(
              title: 'Admin Tagihan',
              subtitle: 'Akun, data master, mapping, dan laporan',
              color: AppColors.adminTeal,
              onTap: () => context.go('/login/admin_tagihan'),
            ),
            const SizedBox(height: 12),

            // Kartu 2: Sales (Oranye)
            _PeranCard(
              title: 'Sales',
              subtitle: 'Mapping, kunjungan, reschedule, kondite',
              color: AppColors.salesOrange,
              onTap: () => context.go('/login/sales'),
            ),
            const SizedBox(height: 12),

            // Kartu 3: Manajer Sales (Biru)
            _PeranCard(
              title: 'Manajer Sales',
              subtitle: 'Approval, penilaian, dan laporan tim',
              color: AppColors.manajerBlue,
              onTap: () => context.go('/login/manajer_sales'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeranCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PeranCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFFF1F5F9),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
