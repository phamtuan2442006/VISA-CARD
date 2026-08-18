import 'package:flutter/material.dart';

import '../../data/models/card_model.dart';
import '../../data/repositories/card_repository.dart';
import 'them_the_moi_vao_danh_sach_quan_ly.dart';

/// Lập trình lưu thông tin thẻ vào local storage (sau khi có dữ liệu
/// trích xuất từ luồng đọc thẻ).
///
/// Đây cũng là màn hình chính của chương trình: hiển thị danh sách thẻ đã
/// lưu trong local storage (đọc qua [CardRepository.getAllCards]) và cho
/// phép:
/// - Nhập tay để lưu trực tiếp một thẻ vào local storage.
/// - Mở [ThemTheMoiVaoDanhSachQuanLyScreen] (chức năng thêm thẻ mới, có
///   liên kết luồng đọc thẻ + xử lý lỗi) rồi tự làm mới danh sách.
class LuuThongTinTheVaoLocalStorageScreen extends StatefulWidget {
  const LuuThongTinTheVaoLocalStorageScreen({
    super.key,
    CardRepository? repository,
  }) : repository = repository ?? const _DefaultRepositoryHolder().value;

  final CardRepository repository;

  @override
  State<LuuThongTinTheVaoLocalStorageScreen> createState() =>
      _LuuThongTinTheVaoLocalStorageScreenState();
}

class _DefaultRepositoryHolder {
  const _DefaultRepositoryHolder();
  CardRepository get value => CardRepository();
}

class _LuuThongTinTheVaoLocalStorageScreenState
    extends State<LuuThongTinTheVaoLocalStorageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _nicknameController = TextEditingController();

  List<CardModel> _savedCards = [];
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _loading = true);
    final cards = await widget.repository.getAllCards();
    if (!mounted) return;
    setState(() {
      _savedCards = cards;
      _loading = false;
    });
  }

  /// Lưu thông tin thẻ (dữ liệu trích xuất) vào local storage.
  Future<void> _luuThongTinThe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final card = CardModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      cardNumber: _cardNumberController.text.trim(),
      nickname: _nicknameController.text.trim(),
    );

    await widget.repository.insertCard(card);

    _cardNumberController.clear();
    _nicknameController.clear();
    await _loadCards();

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu thông tin thẻ vào local storage')),
    );
  }

  Future<void> _moThemTheMoi() async {
    final added = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(
        builder: (_) =>
            ThemTheMoiVaoDanhSachQuanLyScreen(repository: widget.repository),
      ),
    );
    if (added == true) {
      await _loadCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý thẻ')),
      floatingActionButton: FloatingActionButton(
        onPressed: _moThemTheMoi,
        tooltip: 'Thêm thẻ mới vào danh sách quản lý',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Số thẻ (dữ liệu trích xuất)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Vui lòng nhập số thẻ'
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
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving ? null : _luuThongTinThe,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Lưu vào local storage'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Danh sách thẻ đang quản lý (đọc từ local storage):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _savedCards.isEmpty
                      ? const Center(child: Text('Chưa có thẻ nào được lưu'))
                      : ListView.builder(
                          itemCount: _savedCards.length,
                          itemBuilder: (context, index) {
                            final card = _savedCards[index];
                            return Card(
                              child: ListTile(
                                title: Text(card.nickname),
                                subtitle: Text(card.cardNumber),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    await widget.repository
                                        .deleteCard(card.id);
                                    await _loadCards();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
