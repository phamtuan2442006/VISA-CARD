// ===================================================================
// FILE: main.dart
// MÔ TẢ: Entry point của app. Gắn CardRepository (Tăng Lê Duy Long) vào
// toàn bộ cây widget qua Provider, để các màn hình (Home, Saved Cards,
// NFC Payment...) đều đọc/ghi được cùng 1 nguồn dữ liệu thẻ.
//
// Cập nhật theo tiến độ Sprint 2 (10-14/08/2026):
//   10/08: Home + NFC detect (Phạm Tuân, Nguyễn Lê Chí Khải)
//   12/08: Trích xuất dữ liệu thẻ + Saved Cards UI (Huỳnh Phúc Điền, NLCK)
//   13/08: Gửi thẻ tới POS + lưu storage (Phạm Tuân, Tăng Lê Duy Long)
//   14/08: Xóa thẻ + xử lý lỗi timeout + màn hình Payment/Result
//          (Huỳnh Phúc Điền, Tăng Lê Duy Long, Nguyễn Lê Chí Khải)
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/card_repository.dart';
import 'services/transaction_repository.dart';
import 'services/auth_lock_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NfcCardWalletApp());
}

class NfcCardWalletApp extends StatelessWidget {
  const NfcCardWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CardRepository()..loadCards()),
        ChangeNotifierProvider(create: (_) => TransactionRepository()..loadTransactions()),
        ChangeNotifierProvider(create: (_) => AuthLockService()..loadSettings()),
      ],
      child: MaterialApp(
        title: 'NFC Card Wallet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
