// ===================================================================
// FILE: bank_card_widget.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// MÔ TẢ: Widget dùng chung để vẽ 1 thẻ ngân hàng cách điệu (Saved Cards,
// Card Details, NFC Payment) — theo đúng phong cách mockup Figma.
// ===================================================================

import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../theme/app_theme.dart';

class BankCardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback? onTap;

  const BankCardWidget({super.key, required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isVisa = card.cardBrand.toUpperCase() == 'VISA';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card.isActive
                ? [AppColors.primaryBlue, AppColors.darkNavy]
                : [Colors.grey.shade400, Colors.grey.shade600],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (card.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('● Active',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  )
                else
                  const SizedBox(),
                Text(
                  isVisa ? 'VISA' : 'MASTERCARD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              card.maskedNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.cardHolderName.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text(
                  card.expiryDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
