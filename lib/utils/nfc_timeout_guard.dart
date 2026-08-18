// ===================================================================
// FILE: nfc_timeout_guard.dart
// PHỤ TRÁCH: Tăng Lê Duy Long
// TASK GỐC (14/08/2026):
//   "Lập trình xử lý lỗi khi đọc thẻ thất bại (thẻ lỗi, mất kết nối, timeout)"
//
// MÔ TẢ:
//   Bọc (wrap) Stream<NfcEvent> từ NfcService (Phạm Tuân) với một bộ đếm
//   thời gian chờ (timeout). Nếu quá thời gian quy định mà không có sự kiện
//   phát hiện thẻ hoặc lỗi nào được phát ra, tự động phát sinh lỗi timeout
//   để UI hiển thị thông báo rõ ràng thay vì treo màn hình vô thời hạn.
// ===================================================================

import 'dart:async';
import '../services/nfc_service.dart';
import 'error_handler.dart';

class NfcTimeoutGuard {
  /// Thời gian tối đa chờ phát hiện thẻ trước khi báo timeout.
  static const Duration defaultTimeout = Duration(seconds: 8);

  /// Bọc stream gốc của NfcService, tự phát ra NfcEvent lỗi timeout
  /// nếu không có kết quả nào trong khoảng thời gian [timeout].
  static Stream<NfcEvent> wrap(
    Stream<NfcEvent> source, {
    Duration timeout = defaultTimeout,
  }) {
    late StreamController<NfcEvent> controller;
    Timer? timeoutTimer;
    StreamSubscription<NfcEvent>? subscription;

    void resetTimer() {
      timeoutTimer?.cancel();
      timeoutTimer = Timer(timeout, () {
        controller.add(
          NfcEvent.error(TransactionTimeoutException().toString()),
        );
        controller.close();
        subscription?.cancel();
      });
    }

    controller = StreamController<NfcEvent>(
      onListen: () {
        resetTimer();
        subscription = source.listen(
          (event) {
            // Chỉ các sự kiện "đang quét" mới reset timer; sự kiện
            // kết thúc (detected/error/stopped) sẽ tự đóng stream.
            if (event.state == NfcSessionState.scanning) {
              resetTimer();
            } else {
              timeoutTimer?.cancel();
            }
            controller.add(event);
            if (event.state != NfcSessionState.scanning) {
              controller.close();
            }
          },
          onError: (Object e) {
            timeoutTimer?.cancel();
            controller.add(NfcEvent.error(e.toString()));
            controller.close();
          },
          onDone: () {
            timeoutTimer?.cancel();
          },
        );
      },
      onCancel: () {
        timeoutTimer?.cancel();
        subscription?.cancel();
      },
    );

    return controller.stream;
  }
}
