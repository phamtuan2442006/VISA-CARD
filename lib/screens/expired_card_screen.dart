// ===================================================================
// FILE: expired_card_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// GẮN VỚI: US-04 (chọn thẻ active) — kiểm tra hợp lệ do CardValidityService
// của Phạm Tuân cung cấp.
//
// MÔ TẢ: Hiển thị khi người dùng bấm vào 1 thẻ đã hết hạn trong Saved Cards
// (thay vì chỉ hiện SnackBar như trước) — theo mockup Figma
// "13 Expired/Invalid Card", cho phép xem chi tiết hoặc xóa luôn thẻ đó.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../services/card_repository.dart';
import '../theme/app_theme.dart';

class ExpiredCardScreen extends StatelessWidget {
  final CardModel card;
  const ExpiredCardScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Not Available')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
              child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 24),
            _buildExpiredCardPreview(),
            const SizedBox(height: 24),
            Text(
              'This card has expired and cannot be used for NFC payment.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => _showDetails(context),
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('View Card Details'),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => _removeCard(context),
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
              label: const Text('Remove Card', style: TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiredCardPreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.cardBrand,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 20),
              Text(card.maskedNumber, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
        Transform.rotate(
          angle: -0.15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('EXPIRED',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Card Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cardholder: ${card.cardHolderName}'),
            Text('Number: ${card.maskedNumber}'),
            Text('Expiry: ${card.expiryDate}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _removeCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa thẻ đã hết hạn?'),
        content: const Text('Thẻ sẽ bị xóa khỏi danh sách và không thể khôi phục.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              context.read<CardRepository>().deleteCard(card.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
