// ===================================================================
// FILE: transaction_repository.dart
// PHỤ TRÁCH: Huỳnh Phúc Điền
// TASK GỐC (15-16/08/2026):
//   "Lập trình xử lý phản hồi từ đầu thu (sau khi có chức năng gửi dữ liệu)"
//
// MÔ TẢ:
//   Nhận sự kiện PosTransferEvent (kết quả trả về từ đầu thu, do
//   PosTransferService của Phạm Tuân phát ra) và xử lý thành bản ghi
//   giao dịch hoàn chỉnh, lưu vào lịch sử để màn hình Transaction History
//   (Nguyễn Lê Chí Khải) có dữ liệu để hiển thị.
//
//   Việc lưu trữ dùng lại đúng pattern StorageService mà Tăng Lê Duy Long
//   đã thiết kế cho danh sách thẻ, áp dụng tương tự cho danh sách giao dịch.
// ===================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../services/pos_transfer_service.dart';
import '../utils/error_handler.dart';

class TransactionRepository extends ChangeNotifier {
  static const String _storageKey = 'nfc_wallet_transactions_v1';

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  List<TransactionModel> get successfulTransactions =>
      _transactions.where((t) => t.status == TransactionStatus.success).toList();
  List<TransactionModel> get failedTransactions =>
      _transactions.where((t) => t.status == TransactionStatus.failed).toList();

  /// Nạp lịch sử giao dịch đã lưu khi mở app.
  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      _transactions = [];
    } else {
      try {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        _transactions = list
            .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _transactions = [];
      }
    }
    // Mới nhất lên đầu
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  /// Xử lý phản hồi từ đầu thu (PosTransferEvent) sau khi giao dịch kết thúc
  /// (thành công hoặc thất bại) — đây là phần lõi của task được giao.
  /// Trả về TransactionModel đã hoàn chỉnh, hoặc null nếu event chưa kết thúc
  /// (vẫn đang connecting/sending).
  Future<TransactionModel?> handlePosResponse(
    PosTransferEvent event, {
    required String cardId,
    required double amount,
    required String merchantName,
  }) async {
    TransactionModel transaction;

    if (event.stage == PosTransferStage.success && event.transaction != null) {
      transaction = event.transaction!;
    } else if (event.stage == PosTransferStage.failed) {
      final resolved = AppErrorHandler.resolve(
        event.error ?? TransactionFailedException('không rõ nguyên nhân'),
      );
      transaction = TransactionModel(
        id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        cardId: cardId,
        merchantName: merchantName,
        amount: amount,
        date: DateTime.now(),
        status: TransactionStatus.failed,
        errorMessage: resolved.title,
      );
    } else {
      // Đang connecting/sending, chưa có kết quả cuối cùng
      return null;
    }

    _transactions.insert(0, transaction);
    await _persist();
    notifyListeners();
    return transaction;
  }
}
