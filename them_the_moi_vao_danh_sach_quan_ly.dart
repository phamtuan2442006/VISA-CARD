import 'package:flutter/material.dart';

import '../../data/models/card_model.dart';
import '../../data/repositories/card_repository.dart';
import 'xu_ly_loi_doc_the_that_bai.dart';

/// Lập trình chức năng thêm thẻ mới vào danh sách quản lý
/// (liên kết luồng đọc thẻ tuần 1).
///
/// Luồng xử lý:
/// 1. Bấm "Quét thẻ NFC" -> mở [XuLyLoiDocTheThatBaiScreen] (đã xử lý đầy
///    đủ lỗi thẻ lỗi / mất kết nối / timeout) -> nhận về [CardModel].
/// 2. Dữ liệu đọc được tự động điền vào form, người dùng có thể chỉnh sửa.
/// 3. Bấm "Thêm vào danh sách" -> validate -> lưu qua [CardRepository]
///    (đồng bộ với dữ liệu do chức năng lưu thông tin thẻ tạo ra) -> trả
///    `true` về màn hình gọi để tự làm mới danh sách.
class ThemTheMoiVaoDanhSachQuanLyScreen extends StatefulWidget {
  const ThemTheMoiVaoDanhSachQuanLyScreen({
    super.key,
    CardRepository? repository,
  }) : repository = repository ?? const _DefaultRepositoryHolder().value;

  final CardRepository repository;

  @override
  State<ThemTheMoiVaoDanhSachQuanLyScreen> createState() =>
      _ThemTheMoiVaoDanhSachQuanLyScreenState();
}

class _DefaultRepositoryHolder {
  const _DefaultRepositoryHolder();
  CardRepository get value => CardRepository();
}

class _ThemTheMoiVaoDanhSachQuanLyScreenState
    extends State<ThemTheMoiVaoDanhSachQuanLyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _quetThe() async {
    final card = await Navigator.of(context).push<CardModel?>(
      MaterialPageRoute(builder: (_) => const XuLyLoiDocTheThatBaiScreen()),
    );
    if (card == null || !mounted) return;

    setState(() {
      _cardNumberController.text = card.cardNumber;
      _nicknameController.text = card.nickname;
    });
  }

  Future<void> _themTheMoi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final newCard = CardModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      cardNumber: _cardNumberController.text.trim(),
      nickname: _nicknameController.text.trim(),
    );

    try {
      await widget.repository.insertCard(newCard);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm thẻ mới vào danh sách quản lý')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm thẻ thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm thẻ mới')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: _quetThe,
                icon: const Icon(Icons.nfc),
                label: const Text('Quét thẻ NFC'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Số thẻ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vui lòng nhập hoặc quét số thẻ'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Tên gợi nhớ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vui lòng nhập tên gợi nhớ'
                    : null,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _themTheMoi,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Thêm vào danh sách'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
