// ===================================================================
// FILE: saved_cards_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// TASK GỐC (12/08/2026):
//   "Dựng giao diện danh sách thẻ, popup xóa, empty state"
//
// MÔ TẢ:
//   Hiển thị toàn bộ thẻ đã lưu (CardRepository). Bấm vào thẻ -> đặt làm
//   active. Nút xóa -> popup xác nhận trước khi gọi CardRepository.deleteCard
//   (task của Huỳnh Phúc Điền). Khi danh sách rỗng -> hiển thị empty state.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/card_repository.dart';
import '../services/card_validity_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bank_card_widget.dart';
import 'edit_card_screen.dart';

class SavedCardsScreen extends StatelessWidget {
  const SavedCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final validity = CardValidityService();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Cards')),
      body: Consumer<CardRepository>(
        builder: (context, repo, _) {
          if (repo.cards.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: repo.cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final card = repo.cards[index];
              return Stack(
                children: [
                  BankCardWidget(
                    card: card,
                    onTap: () {
                      // Phạm Tuân (16-17/08): chặn đặt active nếu thẻ đã hết hạn.
                      final error = validity.getValidityError(card);
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: AppColors.danger, content: Text(error)),
                        );
                        return;
                      }
                      repo.setActiveCard(card.id);
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 44,
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditCardScreen(card: card)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: () => _confirmDelete(context, repo, card.id),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () => Navigator.pop(context), // quay lại Home để quét thẻ mới
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ------------------- Empty state -------------------
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.credit_card_off_outlined,
                size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Chưa có thẻ nào được lưu',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quay lại màn hình chính và bấm "Scan Card" để thêm thẻ đầu tiên.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quét thẻ ngay'),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- Popup xác nhận xóa -------------------
  void _confirmDelete(BuildContext context, CardRepository repo, String cardId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa thẻ này?'),
        content: const Text(
          'Thẻ sẽ bị xóa khỏi danh sách và không thể khôi phục. Bạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              repo.deleteCard(cardId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa thẻ')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
