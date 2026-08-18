// ===================================================================
// FILE: error_handler.dart
// PHỤ TRÁCH: Tăng Lê Duy Long
// TASK GỐC (Sprint Backlog):
//   - "Phân tích các trường hợp lỗi cần xử lý (đọc thẻ thất bại, giao dịch thất bại, timeout)"
//   - "Lập trình xử lý lỗi khi đọc thẻ thất bại (thẻ lỗi, mất kết nối, timeout)"
//   - "Kiểm thử xử lý lỗi / timeout / mất kết nối"
// MÔ TẢ: Định nghĩa các loại lỗi nghiệp vụ và hàm chuyển lỗi
// thành thông báo tiếng Việt dễ hiểu cho người dùng (đúng ràng buộc
// Product Backlog #7: "Thông báo lỗi phải hiển thị nguyên nhân và gợi ý thử lại").
// ===================================================================

/// Lỗi khi đọc thẻ NFC thất bại (thẻ lỗi / không đọc được chip)
class NfcReadException implements Exception {
  final String reason;
  NfcReadException(this.reason);
}

/// Lỗi mất kết nối với đầu thu (POS) trong lúc giao dịch
class ConnectionLostException implements Exception {}

/// Lỗi hết thời gian chờ phản hồi từ đầu thu
class TransactionTimeoutException implements Exception {}

/// Lỗi giao dịch bị từ chối (thẻ hết hạn, không đủ điều kiện...)
class TransactionFailedException implements Exception {
  final String reason;
  TransactionFailedException(this.reason);
}

/// Lỗi khi trích xuất dữ liệu thẻ từ payload NFC bị thiếu/sai định dạng
/// (bổ sung cho task "Lập trình trích xuất dữ liệu thẻ" - Huỳnh Phúc Điền, 12/08)
class CardExtractionException implements Exception {
  final String reason;
  CardExtractionException(this.reason);
}

class AppErrorHandler {
  /// Chuyển 1 Exception kỹ thuật thành thông báo thân thiện + gợi ý xử lý.
  /// Trả về tuple (tiêu đề lỗi, gợi ý xử lý).
  static ({String title, String suggestion}) resolve(Object error) {
    if (error is NfcReadException) {
      return (
        title: 'Không đọc được thẻ (${error.reason})',
        suggestion: 'Vui lòng đặt thẻ áp sát mặt sau điện thoại và giữ yên trong vài giây, sau đó thử lại.',
      );
    }
    if (error is ConnectionLostException) {
      return (
        title: 'Mất kết nối với đầu thu',
        suggestion: 'Kiểm tra khoảng cách giữa điện thoại và đầu thu, sau đó thử lại.',
      );
    }
    if (error is TransactionTimeoutException) {
      return (
        title: 'Hết thời gian chờ phản hồi',
        suggestion: 'Đầu thu không phản hồi kịp thời. Vui lòng thử lại giao dịch.',
      );
    }
    if (error is TransactionFailedException) {
      return (
        title: 'Giao dịch không thành công (${error.reason})',
        suggestion: 'Vui lòng kiểm tra lại thẻ hoặc thử lại sau ít phút.',
      );
    }
    if (error is CardExtractionException) {
      return (
        title: 'Không đọc được thông tin thẻ (${error.reason})',
        suggestion: 'Vui lòng quét lại, giữ thẻ áp sát và không di chuyển trong lúc đọc.',
      );
    }
    return (
      title: 'Đã xảy ra lỗi không xác định',
      suggestion: 'Vui lòng thử lại. Nếu lỗi lặp lại, liên hệ hỗ trợ.',
    );
  }
}
