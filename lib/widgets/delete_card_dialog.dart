// ===================================================================
// FILE: delete_card_dialog.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// GẮN VỚI: US-05 ("Phải có bước xác nhận trước khi xóa để tránh xóa nhầm")
//
// MÔ TẢ: Popup xác nhận xóa thẻ theo đúng mockup Figma "15 Delete Card
// Confirmation" — có icon cảnh báo, preview thu nhỏ của thẻ sắp xóa, và
// nút "Delete Card" màu đỏ. Dùng chung cho Saved Cards và Expired Card.
// ===================================================================

import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../theme/app_theme.dart';

class DeleteCardDialog extends StatelessWidget {
  final CardModel card;

  const DeleteCardDialog({super.key, required this.card});

  static Future<bool?> show(BuildContext context, CardModel card) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteCardDialog(card: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 30),
            ),
            const SizedBox(height: 16),
            const Text('Delete this card?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.darkNavy]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('${card.cardBrand} •••• ${card.last4Digits}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This card will be removed from your saved cards. You won\'t be able to use it for future payments unless you add it again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete Card'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
