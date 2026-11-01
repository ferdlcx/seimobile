import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Item navigasi bawah per peran.
class RoleNavItem {
  final String label;
  final IconData icon;
  final String route;

  const RoleNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Scaffold standar S.E.U.I Centre dengan header navy `#0F1B3D`
/// (logo kecil "SEUI", judul "S.E.U.I CENTRE", subjudul "`<Peran> · <Menu>`", tombol "Keluar")
/// dan BottomNavigationBar 4 item sesuai peran.
class AppScaffold extends StatelessWidget {
  final String roleLabel;
  final String menuTitle;
  final Color accentColor;
  final List<RoleNavItem>? navItems;
  final int currentNavIndex;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onLogout;
  final Widget body;

  const AppScaffold({
    super.key,
    required this.roleLabel,
    required this.menuTitle,
    required this.accentColor,
    this.navItems,
    this.currentNavIndex = 0,
    this.onNavTap,
    this.onLogout,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: AppColors.navyHeader,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'SEUI',
                      style: TextStyle(
                        color: AppColors.navyHeader,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'S.E.U.I CENTRE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$roleLabel · $menuTitle',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onLogout != null)
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: onLogout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF334155)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: (navItems != null && navItems!.length >= 2)
          ? Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: currentNavIndex.clamp(0, navItems!.length - 1),
                onTap: onNavTap,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: accentColor,
                unselectedItemColor: AppColors.textSecondary,
                selectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                elevation: 0,
                items: navItems!
                    .map(
                      (item) => BottomNavigationBarItem(
                        icon: Icon(item.icon, size: 22),
                        label: item.label,
                      ),
                    )
                    .toList(),
              ),
            )
          : null,
    );
  }
}
