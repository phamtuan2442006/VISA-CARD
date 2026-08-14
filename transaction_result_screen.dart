// ===================================================================
// FILE: transaction_result_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// TASK GỐC (14/08/2026):
//   "Dựng giao diện màn hình truyền thẻ, kết quả giao dịch" (phần 2/2:
//   màn hình kết quả giao dịch)
//
// MÔ TẢ:
//   Hiển thị kết quả sau khi PosTransferService (Phạm Tuân) trả về:
//   - Thành công: icon check xanh + số tiền + thời gian giao dịch.
//   - Thất bại: icon X đỏ + thông báo lỗi thân thiện (dùng AppErrorHandler
//     của Tăng Lê Duy Long) + nút "Thử lại".
// ===================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../utils/error_handler.dart';
import 'nfc_payment_screen.dart';

class TransactionResultScreen extends StatelessWidget {
  final String merchantName;
  final double amount;
  final TransactionModel? transaction;
  final Object? error;

  const TransactionResultScreen({
    super.key,
    required this.merchantName,
    required this.amount,
    this.transaction,
    this.error,
  });

  bool get isSuccess => transaction != null && error == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
        title: const Text('NFC Card Reader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isSuccess ? AppColors.success : AppColors.danger)
                    .withOpacity(0.12),
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                size: 56,
                color: isSuccess ? AppColors.success : AppColors.danger,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSuccess ? 'Transaction Successful' : 'Transaction Failed',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isSuccess
                  ? 'Your payment has been processed.'
                  : _resolvedError().title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            if (isSuccess) _buildSuccessDetails() else _buildFailureDetails(),
            const Spacer(),
            if (isSuccess)
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text('Done'),
              )
            else ...[
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NfcPaymentScreen(
                      amount: amount,
                      merchantName: merchantName,
                    ),
                  ),
                ),
                child: const Text('Thử lại'),
              ),
              TextButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text('Về trang chủ'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessDetails() {
    final df = DateFormat('dd/MM/yyyy • HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text('AMOUNT PAID',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 28),
            _detailRow('Merchant', merchantName),
            _detailRow('Transaction ID', transaction?.id ?? '-'),
            _detailRow('Date & Time', df.format(transaction?.date ?? DateTime.now())),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureDetails() {
    final resolved = _resolvedError();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nguyên nhân',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(resolved.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Text('Gợi ý xử lý',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(resolved.suggestion),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  ({String title, String suggestion}) _resolvedError() {
    if (error == null) {
      return (title: 'Lỗi không xác định', suggestion: 'Vui lòng thử lại.');
    }
    return AppErrorHandler.resolve(error!);
  }
}
