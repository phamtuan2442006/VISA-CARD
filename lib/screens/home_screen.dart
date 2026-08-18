// ===================================================================
// FILE: home_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// TASK GỐC (Sprint 2 - Tuần 2, bắt đầu 10/08/2026):
//   "Dựng giao diện Home, hướng dẫn quét, thông báo kết quả
//    (theo thiết kế tuần 1)"
//
// MÔ TẢ:
//   - Home Dashboard: lời chào, trạng thái NFC, Quick Actions, hoạt động gần đây.
//   - Hướng dẫn quét: bottom sheet "Ready to Scan" hiển thị khi bấm Scan Card,
//     lắng nghe NfcService (của Phạm Tuân) để cập nhật trạng thái realtime.
//   - Thông báo kết quả: SnackBar/Dialog báo thành công hoặc lỗi sau khi quét,
//     dùng AppErrorHandler (của Tăng Lê Duy Long) để hiển thị lỗi thân thiện.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../services/nfc_service.dart';
import '../services/card_extraction_service.dart';
import '../services/card_repository.dart';
import '../services/transaction_repository.dart';
import '../services/auth_lock_service.dart';
import '../theme/app_theme.dart';
import '../utils/error_handler.dart';
import '../utils/nfc_timeout_guard.dart';
import 'saved_cards_screen.dart';
import 'nfc_payment_screen.dart';
import 'transaction_history_screen.dart';
import 'security_settings_screen.dart';
import 'reauth_screen.dart';
import 'nfc_error_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NfcService _nfcService = NfcService();
  final CardExtractionService _extractionService = CardExtractionService();
  bool _nfcEnabled = true;
  int _navIndex = 0;

  @override
  void dispose() {
    _nfcService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthLockService>();

    // Tăng Lê Duy Long (16/08): nếu app đang bị khóa (chủ động hoặc do
    // auto-lock hết thời gian không hoạt động), hiển thị màn xác thực lại
    // thay vì cho xem nội dung Home.
    if (authService.isLocked) {
      return const ReauthScreen();
    }

    return GestureDetector(
      // Ghi nhận tương tác để reset lại đồng hồ đếm auto-lock.
      onTap: () => authService.registerUserActivity(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(),
                const SizedBox(height: 20),
                _buildNfcStatusCard(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildRecentActivitySection(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ------------------- Greeting -------------------
  Widget _buildGreeting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            SizedBox(height: 2),
            Text('Hello, Ronaldo',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ],
        ),
        Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không có thông báo mới')),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------- NFC status card -------------------
  Widget _buildNfcStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.nfc, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NFC Status',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: _nfcEnabled ? AppColors.success : AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        _nfcEnabled ? 'Ready to scan' : 'Disabled',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Đổi từ Switch sang nút "Activate" theo giao diện Figma mới (13/08).
            GestureDetector(
              onTap: () => setState(() => _nfcEnabled = !_nfcEnabled),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _nfcEnabled ? AppColors.primaryBlue : AppColors.divider,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _nfcEnabled ? 'Activate' : 'Activate',
                  style: TextStyle(
                    color: _nfcEnabled ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- Quick actions -------------------
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _nfcEnabled ? _handlePrimaryAction : _showNfcDisabledNotice,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.credit_card, color: Colors.white),
                  SizedBox(height: 6),
                  Text('Scan Card',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedCardsScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Column(
                children: [
                  Icon(Icons.credit_card_outlined, color: AppColors.primaryBlue),
                  SizedBox(height: 6),
                  Text('Saved Cards', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------- Recent activity -------------------
  Widget _buildRecentActivitySection() {
    // Nguyễn Lê Chí Khải: dữ liệu nay lấy thật từ TransactionRepository
    // (Huỳnh Phúc Điền) thay vì mock, hiển thị 3 giao dịch gần nhất.
    final transactions = context.watch<TransactionRepository>().transactions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
              ),
              child: const Text('View All',
                  style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Chưa có giao dịch nào', style: TextStyle(color: AppColors.textSecondary)),
          )
        else
          ...transactions.map((t) => _buildActivityTile(t)),
      ],
    );
  }

  Widget _buildActivityTile(TransactionModel t) {
    final isSuccess = t.status == TransactionStatus.success;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryBlue),
        ),
        title: Text(t.merchantName),
        subtitle: Text(isSuccess ? 'Success' : 'Failed',
            style: TextStyle(color: isSuccess ? AppColors.success : AppColors.danger)),
        trailing: Text(
          '-\$${t.amount.abs().toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _navIndex,
      onDestinationSelected: (index) {
        setState(() => _navIndex = index);
        switch (index) {
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedCardsScreen()))
                .then((_) => setState(() => _navIndex = 0));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NfcPaymentScreen()))
                .then((_) => setState(() => _navIndex = 0));
            break;
          case 3:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()))
                .then((_) => setState(() => _navIndex = 0));
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.credit_card_outlined), label: 'Cards'),
        NavigationDestination(icon: Icon(Icons.nfc), label: 'Payment'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }

  // ===================================================================
  // HƯỚNG DẪN QUÉT — bottom sheet "Ready to Scan"
  // ===================================================================
  void _handlePrimaryAction() {
    // Luôn mở giao diện quét thẻ mới khi nhấn "Scan Card" bất kể đã có thẻ active hay chưa
    _openScanSheet();
  }

  void _openScanSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ScanGuideSheet(
        // Tăng Lê Duy Long (14/08): bọc stream với timeout guard để tránh
        // treo màn hình vô thời hạn nếu không phát hiện thẻ nào.
        eventStream: NfcTimeoutGuard.wrap(_nfcService.startSession()),
        onCancel: _nfcService.stopSession,
        onFinished: (event) {
          Navigator.of(ctx).pop();
          _handleScanResult(event);
        },
      ),
    );
  }

  void _showNfcDisabledNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng bật NFC trước khi quét thẻ')),
    );
  }

  // ===================================================================
  // THÔNG BÁO KẾT QUẢ sau khi quét
  // ===================================================================
  void _handleScanResult(NfcEvent event) {
    if (event.state == NfcSessionState.tagDetected) {
      // Huỳnh Phúc Điền (12/08): trích xuất dữ liệu thẻ từ payload thô.
      try {
        final card = _extractionService.extractFromPayload(event.rawPayload!);
        // Tăng Lê Duy Long (13/08): lưu thẻ vừa trích xuất vào storage.
        context.read<CardRepository>().addCard(card);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text(
              'Đã lưu thẻ ${card.cardBrand} •••• ${card.last4Digits}',
            ),
          ),
        );
      } on CardExtractionException catch (e) {
        _showErrorDialog(e);
      }
    } else if (event.state == NfcSessionState.error) {
      // Nguyễn Lê Chí Khải: lỗi đọc thẻ/timeout dùng màn hình lỗi toàn màn
      // hình (mockup "14 NFC/Payment Error") thay vì dialog nhỏ.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NfcErrorScreen(
            onRetry: () {
              Navigator.pop(context);
              _openScanSheet();
            },
          ),
        ),
      );
    }
  }

  void _showErrorDialog(Object error) {
    final resolved = AppErrorHandler.resolve(error);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(resolved.title),
        content: Text(resolved.suggestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openScanSheet();
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// Widget nội bộ: bottom sheet hướng dẫn quét, lắng nghe NfcService
// ===================================================================
class _ScanGuideSheet extends StatefulWidget {
  final Stream<NfcEvent> eventStream;
  final VoidCallback onCancel;
  final void Function(NfcEvent) onFinished;

  const _ScanGuideSheet({
    required this.eventStream,
    required this.onCancel,
    required this.onFinished,
  });

  @override
  State<_ScanGuideSheet> createState() => _ScanGuideSheetState();
}

class _ScanGuideSheetState extends State<_ScanGuideSheet> {
  String _statusText = 'Ready to Scan';

  @override
  void initState() {
    super.initState();
    widget.eventStream.listen((event) {
      if (!mounted) return;
      setState(() {
        switch (event.state) {
          case NfcSessionState.scanning:
            _statusText = 'Searching...';
            break;
          case NfcSessionState.tagDetected:
          case NfcSessionState.error:
            widget.onFinished(event);
            break;
          default:
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    widget.onCancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withOpacity(0.1),
            ),
            child: const Icon(Icons.nfc, size: 48, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 18),
          Text(_statusText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Hold your card near the back of your phone to read EMV data.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              widget.onCancel();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}