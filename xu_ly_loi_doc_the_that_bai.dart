import 'package:flutter/material.dart';

import '../../data/models/card_model.dart';

/// Lập trình xử lý lỗi khi đọc thẻ thất bại (thẻ lỗi, mất kết nối, timeout).
///
/// Tách riêng phần đọc thẻ + xử lý lỗi thành 1 màn hình dùng chung, để bất
/// kỳ luồng nào cần đọc thẻ (thêm thẻ mới, lưu thông tin thẻ...) đều gọi
/// lại được. Khi đọc thành công, trả về [CardModel] (đúng model dùng chung
/// toàn chương trình) cho màn hình gọi thông qua Navigator.pop.

/// Các loại lỗi có thể xảy ra khi đọc thẻ.
enum CardReadErrorType {
  /// Thẻ không hợp lệ / không đọc được dữ liệu thẻ.
  invalidCard,

  /// Mất kết nối với đầu đọc NFC trong khi đang đọc thẻ.
  connectionLost,

  /// Hết thời gian chờ phản hồi từ đầu đọc (timeout).
  timeout,

  /// Lỗi không xác định.
  unknown,
}

class CardReadException implements Exception {
  final CardReadErrorType type;
  final String detail;

  CardReadException(this.type, this.detail);

  /// Thông báo hiển thị cho người dùng, tiếng Việt, dễ hiểu.
  String get userMessage {
    switch (type) {
      case CardReadErrorType.invalidCard:
        return 'Thẻ không hợp lệ hoặc không đọc được dữ liệu. Vui lòng thử lại với thẻ khác.';
      case CardReadErrorType.connectionLost:
        return 'Mất kết nối với đầu đọc NFC. Vui lòng kiểm tra kết nối và thử lại.';
      case CardReadErrorType.timeout:
        return 'Hết thời gian chờ đọc thẻ. Vui lòng đưa thẻ lại gần đầu đọc và thử lại.';
      case CardReadErrorType.unknown:
        return 'Đã xảy ra lỗi không xác định khi đọc thẻ.';
    }
  }

  @override
  String toString() => 'CardReadException($type): $detail';
}

/// Service đọc thẻ NFC. Khi tích hợp module đọc thẻ thật (luồng tuần 1),
/// chỉ cần thay nội dung [_readCardRaw] bằng lời gọi tới plugin/service NFC
/// thật — vẫn giữ nguyên hợp đồng: trả [CardModel] khi thành công, ném
/// [CardReadException] khi thất bại (đúng 1 trong 3 loại lỗi nêu trên).
class CardReaderService {
  Future<CardModel> readCard({
    Duration timeoutDuration = const Duration(seconds: 5),
  }) async {
    try {
      return await _readCardRaw().timeout(
        timeoutDuration,
        onTimeout: () => throw CardReadException(
          CardReadErrorType.timeout,
          'Không có phản hồi sau ${timeoutDuration.inSeconds}s',
        ),
      );
    } on CardReadException {
      rethrow;
    } catch (e) {
      throw CardReadException(CardReadErrorType.unknown, e.toString());
    }
  }

  Future<CardModel> _readCardRaw() async {
    // TODO: thay đoạn mô phỏng này bằng lời gọi thực tới plugin NFC (tuần 1).
    await Future.delayed(const Duration(milliseconds: 900));

    final now = DateTime.now();
    if (now.second % 5 == 1) {
      throw CardReadException(
          CardReadErrorType.invalidCard, 'Sai định dạng / CRC không khớp');
    }
    if (now.second % 5 == 2) {
      throw CardReadException(
          CardReadErrorType.connectionLost, 'NFC adapter bị ngắt kết nối');
    }

    return CardModel(
      id: now.microsecondsSinceEpoch.toString(),
      cardNumber:
          '4${now.millisecondsSinceEpoch.toString().substring(0, 11)}',
      nickname: 'Thẻ vừa quét',
    );
  }
}

/// Màn hình đọc thẻ có xử lý lỗi đầy đủ, cho phép thử lại.
/// Trả về [CardModel] cho màn hình gọi khi đọc thành công (Navigator.pop).
class XuLyLoiDocTheThatBaiScreen extends StatefulWidget {
  const XuLyLoiDocTheThatBaiScreen({super.key, CardReaderService? reader})
      : reader = reader ?? const _DefaultReaderHolder().value;

  final CardReaderService reader;

  @override
  State<XuLyLoiDocTheThatBaiScreen> createState() =>
      _XuLyLoiDocTheThatBaiScreenState();
}

class _DefaultReaderHolder {
  const _DefaultReaderHolder();
  CardReaderService get value => CardReaderService();
}

class _XuLyLoiDocTheThatBaiScreenState
    extends State<XuLyLoiDocTheThatBaiScreen> {
  bool _reading = false;
  CardReadException? _lastError;

  @override
  void initState() {
    super.initState();
    _docThe();
  }

  Future<void> _docThe() async {
    setState(() {
      _reading = true;
      _lastError = null;
    });

    try {
      final card = await widget.reader.readCard();
      if (!mounted) return;
      Navigator.of(context).pop(card);
    } on CardReadException catch (e) {
      if (!mounted) return;
      setState(() => _lastError = e);
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đọc thẻ NFC')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_reading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Đang đọc thẻ, vui lòng giữ thẻ gần đầu đọc...'),
              ] else if (_lastError != null) ...[
                Icon(Icons.error_outline,
                    color: Theme.of(context).colorScheme.error, size: 48),
                const SizedBox(height: 12),
                Text(_lastError!.userMessage, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _docThe,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Hủy'),
                ),
              ] else ...[
                const Icon(Icons.nfc, size: 48),
                const SizedBox(height: 12),
                const Text('Sẵn sàng đọc thẻ'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
