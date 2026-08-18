import 'package:flutter/material.dart';

import 'presentation/screens/luu_thong_tin_the_vao_local_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý thẻ Visa',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      // Màn hình chính = chức năng "lưu thông tin thẻ vào local storage",
      // vì đây cũng là nơi hiển thị danh sách thẻ và mở các chức năng khác
      // (thêm thẻ mới -> đọc thẻ có xử lý lỗi).
      home: const LuuThongTinTheVaoLocalStorageScreen(),
    );
  }
}
