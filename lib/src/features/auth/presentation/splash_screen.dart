import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_app/src/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnSession();
  }

  void _navigateBasedOnSession() async {
    // Check backend connection
    final dioClient = DioClient();
    final isConnected = await dioClient.checkConnection();

    if (mounted) {
      if (isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Backend Connected Successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '❌ Backend Connection Failed. Check if server is running.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if user is already logged in
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final role = prefs.getString('role');

    if (token != null && token.isNotEmpty && role != null && role.isNotEmpty) {
      // User has a saved session, route to their dashboard
      _navigateByRole(role);
    } else {
      context.go('/login');
    }
  }

  void _navigateByRole(String rawRole) {
    // Normalize role alias
    final role = _normalizeRole(rawRole);
    switch (role) {
      case 'admin':
        context.go('/dashboard');
        break;
      case 'field_officer':
        context.go('/user-dashboard');
        break;
      case 'estate_manager':
        context.go('/manager/estate');
        break;
      case 'mill_manager':
        context.go('/manager/mill');
        break;
      case 'finance_manager':
        context.go('/manager/finance');
        break;
      case 'sales_officer':
        context.go('/manager/sales');
        break;
      default:
        context.go('/login');
    }
  }

  String _normalizeRole(String role) {
    switch (role.toLowerCase().trim()) {
      case 'sales':
      case 'sales_officer':
        return 'sales_officer';
      case 'finance':
      case 'finance_manager':
        return 'finance_manager';
      case 'estate':
      case 'estate_manager':
        return 'estate_manager';
      case 'mill':
      case 'mill_manager':
        return 'mill_manager';
      case 'field':
      case 'field_officer':
        return 'field_officer';
      case 'admin':
        return 'admin';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.spa_rounded,
              color: Colors.white,
              size: 80,
            ).animate().scale(duration: 600.ms).then().shimmer(),
            const SizedBox(height: 24),
            const Text(
              'NEX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const Text(
              'IROSTECH',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
