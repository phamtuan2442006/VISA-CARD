// ===================================================================
// FILE: transaction_model.dart
// PHỤ TRÁCH: Huỳnh Phúc Điền
// TASK GỐC: "Lập trình xử lý phản hồi từ đầu thu (sau khi có chức năng gửi dữ liệu)"
// MÔ TẢ: Cấu trúc dữ liệu 1 giao dịch NFC (kết quả thanh toán).
// ===================================================================

enum TransactionStatus { success, failed }

class TransactionModel {
  final String id;
  final String cardId;
  final String merchantName;
  final double amount;
  final DateTime date;
  final TransactionStatus status;
  final String? errorMessage;

  TransactionModel({
    required this.id,
    required this.cardId,
    required this.merchantName,
    required this.amount,
    required this.date,
    required this.status,
    this.errorMessage,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      merchantName: json['merchantName'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] == 'success'
          ? TransactionStatus.success
          : TransactionStatus.failed,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'merchantName': merchantName,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status == TransactionStatus.success ? 'success' : 'failed',
      'errorMessage': errorMessage,
    };
  }
}
