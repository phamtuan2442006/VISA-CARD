// ===================================================================
// FILE: transaction_history_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// TASK GỐC (15-16/08/2026): "Dựng giao diện Lịch sử giao dịch đầy đủ"
// MÔ TẢ: Hiển thị toàn bộ giao dịch (không chỉ vài giao dịch gần đây như
// Home Dashboard), có bộ lọc All/Successful/Failed, dữ liệu lấy từ
// TransactionRepository (Huỳnh Phúc Điền).
// ===================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../services/transaction_repository.dart';
import '../theme/app_theme.dart';

enum _FilterType { all, success, failed }

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  _FilterType _filter = _FilterType.all;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionRepository>();
    final all = repo.transactions;
    final total = all.length;
    final successCount = repo.successfulTransactions.length;
    final failedCount = repo.failedTransactions.length;

    List<TransactionModel> filtered;
    switch (_filter) {
      case _FilterType.success:
        filtered = repo.successfulTransactions;
        break;
      case _FilterType.failed:
        filtered = repo.failedTransactions;
        break;
      default:
        filtered = all;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statColumn('Total Transactions', '$total', AppColors.textPrimary),
                    _statColumn('Successful', '$successCount', AppColors.success),
                    _statColumn('Failed', '$failedCount', AppColors.danger),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterChip('All', _FilterType.all),
                const SizedBox(width: 8),
                _filterChip('Successful', _FilterType.success),
                const SizedBox(width: 8),
                _filterChip('Failed', _FilterType.failed),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Chưa có giao dịch nào'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _buildTile(filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _filterChip(String label, _FilterType type) {
    final selected = _filter == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primaryBlue,
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
      onSelected: (_) => setState(() => _filter = type),
    );
  }

  Widget _buildTile(TransactionModel t) {
    final isSuccess = t.status == TransactionStatus.success;
    final df = DateFormat('dd/MM • HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isSuccess ? AppColors.success : AppColors.danger).withOpacity(0.1),
          child: Icon(
            isSuccess ? Icons.check : Icons.close,
            color: isSuccess ? AppColors.success : AppColors.danger,
          ),
        ),
        title: Text(t.merchantName),
        subtitle: Text(df.format(t.date)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '-\$${t.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSuccess ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            Text(
              isSuccess ? 'Success' : 'Failed',
              style: TextStyle(
                fontSize: 11,
                color: isSuccess ? AppColors.success : AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
