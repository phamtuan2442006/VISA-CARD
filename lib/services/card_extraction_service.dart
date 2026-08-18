// ===================================================================
// FILE: card_extraction_service.dart
// PHỤ TRÁCH: Huỳnh Phúc Điền
// TASK GỐC (12/08/2026):
//   "Lập trình trích xuất số tài khoản, tên chủ thẻ, ngày mở thẻ
//    (sau khi NFC sẵn sàng)"
//
// MÔ TẢ:
//   Nhận payload thô từ NfcService.rawPayload (của Phạm Tuân) và chuyển
//   thành CardModel hoàn chỉnh. Có kiểm tra tính hợp lệ của dữ liệu
//   trước khi trả về, ném CardExtractionException nếu thiếu/sai định dạng
//   (đúng ràng buộc "phải kiểm tra dữ liệu trước khi lưu").
// ===================================================================

import '../models/card_model.dart';
import '../utils/error_handler.dart';

class CardExtractionService {
  /// Trích xuất CardModel từ payload thô do NfcService phát hiện được.
  CardModel extractFromPayload(Map<String, dynamic> payload) {
    final cardBrand = payload['cardBrand'] as String?;
    final cardHolderName = payload['cardHolderName'] as String?;
    final last4Digits = payload['last4Digits'] as String?;
    final expiryDate = payload['expiryDate'] as String?;

    if (cardBrand == null || cardBrand.isEmpty) {
      throw CardExtractionException('thiếu thông tin loại thẻ');
    }
    if (cardHolderName == null || cardHolderName.trim().isEmpty) {
      throw CardExtractionException('thiếu tên chủ thẻ');
    }
    if (last4Digits == null || !RegExp(r'^\d{4}$').hasMatch(last4Digits)) {
      throw CardExtractionException('số thẻ không hợp lệ');
    }
    if (expiryDate == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) {
      throw CardExtractionException('ngày hết hạn không hợp lệ');
    }

    return CardModel.fromNfcPayload({
      'cardBrand': cardBrand,
      'cardHolderName': _normalizeName(cardHolderName),
      'last4Digits': last4Digits,
      'expiryDate': expiryDate,
    });
  }

  /// Chuẩn hóa tên chủ thẻ về dạng "Chữ Hoa Đầu Từ" thay vì toàn bộ IN HOA
  /// (dữ liệu chip EMV thường trả về toàn bộ chữ in hoa).
  String _normalizeName(String raw) {
    return raw
        .toLowerCase()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
