import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

/// Root widget aplikasi S.E.U.I Centre.
class SeuiCentreApp extends ConsumerWidget {
  const SeuiCentreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final auth = ref.watch(authProvider);
    final accentColor = AppColors.accentForRole(
      auth.role,
      mode: auth.activeMode,
    );

    return MaterialApp.router(
      title: 'S.E.U.I Centre',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(primaryColor: accentColor),
      routerConfig: router,
    );
  }
}
