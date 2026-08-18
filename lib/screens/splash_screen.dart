// ===================================================================
// FILE: splash_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// MÔ TẢ: Màn hình mở đầu (Splash Screen) theo đúng thứ tự trong Figma:
// Splash -> Login. Hiện logo + tên app trong 2 giây rồi tự chuyển sang
// màn Login (trước đây app mở thẳng vào Login, bỏ qua bước này).
// ===================================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryBlue, AppColors.darkNavy],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.nfc, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 28),
              const Text(
                'Smart NFC\nCard Reader',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Secure • Fast • Contactless',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
              ),
              const Spacer(flex: 4),
              const Text('V1.0.4',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 10),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white70),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
