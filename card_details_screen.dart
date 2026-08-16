// ===================================================================
// FILE: card_details_screen.dart
// PHỤ TRÁCH: NGUYỄN LÊ CHÍ KHẢI
// ===================================================================

import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../theme/app_theme.dart';

class CardDetailsScreen extends StatefulWidget {
  final CardModel card;

  const CardDetailsScreen({super.key, required this.card});

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  bool _isFrozen = false;
  bool _isOnlineEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ hiển thị trực quan phía trên
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F52BA), Color(0xFF2196F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'CORPORATE DEBIT',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.contactless, color: Colors.white),
                    ],
                  ),
                  Text(
                    '•••• •••• •••• ${widget.card.last4Digits}',
                    style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Card Holder', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text(widget.card.cardHolderName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Expires', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text(widget.card.expiryDate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Thông tin chi tiết thẻ
            const Text('Card Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildInfoRow('Status', widget.card.isActive ? 'Active' : 'Inactive', isStatus: true),
                  const Divider(height: 24),
                  _buildInfoRow('Daily Limit', '\$5,000.00'),
                  const Divider(height: 24),
                  _buildInfoRow('Billing Address', '123 Corporate Blvd\nSuite 400', isMultiLine: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Phần Security & Controls (Mới thêm)
            const Text('Security & Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_outline, color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: Text('Freeze Card', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
                      Switch(
                        value: _isFrozen,
                        onChanged: (val) => setState(() => _isFrozen = val),
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.language, color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: Text('Online Transactions', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
                      Switch(
                        value: _isOnlineEnabled,
                        onChanged: (val) => setState(() => _isOnlineEnabled = val),
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Phần Recent Activity (Mới thêm)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: const Text('VIEW ALL', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildActivityItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Apple Store',
                    subtitle: 'Today, 2:45 PM',
                    amount: '-\$249.00',
                  ),
                  const Divider(height: 24),
                  _buildActivityItem(
                    icon: Icons.restaurant,
                    title: 'Sweetgreen',
                    subtitle: 'Yesterday, 1:15 PM',
                    amount: '-\$18.50',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false, bool isMultiLine = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        isStatus
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        )
            : Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildActivityItem({required IconData icon, required String title, required String subtitle, required String amount}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Completed', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ],
    );
  }
}