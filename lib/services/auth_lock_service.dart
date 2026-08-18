// ===================================================================
// FILE: auth_lock_service.dart
// PHỤ TRÁCH: Tăng Lê Duy Long
// TASK GỐC (16/08/2026):
//   "Lập trình đăng xuất / khóa ứng dụng thủ công + yêu cầu xác thực lại
//    khi mở lại"
//
// MÔ TẢ:
//   Quản lý trạng thái khóa (locked) của app. Khi người dùng chủ động khóa
//   (hoặc auto-lock sau thời gian không hoạt động — cấu hình được ở màn
//   Security Settings, tối đa 20 phút, mặc định 20 phút), toàn bộ nội dung
//   thẻ phải được ẩn cho tới khi xác thực lại (vân tay) — đúng ràng buộc
//   Product Backlog #12.
//
// CẬP NHẬT (theo phản hồi thực tế):
//   - Auto Lock: mặc định 20 phút, tối đa 20 phút.
//   - autoLockMinutes được lưu vào SharedPreferences để không bị mất khi
//     rời màn Security Settings rồi quay lại (trước đây lưu ở State cục bộ
//     của SecuritySettingsScreen nên bị reset về mặc định mỗi lần dựng lại
//     màn hình).
//   - Bỏ xác thực bằng mật khẩu (app đăng nhập bằng OTP, không có mật khẩu).
//   - Thêm logout() phục vụ nút "Log out" ở Security Settings.
// ===================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLockService extends ChangeNotifier {
  static const String _autoLockMinutesKey = 'nfc_wallet_auto_lock_minutes_v1';
  static const int defaultAutoLockMinutes = 20;
  static const int maxAutoLockMinutes = 20;

  bool _isLocked = false;
  int _autoLockMinutes = defaultAutoLockMinutes;
  Timer? _inactivityTimer;

  bool get isLocked => _isLocked;
  int get autoLockMinutes => _autoLockMinutes;
  Duration get autoLockDuration => Duration(minutes: _autoLockMinutes);

  /// Đọc lại cấu hình Auto Lock đã lưu (gọi 1 lần khi khởi tạo service ở main.dart).
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_autoLockMinutesKey);
    if (saved != null && saved > 0 && saved <= maxAutoLockMinutes) {
      _autoLockMinutes = saved;
      notifyListeners();
    }
  }

  /// Cập nhật số phút Auto Lock, lưu lại persistent để không mất khi rời
  /// màn hình hoặc mở lại app.
  Future<void> setAutoLockMinutes(int minutes) async {
    final clamped = minutes.clamp(1, maxAutoLockMinutes);
    _autoLockMinutes = clamped;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockMinutesKey, clamped);
    // Áp dụng ngay cho lần đếm ngược tiếp theo.
    if (!_isLocked) _resetInactivityTimer();
  }

  /// Khóa app thủ công (người dùng bấm nút "Lock" hoặc rời màn hình lâu).
  void lock() {
    _isLocked = true;
    _inactivityTimer?.cancel();
    notifyListeners();
  }

  /// Mở khóa sau khi xác thực thành công (vân tay).
  void unlock() {
    _isLocked = false;
    _resetInactivityTimer();
    notifyListeners();
  }

  /// Gọi mỗi khi có tương tác trong app để reset lại đồng hồ đếm auto-lock.
  void registerUserActivity() {
    if (_isLocked) return;
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(autoLockDuration, lock);
  }

  /// Mock xác thực lại bằng vân tay — ở bản demo luôn thành công sau 1 giây.
  Future<bool> reauthenticateWithBiometrics() async {
    await Future.delayed(const Duration(seconds: 1));
    unlock();
    return true;
  }

  /// Đăng xuất: hủy đếm ngược auto-lock và đưa trạng thái về ban đầu, để
  /// lần đăng nhập tiếp theo (qua LoginScreen) không bị dính khóa cũ.
  void logout() {
    _inactivityTimer?.cancel();
    _isLocked = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }
}
