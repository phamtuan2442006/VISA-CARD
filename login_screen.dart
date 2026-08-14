// ===================================================================
// FILE: login_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// CẬP NHẬT: Đổi từ Email/Password sang Phone Number + OTP theo giao diện
// Figma mới nhất (13/08/2026). Vẫn giữ lựa chọn đăng nhập nhanh bằng vân tay.
// ===================================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool get _isPhoneValid => RegExp(r'^\d{9,10}$').hasMatch(_phoneController.text.trim());

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.nfc, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('NFC Card Reader',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              const SizedBox(height: 28),
              const Text('Welcome Back',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Sign in to access your cards',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Phone Number',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isPhoneValid ? _sendOtp : null,
                child: const Text('Login with OTP'),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 18),
              // Đăng nhập nhanh bằng vân tay (mock — không cần local_auth thật ở bản demo)
              GestureDetector(
                onTap: _mockBiometricLogin,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(Icons.fingerprint, color: AppColors.primaryBlue, size: 28),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _sendOtp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(phoneNumber: _phoneController.text.trim()),
      ),
    );
  }

  void _mockBiometricLogin() {
    // Mock: bỏ qua xác thực vân tay thật, demo trực tiếp vào Home.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}
