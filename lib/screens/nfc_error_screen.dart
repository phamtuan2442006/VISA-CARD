// ===================================================================
// FILE: nfc_error_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// GẮN VỚI: US-07 ("Thông báo lỗi phải hiển thị nguyên nhân và gợi ý thử lại")
//
// MÔ TẢ: Thay cho dialog nhỏ trước đây, đây là màn hình lỗi toàn màn hình
// theo mockup Figma "14 NFC/Payment Error" — hiển thị khi quét thẻ thất bại
// (NfcReadException/timeout từ NfcService của Phạm Tuân + NfcTimeoutGuard
// của Tăng Lê Duy Long), kèm danh sách gợi ý khắc phục cụ thể.
// ===================================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NfcErrorScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const NfcErrorScreen({
    super.key,
    this.title = 'Unable to Read Card',
    this.subtitle = 'Your card could not be detected.',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC Card Reader')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.priority_high_rounded, size: 48, color: AppColors.danger),
            ),
            const SizedBox(height: 22),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TRY THE FOLLOWING',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    _tipRow('Make sure NFC is enabled'),
                    _tipRow('Hold card closer'),
                    _tipRow('Keep still'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
