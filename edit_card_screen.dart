// ===================================================================
// FILE: edit_card_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// TASK GỐC (15-16/08/2026): "Dựng giao diện ... Sửa thẻ"
// MÔ TẢ: Form sửa Card Nickname + Cardholder Name, gọi
// CardRepository.updateCardDisplayInfo (Huỳnh Phúc Điền). Số thẻ hiển thị
// dạng chỉ đọc (readOnly) đúng ràng buộc không cho sửa số gốc.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../services/card_repository.dart';
import '../theme/app_theme.dart';

class EditCardScreen extends StatefulWidget {
  final CardModel card;
  const EditCardScreen({super.key, required this.card});

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _holderController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.card.nickname ?? '');
    _holderController = TextEditingController(text: widget.card.cardHolderName);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Card'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardPreview(card),
            const SizedBox(height: 24),
            const Text('Card Nickname',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _nicknameController,
              decoration: _inputDecoration('My Main Visa'),
            ),
            const SizedBox(height: 18),
            const Text('Cardholder Name',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _holderController,
              decoration: _inputDecoration(card.cardHolderName),
            ),
            const SizedBox(height: 18),
            const Text('Card Number',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              enabled: false,
              controller: TextEditingController(text: card.maskedNumber),
              decoration: _inputDecoration(''),
            ),
            const SizedBox(height: 4),
            const Text(
              'Original card data cannot be changed.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const Spacer(),
            ElevatedButton(onPressed: _save, child: const Text('Save Changes')),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.cardSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
    );
  }

  Widget _buildCardPreview(CardModel card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkNavy],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.displayName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(card.maskedNumber, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const Icon(Icons.nfc, color: Colors.white70),
        ],
      ),
    );
  }

  void _save() {
    context.read<CardRepository>().updateCardDisplayInfo(
          widget.card.id,
          nickname: _nicknameController.text,
          cardHolderName: _holderController.text,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu thay đổi')),
    );
    Navigator.pop(context);
  }
}
