import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_app/src/core/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dioClient = DioClient();
      final response = await dioClient.dio.post(
        '/api/v1/auth/login',
        data: {
          'username': _emailController.text.trim(),
          'password': _passwordController.text,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final data = response.data;
          final rawRole = data['role'] as String;
          final token = data['access_token'];

          // Normalize role — backend may return short names
          final role = _normalizeRole(rawRole);

          print('Login Success: raw=$rawRole, normalized=$role, Token: $token');
          // Save token using shared_preferences for persistence
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          await prefs.setString('role', role);

          // Navigate based on role
          if (role == 'admin') {
            context.go('/dashboard');
          } else if (role == 'field_officer') {
            context.go('/user-dashboard');
          } else if (role == 'estate_manager') {
            context.go('/manager/estate');
          } else if (role == 'mill_manager') {
            context.go('/manager/mill');
          } else if (role == 'finance_manager') {
            context.go('/manager/finance');
          } else if (role == 'sales_officer') {
            context.go('/manager/sales');
          } else {
            // Default fallback
            context.go('/dashboard');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${data['role']}!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Login failed. Please check your connection.';
        if (e is DioException) {
          if (e.response?.statusCode == 400) {
            errorMessage = 'Invalid email or password.';
          } else if (e.response != null) {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Normalize role string from backend to match app routing expectations.
  /// Backend may return short names like 'sales' or 'finance' instead of
  /// 'sales_officer' or 'finance_manager'.
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
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left Side - Hero Image / Branding (Visible on large screens)
          if (MediaQuery.of(context).size.width > 900)
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1542601906990-24d4c16419d9?q=80&w=1974&auto=format&fit=crop',
                    ), // Placeholder for Plantation image
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Color(0x991B4B8C),
                      BlendMode.multiply,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.spa_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'IROSTECH',
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Integrated ERP Solution for CPO Supply Chain.\nDigitize, Automate, and Analyze.',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.white70, height: 1.5),
                      ),
                    ].animate().fadeIn().moveY(begin: 20, end: 0),
                  ),
                ),
              ),
            ),

          // Right Side - Login Form
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mobile Logo
                    if (MediaQuery.of(context).size.width <= 900)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.spa_rounded,
                              color: AppTheme.primary,
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'NEX',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),

                    Text(
                      'Welcome Back',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access your dashboard',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 48),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Employee ID or Email',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: Icon(Icons.visibility_off_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ].animate(interval: 100.ms).fadeIn().moveY(begin: 20, end: 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
