// ===================================================================
// FILE: security_settings_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// TASK GỐC (15-16/08/2026): "Dựng giao diện Cài đặt bảo mật"
// MÔ TẢ: Bật/tắt đăng nhập vân tay, cấu hình Auto Lock (dùng
// AuthLockService của Tăng Lê Duy Long), ẩn số thẻ trên dashboard,
// đăng xuất khỏi ứng dụng.
//
// CẬP NHẬT (theo phản hồi thực tế):
//   - Bỏ mục "Change Password" (app đăng nhập bằng OTP, không dùng mật khẩu).
//   - Auto Lock: tối đa 20 phút, mặc định 20 phút, và số phút chọn được lưu
//     persistent trong AuthLockService (không còn là State cục bộ của màn
//     hình này) nên rời màn hình rồi quay lại vẫn giữ đúng lựa chọn.
//   - Thêm mục "Log out" để đăng xuất khỏi ứng dụng, quay lại Login Screen.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_lock_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = true;
  bool _hideCardNumbers = true;

  static const List<int> _autoLockOptions = [1, 2, 5, 10, 15, 20];

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
          const SizedBox(height: 20),
          _sectionLabel('SESSION SECURITY'),
          _settingCard(
            icon: Icons.timer_outlined,
            title: 'Auto Lock',
            subtitle: 'Require authentication after ${authService.autoLockMinutes} minute'
                '${authService.autoLockMinutes > 1 ? 's' : ''} (tối đa 20 phút)',
            trailing: DropdownButton<int>(
              // Đọc trực tiếp từ AuthLockService (nguồn dữ liệu duy nhất) thay vì
              // State cục bộ của màn hình -> giá trị không bị mất khi quay lại.
              value: authService.autoLockMinutes,
              underline: const SizedBox(),
              items: _autoLockOptions
                  .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                authService.setAutoLockMinutes(v);
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
          const SizedBox(height: 20),
          _sectionLabel('ACCOUNT'),
          _settingCard(
            icon: Icons.logout,
            title: 'Log out',
            subtitle: 'Đăng xuất khỏi ứng dụng',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () => _confirmLogout(context),
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

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi ứng dụng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // Reset trạng thái khóa/đếm giờ, rồi đưa toàn bộ stack về LoginScreen.
    context.read<AuthLockService>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
