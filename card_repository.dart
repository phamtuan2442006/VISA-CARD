import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/card_model.dart';

/// Thao tác đọc/ghi bảng `cards` trong local storage.
/// Dùng chung cho chức năng "thêm thẻ mới vào danh sách quản lý" và
/// "lưu thông tin thẻ vào local storage".
class CardRepository {
  final AppDatabase _appDb = AppDatabase.instance;

  /// Lưu thông tin thẻ vào local storage (sau khi có dữ liệu trích xuất
  /// từ luồng đọc thẻ).
  Future<void> insertCard(CardModel card) async {
    final db = await _appDb.database;
    await db.insert(
      'cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lấy danh sách thẻ đã lưu trong local storage, mới nhất lên đầu.
  Future<List<CardModel>> getAllCards() async {
    final db = await _appDb.database;
    final maps = await db.query('cards', orderBy: 'created_at DESC');
    return maps.map((m) => CardModel.fromMap(m)).toList();
  }

  /// Xóa một thẻ khỏi local storage theo id.
  Future<void> deleteCard(String id) async {
    final db = await _appDb.database;
    await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}
