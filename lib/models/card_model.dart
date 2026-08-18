// ===================================================================
// FILE: card_model.dart
// PHỤ TRÁCH: Huỳnh Phúc Điền
// TASK GỐC (Sprint Backlog):
//   - "Phân tích cấu trúc dữ liệu thẻ cần lưu (số tài khoản, tên chủ thẻ, ngày mở)"
//   - "Lập trình trích xuất số tài khoản, tên chủ thẻ, ngày mở thẻ"
// MÔ TẢ: Định nghĩa cấu trúc dữ liệu 1 thẻ ngân hàng được lưu trong app.
// ===================================================================

class CardModel {
  final String id;
  final String cardHolderName;
  final String last4Digits;
  final String cardBrand; // 'VISA' hoặc 'MASTERCARD'
  final String expiryDate; // định dạng MM/YY
  final DateTime dateAdded;
  bool isActive;
  String? nickname; // Tên gợi nhớ do người dùng đặt (task sửa thẻ, HD 15/08)

  CardModel({
    required this.id,
    required this.cardHolderName,
    required this.last4Digits,
    required this.cardBrand,
    required this.expiryDate,
    required this.dateAdded,
    this.isActive = false,
    this.nickname,
  });

  /// Trích xuất dữ liệu từ kết quả quét NFC (mock) thành CardModel.
  /// Đây là nơi mô phỏng bước "trích xuất số tài khoản, tên chủ thẻ, ngày mở"
  /// theo đúng task được giao.
  factory CardModel.fromNfcPayload(Map<String, dynamic> payload) {
    return CardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cardHolderName: payload['cardHolderName'] as String,
      last4Digits: payload['last4Digits'] as String,
      cardBrand: payload['cardBrand'] as String,
      expiryDate: payload['expiryDate'] as String,
      dateAdded: DateTime.now(),
      isActive: false,
    );
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String,
      cardHolderName: json['cardHolderName'] as String,
      last4Digits: json['last4Digits'] as String,
      cardBrand: json['cardBrand'] as String,
      expiryDate: json['expiryDate'] as String,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      isActive: json['isActive'] as bool? ?? false,
      nickname: json['nickname'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardHolderName': cardHolderName,
      'last4Digits': last4Digits,
      'cardBrand': cardBrand,
      'expiryDate': expiryDate,
      'dateAdded': dateAdded.toIso8601String(),
      'isActive': isActive,
      'nickname': nickname,
    };
  }

  /// Tên hiển thị: ưu tiên nickname nếu người dùng đã đặt, nếu chưa thì
  /// dùng "<Brand> •••• <4 số cuối>" làm mặc định.
  String get displayName => (nickname != null && nickname!.trim().isNotEmpty)
      ? nickname!
      : '$cardBrand •••• $last4Digits';

  /// Chỉ hiển thị 4 số cuối theo đúng ràng buộc bảo mật trong Product Backlog
  /// (User Story #3: "Danh sách chỉ hiển thị tên chủ thẻ và 4 số cuối").
  String get maskedNumber => '•••• •••• •••• $last4Digits';
}
