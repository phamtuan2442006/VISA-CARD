/// Model dữ liệu thẻ, dùng chung cho toàn bộ chương trình:
/// - Đọc thẻ (xu_ly_loi_doc_the_that_bai.dart)
/// - Thêm thẻ mới vào danh sách quản lý (them_the_moi_vao_danh_sach_quan_ly.dart)
/// - Lưu thông tin thẻ vào local storage (luu_thong_tin_the_vao_local_storage.dart)
class CardModel {
  final String id;
  final String cardNumber;
  final String nickname;
  final DateTime createdAt;

  CardModel({
    required this.id,
    required this.cardNumber,
    required this.nickname,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_number': cardNumber,
      'nickname': nickname,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as String,
      cardNumber: map['card_number'] as String,
      nickname: map['nickname'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
