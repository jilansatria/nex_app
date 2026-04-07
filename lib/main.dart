import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_app/src/features/auth/presentation/login_screen.dart';
import 'package:nex_app/src/features/auth/presentation/splash_screen.dart';
import 'package:nex_app/src/features/dashboard/presentation/admin/admin_dashboard_screen.dart';
import 'package:nex_app/src/features/dashboard/presentation/user/user_dashboard_screen.dart';
import 'package:nex_app/src/features/dashboard/presentation/manager/manager_dashboard_screen.dart';
import 'package:nex_app/src/core/theme/app_theme.dart';
import 'package:nex_app/src/features/dashboard/data/services/local_storage_service.dart';
import 'package:nex_app/src/features/dashboard/data/services/network_service.dart';

import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:nex_app/src/features/dashboard/data/services/offline_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage
  await LocalStorageService.init();

  // Initialize Network Service
  final networkService = NetworkService();
  await networkService.initialize();

  // Initialize Offline Sync Service with a repository
  final repository = DashboardRepositoryImpl(DioClient());
  OfflineSyncService().initialize(repository);

  runApp(const NexApp());
}

class NexApp extends StatelessWidget {
  const NexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Irostech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/user-dashboard',
      builder: (context, state) => const UserDashboardScreen(),
    ),
    GoRoute(
      path: '/manager/estate',
      builder: (context, state) =>
          const ManagerDashboardScreen(role: 'estate_manager'),
    ),
    GoRoute(
      path: '/manager/mill',
      builder: (context, state) =>
          const ManagerDashboardScreen(role: 'mill_manager'),
    ),
    GoRoute(
      path: '/manager/finance',
      builder: (context, state) =>
          const ManagerDashboardScreen(role: 'finance_manager'),
    ),
    GoRoute(
      path: '/manager/sales',
      builder: (context, state) =>
          const ManagerDashboardScreen(role: 'sales_officer'),
    ),
  ],
);
