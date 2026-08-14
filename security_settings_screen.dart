// ===================================================================
// FILE: security_settings_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// TASK GỐC (15-16/08/2026): "Dựng giao diện Cài đặt bảo mật"
// MÔ TẢ: Bật/tắt đăng nhập vân tay, đổi mật khẩu (điều hướng), cấu hình
// Auto Lock (dùng AuthLockService của Tăng Lê Duy Long), ẩn số thẻ trên
// dashboard. Theo ràng buộc Product Backlog #14: phải xác thực lại trước
// khi cho phép đổi bất kỳ cài đặt bảo mật nào — nút "Change Password" ở
// đây sẽ yêu cầu xác thực lại (ReauthScreen) trước khi cho vào.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_lock_service.dart';
import '../theme/app_theme.dart';
import 'reauth_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = true;
  bool _hideCardNumbers = true;
  int _autoLockMinutes = 1;

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthLockService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('AUTHENTICATION'),
          _settingCard(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Use fingerprint or face to sign in',
            trailing: Switch(
              value: _biometricEnabled,
              activeColor: AppColors.primaryBlue,
              onChanged: (v) => setState(() => _biometricEnabled = v),
            ),
          ),
          _settingCard(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Last changed 3 months ago',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () => _requireReauth(context, action: 'đổi mật khẩu'),
          ),
          const SizedBox(height: 20),
          _sectionLabel('SESSION SECURITY'),
          _settingCard(
            icon: Icons.timer_outlined,
            title: 'Auto Lock',
            subtitle: 'Require authentication after $_autoLockMinutes minute',
            trailing: DropdownButton<int>(
              value: _autoLockMinutes,
              underline: const SizedBox(),
              items: const [1, 2, 5]
                  .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _autoLockMinutes = v);
                authService.autoLockDuration = Duration(minutes: v);
              },
            ),
          ),
          _settingCard(
            icon: Icons.lock_clock,
            title: 'Lock App Now',
            subtitle: 'Khóa ứng dụng ngay lập tức, yêu cầu xác thực lại',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () => authService.lock(),
          ),
          const SizedBox(height: 20),
          _sectionLabel('PRIVACY'),
          _settingCard(
            icon: Icons.visibility_off_outlined,
            title: 'Hide Card Numbers',
            subtitle: 'Mask card details on dashboard',
            trailing: Switch(
              value: _hideCardNumbers,
              activeColor: AppColors.primaryBlue,
              onChanged: (v) => setState(() => _hideCardNumbers = v),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Your saved card data is encrypted and stored securely on this device.',
              style: TextStyle(fontSize: 12, color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
    );
  }

  Widget _settingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: trailing,
      ),
    );
  }

  /// Yêu cầu xác thực lại trước khi cho phép thao tác nhạy cảm
  /// (đúng ràng buộc Product Backlog #14).
  Future<void> _requireReauth(BuildContext context, {required String action}) async {
    context.read<AuthLockService>().lock();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReauthScreen()),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xác thực — có thể tiếp tục $action')),
      );
    }
  }
}
