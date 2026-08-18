// ===================================================================
// FILE: pos_transfer_service.dart
// PHỤ TRÁCH: Phạm Tuân
// TASK GỐC (13/08/2026):
//   "Lập trình chức năng gửi thông tin thẻ đã chọn tới đầu thu"
//
// MÔ TẢ:
//   Mô phỏng việc truyền dữ liệu thẻ (đang active) qua NFC tới đầu thu
//   (POS/điện thoại khác) và nhận phản hồi giao dịch. Ở bản demo, toàn bộ
//   được MOCK bằng delay + xác suất ngẫu nhiên để mô phỏng thành công/thất bại.
//
// GHI CHÚ TÍCH HỢP THẬT:
//   Khi có thiết bị NFC thật, bước "sending" sẽ dùng NFC Host Card Emulation
//   (HCE) trên Android hoặc giao thức tương đương trên iOS để gửi dữ liệu
//   thẻ dưới dạng APDU command tới đầu thu.
// ===================================================================

import 'dart:async';
import 'dart:math';
import '../models/card_model.dart';
import '../models/transaction_model.dart';
import '../utils/error_handler.dart';

enum PosTransferStage { connecting, sending, success, failed }

class PosTransferEvent {
  final PosTransferStage stage;
  final TransactionModel? transaction;
  final Object? error;

  PosTransferEvent.connecting()
      : stage = PosTransferStage.connecting,
        transaction = null,
        error = null;

  PosTransferEvent.sending()
      : stage = PosTransferStage.sending,
        transaction = null,
        error = null;

  PosTransferEvent.success(this.transaction)
      : stage = PosTransferStage.success,
        error = null;

  PosTransferEvent.failed(this.error)
      : stage = PosTransferStage.failed,
        transaction = null;
}

class PosTransferService {
  final Random _random = Random();

  /// Gửi thẻ [card] tới đầu thu với số tiền [amount] tại [merchantName].
  /// Trả về Stream để UI cập nhật theo từng giai đoạn (đúng như mockup
  /// "NFC Payment": connecting -> sending -> kết quả).
  Stream<PosTransferEvent> sendCardToPos({
    required CardModel card,
    required double amount,
    required String merchantName,
  }) async* {
    yield PosTransferEvent.connecting();
    await Future.delayed(const Duration(milliseconds: 900));

    // Mô phỏng 10% khả năng mất kết nối ngay khi bắt đầu kết nối đầu thu
    if (_random.nextDouble() < 0.10) {
      yield PosTransferEvent.failed(ConnectionLostException());
      return;
    }

    yield PosTransferEvent.sending();
    await Future.delayed(const Duration(milliseconds: 1200));

    // Mô phỏng 20% khả năng giao dịch thất bại (từ chối/timeout)
    final outcome = _random.nextDouble();
    if (outcome < 0.10) {
      yield PosTransferEvent.failed(TransactionTimeoutException());
      return;
    }
    if (outcome < 0.20) {
      yield PosTransferEvent.failed(TransactionFailedException('bị đầu thu từ chối'));
      return;
    }

    final transaction = TransactionModel(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      cardId: card.id,
      merchantName: merchantName,
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.success,
    );
    yield PosTransferEvent.success(transaction);
  }
}
