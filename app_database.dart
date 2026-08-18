import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Khởi tạo local storage (SQLite) để lưu thông tin thẻ trên máy,
/// dữ liệu vẫn còn sau khi tắt app / khởi động lại máy.
///
/// Dùng chung cho các chức năng: thêm thẻ mới vào danh sách quản lý,
/// lưu thông tin thẻ vào local storage.
class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_visa.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Bảng lưu trữ thông tin thẻ (local storage)
        await db.execute('''
          CREATE TABLE cards (
            id TEXT PRIMARY KEY,
            card_number TEXT NOT NULL,
            nickname TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
