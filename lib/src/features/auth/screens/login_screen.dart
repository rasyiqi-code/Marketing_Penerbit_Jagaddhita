import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/auth/widgets/login_form.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/auth/widgets/login_screen_background.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/auth/widgets/reset_password_dialog.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService
          .signIn(_emailController.text.trim(), _passwordController.text)
          .timeout(const Duration(seconds: 15));
      // Navigation is handled by AuthWrapper or main stream listener
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'configuration-not-found' || e.code == '400') {
        _showWebConfigErrorDialog(e.message ?? 'Unknown configuration error');
      } else {
        // Normalize kode error (Firebase web kadang pakai format berbeda)
        final code = e.code.toLowerCase().replaceAll('auth/', '');
        final msg = (e.message ?? '').toLowerCase();

        String message;
        if (code == 'invalid-credential' ||
            code == 'wrong-password' ||
            code == 'invalid-login-credentials' ||
            code == 'invalid_login_credentials' ||
            msg.contains('incorrect') ||
            msg.contains('malformed') ||
            msg.contains('expired') ||
            msg.contains('invalid credential')) {
          message =
              'Email atau kata sandi salah. Jika akun Anda didaftarkan menggunakan Google, silakan gunakan tombol "Masuk dengan Google" di bawah.';
        } else if (code == 'user-not-found' || msg.contains('no user record')) {
          message =
              'Email belum terdaftar. Silakan hubungi admin atau gunakan tombol "Masuk dengan Google" jika akun Anda didaftarkan via Google.';
        } else if (code == 'user-disabled') {
          message = 'Akun ini telah dinonaktifkan oleh administrator.';
        } else if (code == 'too-many-requests' || msg.contains('too many')) {
          message =
              'Terlalu banyak percobaan masuk yang gagal. Silakan coba lagi beberapa saat lagi.';
        } else if (code == 'invalid-email' || msg.contains('invalid email')) {
          message = 'Format alamat email tidak valid.';
        } else if (code == 'network-request-failed' ||
            msg.contains('network')) {
          message =
              'Koneksi internet bermasalah. Silakan periksa jaringan Anda dan coba lagi.';
        } else {
          // Fallback: tetap tampilkan pesan ramah, tapi sertakan kode untuk debugging
          message =
              'Gagal masuk (${e.code}). Pastikan email dan kata sandi benar, atau gunakan "Masuk dengan Google".';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: AppTheme.secondaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kesalahan: ${e.toString()}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppTheme.secondaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithGoogle();
      // Navigation handled by auth wrapper
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString();
      if (errorMessage.contains('Google Sign-In failed:')) {
        errorMessage = errorMessage.replaceAll('Exception: Google Sign-In failed:', '').trim();
      }

      String displayMessage = 'Gagal masuk dengan Google: $errorMessage';
      if (errorMessage.contains('sign_in_canceled') || errorMessage.contains('canceled')) {
        displayMessage = 'Masuk dengan Google dibatalkan.';
      } else if (errorMessage.contains('network_error')) {
        displayMessage = 'Koneksi internet bermasalah. Silakan periksa koneksi Anda.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            displayMessage,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppTheme.secondaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showWebConfigErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('Web Configuration Error', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This error usually happens when "Email Enumeration Protection" is enabled in Firebase Console but not fully configured for Web.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please go to Firebase Console > Authentication > Settings and UNCHECK "Email Enumeration Protection".',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              'Error Details:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SelectableText(message, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        body: Stack(
        children: [
          // 1. Latar belakang dekoratif
          const LoginScreenBackground(),


          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo di atas — background putih
                        Image.asset(
                          'assets/logo.png',
                          height: 90,
                        ),
                        const SizedBox(height: 12),
  
                        // Banner hijau melengkung bawah — subtitle di dalamnya
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                          decoration: const BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(36),
                              bottomRight: Radius.circular(36),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Portal Penjualan Internal',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
  
  
                        // Glass Window Card Form
                        LoginForm(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          isLoading: _isLoading,
                          obscurePassword: _obscurePassword,
                          onToggleObscure: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          onLogin: _handleLogin,
                          onGoogleLogin: _handleGoogleLogin,
                          onForgotPassword: () {
                            if (_emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter email to reset password',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            showResetPasswordDialog(context, _emailController.text);
                          },
                        ),
  
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Belum punya akun?",
                              style: TextStyle(
                                color: AppTheme.lightTextSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text(
                                'Daftar',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
