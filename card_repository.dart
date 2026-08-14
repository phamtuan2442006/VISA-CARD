// ===================================================================
// FILE: card_repository.dart
// PHỤ TRÁCH:
//   - loadCards() / addCard() / setActiveCard(): Tăng Lê Duy Long (13/08)
//     Task: "Lập trình lưu thông tin thẻ vào local storage"
//   - deleteCard(): Huỳnh Phúc Điền (14/08)
//     Task: "Lập trình chức năng xóa thẻ + cập nhật storage"
//
// MÔ TẢ:
//   ChangeNotifier giữ danh sách thẻ trong bộ nhớ (in-memory) để UI lắng
//   nghe qua Provider, đồng thời đồng bộ mọi thay đổi xuống StorageService.
// ===================================================================

import 'package:flutter/foundation.dart';
import '../models/card_model.dart';
import 'storage_service.dart';

class CardRepository extends ChangeNotifier {
  final StorageService _storageService;
  List<CardModel> _cards = [];
  bool _isLoaded = false;

  CardRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  List<CardModel> get cards => List.unmodifiable(_cards);
  bool get isLoaded => _isLoaded;

  CardModel? get activeCard {
    for (final c in _cards) {
      if (c.isActive) return c;
    }
    return null;
  }

  /// Tăng Lê Duy Long (13/08) — nạp danh sách thẻ đã lưu khi mở app.
  Future<void> loadCards() async {
    _cards = await _storageService.loadCards();
    _isLoaded = true;
    notifyListeners();
  }

  /// Tăng Lê Duy Long (13/08) — thêm thẻ mới sau khi trích xuất thành công
  /// (nối tiếp CardExtractionService của Huỳnh Phúc Điền) và lưu xuống storage.
  Future<void> addCard(CardModel card) async {
    final alreadyExists = _cards.any(
      (c) => c.last4Digits == card.last4Digits && c.cardBrand == card.cardBrand,
    );
    if (alreadyExists) return;

    // Nếu đây là thẻ đầu tiên, tự động đặt làm active.
    if (_cards.isEmpty) card.isActive = true;

    _cards.add(card);
    await _storageService.saveCards(_cards);
    notifyListeners();
  }

  /// Đặt 1 thẻ làm active — đảm bảo chỉ 1 thẻ active tại một thời điểm
  /// (đúng ràng buộc Product Backlog #4).
  Future<void> setActiveCard(String cardId) async {
    for (final c in _cards) {
      c.isActive = c.id == cardId;
    }
    await _storageService.saveCards(_cards);
    notifyListeners();
  }

  /// Huỳnh Phúc Điền (14/08) — xóa thẻ khỏi danh sách + cập nhật storage.
  /// Nếu thẻ bị xóa đang là active, tự động gán active cho thẻ đầu tiên còn lại.
  Future<void> deleteCard(String cardId) async {
    final wasActive = _cards.any((c) => c.id == cardId && c.isActive);
    _cards.removeWhere((c) => c.id == cardId);

    if (wasActive && _cards.isNotEmpty) {
      _cards.first.isActive = true;
    }

    await _storageService.saveCards(_cards);
    notifyListeners();
  }

  /// Huỳnh Phúc Điền (15-16/08) — sửa thông tin hiển thị của thẻ (nickname,
  /// tên chủ thẻ hiển thị). Ràng buộc Product Backlog #11: KHÔNG được sửa
  /// số tài khoản gốc (last4Digits) đã quét được — hàm này chỉ cho phép
  /// cập nhật 2 trường hiển thị, không đụng tới dữ liệu gốc của thẻ.
  Future<void> updateCardDisplayInfo(
    String cardId, {
    String? nickname,
    String? cardHolderName,
  }) async {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return;

    final old = _cards[index];
    _cards[index] = CardModel(
      id: old.id,
      cardHolderName: cardHolderName?.trim().isNotEmpty == true
          ? cardHolderName!.trim()
          : old.cardHolderName,
      last4Digits: old.last4Digits, // không cho sửa số thẻ gốc
      cardBrand: old.cardBrand,
      expiryDate: old.expiryDate,
      dateAdded: old.dateAdded,
      isActive: old.isActive,
      nickname: nickname?.trim().isNotEmpty == true ? nickname!.trim() : old.nickname,
    );

    await _storageService.saveCards(_cards);
    notifyListeners();
  }
}
