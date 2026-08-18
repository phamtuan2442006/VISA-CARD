// ===================================================================
// FILE: card_repository.dart
// CẬP NHẬT: Thêm logic ngẫu nhiên 70% còn hạn / 30% hết hạn khi addCard
// ===================================================================

import 'dart:math'; // Thêm thư viện để dùng Random
import 'package:flutter/foundation.dart';
import '../models/card_model.dart';
import 'storage_service.dart';

class CardRepository extends ChangeNotifier {
  final StorageService _storageService;
  List<CardModel> _cards = [];
  bool _isLoaded = false;
  final Random _random = Random(); // Khởi tạo biến Random

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

  Future<void> loadCards() async {
    _cards = await _storageService.loadCards();
    _isLoaded = true;
    notifyListeners();
  }

  /// Hàm addCard được chỉnh sửa để tự động phân bổ ngẫu nhiên:
  /// 70% cơ hội là thẻ còn hạn, 30% cơ hội là thẻ hết hạn khi bạn Scan.
  Future<void> addCard(CardModel card) async {
    final alreadyExists = _cards.any(
          (c) => c.last4Digits == card.last4Digits && c.cardBrand == card.cardBrand,
    );
    if (alreadyExists) return;

    // --- TÍNH TOÁN NGẪU NHIÊN 70% / 30% ---
    // Sinh số ngẫu nhiên từ 0 đến 99
    int randomNumber = _random.nextInt(100);
    String assignedExpiryDate;

    if (randomNumber < 50) {
      // 30% tỉ lệ: Tạo thẻ HẾT HẠN (ví dụ: tháng/năm trong quá khứ như 05/24)
      assignedExpiryDate = '05/24';
    } else {
      // 70% tỉ lệ: Tạo thẻ CÒN HẠN (ví dụ: tháng/năm trong tương lai như 10/28)
      assignedExpiryDate = '10/28';
    }

    // Tạo bản sao của thẻ được scan nhưng mang ngày hết hạn đã được phân ngẫu nhiên
    final processedCard = CardModel(
      id: card.id,
      cardHolderName: card.cardHolderName,
      last4Digits: card.last4Digits,
      cardBrand: card.cardBrand,
      expiryDate: assignedExpiryDate, // Gán ngày hết hạn theo tỉ lệ 70/30
      dateAdded: card.dateAdded,
      isActive: _cards.isEmpty ? true : card.isActive,
      nickname: card.nickname,
    );

    // Nếu đây là thẻ đầu tiên, tự động đặt làm active.
    if (_cards.isEmpty) processedCard.isActive = true;

    _cards.add(processedCard);
    await _storageService.saveCards(_cards);
    notifyListeners();
  }

  Future<void> setActiveCard(String cardId) async {
    for (final c in _cards) {
      c.isActive = c.id == cardId;
    }
    await _storageService.saveCards(_cards);
    notifyListeners();
  }

  Future<void> deleteCard(String cardId) async {
    final wasActive = _cards.any((c) => c.id == cardId && c.isActive);
    _cards.removeWhere((c) => c.id == cardId);

    if (wasActive && _cards.isNotEmpty) {
      _cards.first.isActive = true;
    }

    await _storageService.saveCards(_cards);
    notifyListeners();
  }

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
      last4Digits: old.last4Digits,
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