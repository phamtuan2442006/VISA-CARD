// ===================================================================
// FILE: card_selector_sheet.dart
// PHỤ TRÁCH: Phạm Tuân
// TASK GỐC (16-17/08/2026):
//   "Lập trình chức năng chọn thẻ để thao tác (set active)"
//
// MÔ TẢ:
//   Khác với việc đặt active vĩnh viễn ở màn Saved Cards (do Tăng Lê Duy
//   Long xây dựng ở CardRepository.setActiveCard), đây là bottom sheet cho
//   phép chọn nhanh 1 thẻ khác NGAY TRONG luồng thanh toán (nút "Change"
//   trên NFC Payment screen theo mockup Figma) — chọn xong sẽ tự đặt thẻ
//   đó làm active và đóng sheet, không cần rời khỏi màn thanh toán.
//
//   Có tích hợp CardValidityService để loại các thẻ đã hết hạn ra khỏi
//   danh sách được phép chọn.
// ===================================================================

import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../services/card_repository.dart';
import '../services/card_validity_service.dart';
import '../theme/app_theme.dart';

class CardSelectorSheet extends StatelessWidget {
  final CardRepository repository;

  const CardSelectorSheet({super.key, required this.repository});

  static Future<void> show(BuildContext context, CardRepository repository) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CardSelectorSheet(repository: repository),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validity = CardValidityService();
    final cards = repository.cards;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chọn thẻ thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (cards.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Chưa có thẻ nào được lưu.'),
            )
          else
            ...cards.map((card) => _buildCardTile(context, card, validity)),
        ],
      ),
    );
  }

  Widget _buildCardTile(BuildContext context, CardModel card, CardValidityService validity) {
    final expired = !validity.isCardValid(card);

    return ListTile(
      enabled: !expired,
      leading: Icon(
        Icons.credit_card,
        color: expired ? AppColors.textSecondary : AppColors.primaryBlue,
      ),
      title: Text(card.displayName),
      subtitle: Text(
        expired ? 'Đã hết hạn (${card.expiryDate})' : card.maskedNumber,
        style: TextStyle(color: expired ? AppColors.danger : AppColors.textSecondary),
      ),
      trailing: card.isActive ? const Icon(Icons.check_circle, color: AppColors.success) : null,
      onTap: expired
          ? null
          : () {
              repository.setActiveCard(card.id);
              Navigator.pop(context);
            },
    );
  }
}
