// ===================================================================
// FILE: reauth_screen.dart
// PHỤ TRÁCH: Tăng Lê Duy Long
// GHI CHÚ: Màn hình này chưa có task thiết kế UI riêng trong Sprint
// Backlog (chỉ có task lập trình logic khóa/mở khóa), nên được dựng kèm
// theo cùng auth_lock_service.dart, bám sát mockup Figma "12 Re-authentication".
// Đã bỏ lựa chọn "Use Password" vì app đăng nhập bằng OTP, không có
// mật khẩu — chỉ còn xác thực lại bằng vân tay.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_lock_service.dart';
import '../theme/app_theme.dart';

class ReauthScreen extends StatefulWidget {
  const ReauthScreen({super.key});

  @override
  State<ReauthScreen> createState() => _ReauthScreenState();
}

class _ReauthScreenState extends State<ReauthScreen> {
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthLockService>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fingerprint, size: 44, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 20),
              const Text('Verify your identity',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Use your biometrics to continue accessing Smart NFC features.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Your session was locked for security.',
                  style: TextStyle(fontSize: 12, color: AppColors.primaryBlue),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isVerifying ? null : () => _verifyBiometrics(authService),
                child: Text(_isVerifying ? 'Đang xác thực...' : 'Use Biometrics'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyBiometrics(AuthLockService authService) async {
    setState(() => _isVerifying = true);
    await authService.reauthenticateWithBiometrics();
    if (mounted) Navigator.of(context).pop();
  }
}
