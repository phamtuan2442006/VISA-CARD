// ===================================================================
// FILE: nfc_scan_flow.dart
// PHỤ TRÁCH: Phạm Tuân (logic quét) + Nguyễn Lê Chí Khải (UI/điều hướng)
//
// MÔ TẢ:
//   Gộp luồng "quét thẻ mới" thành 1 hàm dùng chung, để cả Saved Cards
//   (nút "+" Add New Card) cũng gọi được y hệt logic Home đang dùng —
//   trước đây nút "+" chỉ Navigator.pop(context) về Home, người dùng phải
//   tự bấm lại "Scan Card" mới thực sự quét được, gây cảm giác nút không
//   hoạt động.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../services/nfc_service.dart';
import '../services/card_extraction_service.dart';
import '../services/card_repository.dart';
import '../screens/nfc_error_screen.dart';
import '../theme/app_theme.dart';
import 'error_handler.dart';
import 'nfc_timeout_guard.dart';

/// Mở bottom sheet "Ready to Scan" và xử lý toàn bộ kết quả (thêm thẻ vào
/// CardRepository, hoặc điều hướng sang NfcErrorScreen nếu lỗi). Gọi được
/// từ bất kỳ màn hình nào có BuildContext hợp lệ (Home, Saved Cards...).
Future<void> runNfcScanFlow(BuildContext context) async {
  final nfcService = NfcService();
  final extractionService = CardExtractionService();

  await showModalBottomSheet(
    context: context,
    isDismissible: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _ScanGuideSheet(
      eventStream: NfcTimeoutGuard.wrap(nfcService.startSession()),
      onCancel: nfcService.stopSession,
      onFinished: (event) async {
        Navigator.of(sheetContext).pop();
        await _handleScanResult(context, event, extractionService);
      },
    ),
  );

  nfcService.dispose();
}

Future<void> _handleScanResult(
  BuildContext context,
  NfcEvent event,
  CardExtractionService extractionService,
) async {
  if (event.state == NfcSessionState.tagDetected) {
    try {
      final CardModel card = extractionService.extractFromPayload(event.rawPayload!);
      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      context.read<CardRepository>().addCard(card);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Đã lưu thẻ ${card.cardBrand} •••• ${card.last4Digits}'),
        ),
      );
    } on CardExtractionException catch (e) {
      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      _showNfcErrorScreen(context, e);
    }
  } else if (event.state == NfcSessionState.error) {
    if (!context.mounted) return;
    // ignore: use_build_context_synchronously
    _showNfcErrorScreen(context, NfcReadException(event.errorMessage ?? 'unknown'));
  }
}

void _showNfcErrorScreen(BuildContext context, Object error) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => NfcErrorScreen(
        onRetry: () {
          Navigator.pop(context);
          runNfcScanFlow(context);
        },
      ),
    ),
  );
}

// ===================================================================
// Widget nội bộ: bottom sheet hướng dẫn quét "Ready to Scan"
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
