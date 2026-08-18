// ===================================================================
// FILE: nfc_payment_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// CẬP NHẬT: Quản lý Stream chặt chẽ, reset state đúng cách,
//           sửa lỗi luồng điều hướng không cho phép quét lại.
// ===================================================================

import 'dart:async'; // Import để quản lý Subscription
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../services/card_repository.dart';
import '../services/pos_transfer_service.dart';
import '../services/transaction_repository.dart';
import '../services/card_validity_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bank_card_widget.dart';
import '../widgets/card_selector_sheet.dart';
import 'transaction_result_screen.dart';

class NfcPaymentScreen extends StatefulWidget {
  final double amount;
  final String merchantName;

  const NfcPaymentScreen({
    super.key,
    this.amount = 45.00,
    this.merchantName = 'Coffee Shop XYZ',
  });

  @override
  State<NfcPaymentScreen> createState() => _NfcPaymentScreenState();
}

class _NfcPaymentScreenState extends State<NfcPaymentScreen> {
  final PosTransferService _posService = PosTransferService();
  final CardValidityService _validityService = CardValidityService();

  StreamSubscription? _posSubscription; // Quản lý luồng kết nối
  String _statusLabel = 'Ready to Pay';
  bool _isProcessing = false;

  @override
  void dispose() {
    _posSubscription?.cancel(); // Hủy kết nối khi thoát màn hình để không bị kẹt
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardRepo = context.watch<CardRepository>();
    final activeCard = cardRepo.activeCard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Card Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Change',
            onPressed: () => CardSelectorSheet.show(context, cardRepo),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (activeCard != null)
              GestureDetector(
                onTap: () => CardSelectorSheet.show(context, cardRepo),
                child: BankCardWidget(card: activeCard),
              )
            else
              const _NoActiveCardNotice(),
            const SizedBox(height: 32),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withOpacity(0.1),
              ),
              child: Icon(
                Icons.nfc,
                size: 64,
                color: _isProcessing ? AppColors.primaryBlue : AppColors.primaryBlue.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(_statusLabel,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Hold your phone near the POS terminal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: (activeCard == null || _isProcessing)
                  ? null
                  : () => _startPayment(activeCard),
              child: Text(_isProcessing ? 'Processing...' : 'Confirm Payment'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isProcessing ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _startPayment(CardModel card) {
    final validityError = _validityService.getValidityError(card);
    if (validityError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.danger, content: Text(validityError)),
      );
      return;
    }

    setState(() => _isProcessing = true);
    final transactionRepo = context.read<TransactionRepository>();

    // Hủy subscription cũ (nếu có) trước khi tạo mới
    _posSubscription?.cancel();

    _posSubscription = _posService
        .sendCardToPos(
      card: card,
      amount: widget.amount,
      merchantName: widget.merchantName,
    )
        .listen((event) async {
      if (!mounted) return;

      switch (event.stage) {
        case PosTransferStage.connecting:
          setState(() => _statusLabel = 'Connecting to terminal...');
          break;
        case PosTransferStage.sending:
          setState(() => _statusLabel = 'Sending card data...');
          break;
        case PosTransferStage.success:
        case PosTransferStage.failed:
          await transactionRepo.handlePosResponse(
            event,
            cardId: card.id,
            amount: widget.amount,
            merchantName: widget.merchantName,
          );

          if (!mounted) return;

          // Reset trạng thái màn hình trước khi điều hướng
          setState(() {
            _isProcessing = false;
            _statusLabel = 'Ready to Pay';
          });

          // Sử dụng push thay vì pushReplacement để giữ stack,
          // giúp khi quay lại màn hình này vẫn giữ được trạng thái sạch.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionResultScreen(
                merchantName: widget.merchantName,
                amount: widget.amount,
                transaction: event.transaction,
                error: event.error,
              ),
            ),
          );
          break;
      }
    });
  }
}

class _NoActiveCardNotice extends StatelessWidget {
  const _NoActiveCardNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Text(
        'Chưa có thẻ active. Vui lòng thêm và chọn 1 thẻ trước khi thanh toán.',
        textAlign: TextAlign.center,
      ),
    );
  }
}