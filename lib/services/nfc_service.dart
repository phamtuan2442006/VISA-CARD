// ===================================================================
// FILE: nfc_service.dart
// PHỤ TRÁCH: Phạm Tuân
// TASK GỐC (Sprint 2 - Tuần 2, bắt đầu 10/08/2026):
//   "Tích hợp thư viện NFC + xử lý sự kiện phát hiện thẻ"
//
// MÔ TẢ:
//   Service chịu trách nhiệm mở phiên quét NFC và phát ra các sự kiện
//   phát hiện thẻ (tag detected) cho UI lắng nghe. Ở giai đoạn demo,
//   phần đọc chip thật (Android NFC API / iOS Core NFC) được MOCK để
//   chạy được trên emulator, không cần thiết bị NFC thật.
//
//   Việc TRÍCH XUẤT chi tiết dữ liệu thẻ (số tài khoản, tên chủ thẻ...)
//   là task riêng của Huỳnh Phúc Điền (12/08/2026) — file này chỉ dừng
//   ở mức phát hiện + trả về payload thô, đúng phạm vi task được giao.
//
// GHI CHÚ TÍCH HỢP THẬT (khi thay mock bằng thư viện thật):
//   - Android: dùng package `nfc_manager` hoặc `flutter_nfc_kit`,
//     lắng nghe NfcManager.instance.startSession(onDiscovered: ...)
//   - iOS: cần bật capability "Near Field Communication Tag Reading"
//     trong Xcode, và khai báo NFCReaderUsageDescription trong Info.plist
// ===================================================================

import 'dart:async';
import 'dart:math';

/// Trạng thái của phiên quét NFC, UI sẽ lắng nghe stream này để cập nhật
/// giao diện "Ready to Scan" / "Searching..." theo đúng mockup Figma.
enum NfcSessionState { idle, scanning, tagDetected, error, stopped }

/// Sự kiện phát ra trong quá trình quét NFC.
class NfcEvent {
  final NfcSessionState state;
  final Map<String, dynamic>? rawPayload; // dữ liệu thô khi phát hiện thẻ
  final String? errorMessage;

  NfcEvent.scanning() : state = NfcSessionState.scanning, rawPayload = null, errorMessage = null;
  NfcEvent.stopped() : state = NfcSessionState.stopped, rawPayload = null, errorMessage = null;

  NfcEvent.detected(Map<String, dynamic> payload)
      : state = NfcSessionState.tagDetected,
        rawPayload = payload,
        errorMessage = null;

  NfcEvent.error(String message)
      : state = NfcSessionState.error,
        rawPayload = null,
        errorMessage = message;
}

class NfcService {
  StreamController<NfcEvent>? _controller;
  bool _sessionActive = false;
  final Random _random = Random();

  /// Kiểm tra thiết bị có hỗ trợ NFC hay không.
  /// (Mock: luôn trả về true để chạy được trên emulator không có chip NFC.)
  Future<bool> isNfcAvailable() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  /// Mở phiên quét NFC. Trả về Stream để UI lắng nghe sự kiện realtime,
  /// đúng với luồng "xử lý sự kiện phát hiện thẻ" trong task được giao.
  Stream<NfcEvent> startSession() {
    _controller = StreamController<NfcEvent>();
    _sessionActive = true;
    _runMockSession();
    return _controller!.stream;
  }

  /// Dừng phiên quét (khi người dùng bấm Cancel hoặc rời màn hình).
  void stopSession() {
    if (_sessionActive) {
      _sessionActive = false;
      _controller?.add(NfcEvent.stopped());
      _controller?.close();
      _controller = null;
    }
  }

  Future<void> _runMockSession() async {
    _controller?.add(NfcEvent.scanning());

    // Mô phỏng thời gian chờ thiết bị đưa thẻ lại gần (giống UX thật)
    await Future.delayed(const Duration(seconds: 2));
    if (!_sessionActive) return;

    // Mô phỏng 15% khả năng đọc thẻ thất bại (thẻ lỗi / rời quá sớm)
    final bool readFailed = _random.nextDouble() < 0.15;

    if (readFailed) {
      _controller?.add(NfcEvent.error('Không phát hiện chip thẻ hợp lệ'));
      _controller?.close();
      _sessionActive = false;
      return;
    }

    // Sự kiện "phát hiện thẻ" — trả về payload thô cho tầng trích xuất xử lý tiếp
    final payload = _generateMockTagPayload();
    _controller?.add(NfcEvent.detected(payload));
    _controller?.close();
    _sessionActive = false;
  }

  /// Payload thô mô phỏng dữ liệu chip EMV đọc được qua NFC.
  /// Huỳnh Phúc Điền sẽ dùng payload này ở service trích xuất riêng.
  Map<String, dynamic> _generateMockTagPayload() {
    final brands = ['VISA', 'MASTERCARD'];
    final names = ['NGUYEN VAN AN', 'TRAN THI BAO', 'LE MINH KHANG'];
    final last4 = (1000 + _random.nextInt(8999)).toString();

    return {
      'cardBrand': brands[_random.nextInt(brands.length)],
      'cardHolderName': names[_random.nextInt(names.length)],
      'last4Digits': last4,
      'expiryDate':
          '${(_random.nextInt(12) + 1).toString().padLeft(2, '0')}/${(27 + _random.nextInt(4))}',
      'detectedAt': DateTime.now().toIso8601String(),
    };
  }

  void dispose() {
    stopSession();
  }
}
