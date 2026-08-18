// ===================================================================
// FILE: saved_cards_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// CẬP NHẬT:
//   - Nhấn vào thẻ hết hạn: Mở ExpiredCardScreen.
//   - Nhấn vào thẻ còn hạn: Mở CardDetailsScreen (ảnh B).
//   - Nhấn vào icon cây bút: Mở EditCardScreen.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/card_repository.dart';
import '../services/card_validity_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bank_card_widget.dart';
import 'edit_card_screen.dart';
import 'expired_card_screen.dart';
import 'card_details_screen.dart'; // Màn hình chi tiết thẻ (Ảnh B)

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
              // Kiểm tra thẻ có hợp lệ hay không
              final isExpired = validity.getValidityError(card) != null;

              return Stack(
                children: [
                  BankCardWidget(
                    card: card,
                    onTap: () {
                      // ĐIỀU HƯỚNG KHI NHẤN VÀO THÂN THẺ:
                      if (isExpired) {
                        // Nếu hết hạn -> Mở màn hình thông báo hết hạn
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpiredCardScreen(card: card),
                          ),
                        );
                      } else {
                        // Nếu còn hạn -> Mở màn hình Card Details (Ảnh B)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CardDetailsScreen(card: card),
                          ),
                        );
                      }
                    },
                  ),

                  // Nút đặt làm Active nhanh
                  Positioned(
                    top: 8,
                    right: 88,
                    child: IconButton(
                      icon: const Icon(
                          Icons.check_circle_outline, color: Colors.white),
                      tooltip: 'Đặt làm Active',
                      onPressed: () {
                        if (isExpired) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.danger,
                              content: Text(
                                  'Không thể đặt thẻ đã hết hạn làm Active'),
                            ),
                          );
                          return;
                        }
                        repo.setActiveCard(card.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Đã đặt thẻ làm mặc định')),
                        );
                      },
                    ),
                  ),

                  // Nút Sửa (Cây bút) -> Mở màn hình chỉnh sửa thẻ
                  Positioned(
                    top: 8,
                    right: 48,
                    child: IconButton(
                      icon: const Icon(
                          Icons.edit_outlined, color: Colors.white),
                      onPressed: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EditCardScreen(card: card)),
                          ),
                    ),
                  ),

                  // Nút Xóa thẻ
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(
                          Icons.delete_outline, color: Colors.white),
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
        onPressed: () => Navigator.pop(context),
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
  void _confirmDelete(BuildContext context, CardRepository repo,
      String cardId) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text('Xóa thẻ này?'),
            content: const Text(
                'Thẻ sẽ bị xóa khỏi danh sách và không thể khôi phục.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy')),
              TextButton(
                onPressed: () {
                  repo.deleteCard(cardId);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa thẻ')));
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }
}