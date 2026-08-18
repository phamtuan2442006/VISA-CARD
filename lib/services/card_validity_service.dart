// ===================================================================
// FILE: card_validity_service.dart
// PHỤ TRÁCH: Phạm Tuân
// TASK GỐC (16-17/08/2026):
//   "Lập trình kiểm tra thẻ hết hạn/không hợp lệ trước khi chọn active
//    hoặc giao dịch"
//
// MÔ TẢ:
//   Kiểm tra ngày hết hạn (expiryDate, định dạng MM/YY) của thẻ so với
//   thời điểm hiện tại. Dùng để chặn không cho đặt active hoặc gửi tới
//   đầu thu nếu thẻ đã hết hạn — đúng ràng buộc Product Backlog #15.
// ===================================================================

import '../models/card_model.dart';

class CardValidityService {
  /// Trả về true nếu thẻ còn hiệu lực (chưa hết hạn).
  bool isCardValid(CardModel card) {
    final expiry = _parseExpiry(card.expiryDate);
    if (expiry == null) return false; // định dạng lỗi -> coi như không hợp lệ

    final now = DateTime.now();
    // Thẻ hết hạn vào cuối tháng ghi trên thẻ, nên so sánh với ngày đầu
    // tháng kế tiếp của expiry.
    final expiryEndOfMonth = DateTime(expiry.year, expiry.month + 1, 1);
    return now.isBefore(expiryEndOfMonth);
  }

  /// Trả về thông báo lỗi tiếng Việt nếu thẻ không hợp lệ, null nếu hợp lệ.
  String? getValidityError(CardModel card) {
    if (!isCardValid(card)) {
      return 'Thẻ ${card.cardBrand} •••• ${card.last4Digits} đã hết hạn (${card.expiryDate}), không thể sử dụng.';
    }
    return null;
  }

  /// Parse "MM/YY" -> DateTime(năm đầy đủ, tháng, 1). Trả về null nếu sai định dạng.
  DateTime? _parseExpiry(String expiryDate) {
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(expiryDate);
    if (match == null) return null;
    final month = int.tryParse(match.group(1)!);
    final yearShort = int.tryParse(match.group(2)!);
    if (month == null || yearShort == null || month < 1 || month > 12) return null;
    final year = 2000 + yearShort;
    return DateTime(year, month, 1);
  }
}
