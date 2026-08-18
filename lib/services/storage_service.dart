// ===================================================================
// FILE: storage_service.dart
// PHỤ TRÁCH: Tăng Lê Duy Long
// TASK GỐC (13/08/2026):
//   "Lập trình lưu thông tin thẻ vào local storage
//    (sau khi có dữ liệu trích xuất)"
//
// MÔ TẢ:
//   Đọc/ghi danh sách CardModel xuống bộ nhớ máy bằng SharedPreferences.
//   Theo ràng buộc Product Backlog #2 ("Dữ liệu thẻ phải được mã hóa
//   trước khi lưu vào storage"), dữ liệu được encode trước khi ghi.
//
// GHI CHÚ QUAN TRỌNG (để đúng thực tế production):
//   Bước "_encode/_decode" ở đây chỉ là base64 - CHỈ mang tính placeholder
//   để mô phỏng bước mã hóa cho bản demo. Khi làm thật, cần thay bằng
//   flutter_secure_storage (lưu vào Keystore/Keychain) hoặc mã hóa AES
//   với khóa sinh riêng cho từng thiết bị.
// ===================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

class StorageService {
  static const String _cardsKey = 'nfc_wallet_saved_cards_v1';

  /// Đọc toàn bộ danh sách thẻ đã lưu.
  Future<List<CardModel>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cardsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decodedJson = _decode(raw);
      final List<dynamic> list = jsonDecode(decodedJson) as List<dynamic>;
      return list
          .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Dữ liệu lưu trữ bị hỏng/không đọc được -> coi như chưa có thẻ nào
      return [];
    }
  }

  /// Ghi đè toàn bộ danh sách thẻ xuống storage.
  Future<void> saveCards(List<CardModel> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(cards.map((c) => c.toJson()).toList());
    await prefs.setString(_cardsKey, _encode(jsonStr));
  }

  String _encode(String plainText) => base64Encode(utf8.encode(plainText));

  String _decode(String encodedText) => utf8.decode(base64Decode(encodedText));
}
