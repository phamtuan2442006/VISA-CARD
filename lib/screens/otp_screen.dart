// ===================================================================
// FILE: otp_screen.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// CẬP NHẬT: Khởi tạo trực tiếp _generatedOtp để tránh lỗi LateInitializationError,
// kèm theo cuộn màn hình chống tràn khi hiện bàn phím.
// ===================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _digitControllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _resendTimer;
  int _secondsLeft = 60;
  String? _errorText;

  // Khởi tạo trực tiếp mã OTP ngẫu nhiên 4 số ngay tại đây để không bao giờ bị lỗi uninitialized
  String _generatedOtp = (1000 + Random().nextInt(9000)).toString();

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  // Hàm tạo mã OTP ngẫu nhiên mới khi bấm gửi lại
  void _generateNewOtp() {
    setState(() {
      _generatedOtp = (1000 + Random().nextInt(9000)).toString();
      _secondsLeft = 60;
      _errorText = null;
    });
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _digitControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _maskedPhone {
    final p = widget.phoneNumber;
    if (p.length < 3) return p;
    return '0${p.substring(0, 2)}${'*' * (p.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(18),
),
                        child: const Icon(Icons.nfc, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 16),
                      const Text('NFC Card Reader',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      const SizedBox(height: 28),
                      const Text('Enter the confirmation code',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        'Please enter the OTP code sent to your phone number.\nDial $_maskedPhone to login in.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 16),

                      // KHUNG HIỂN THỊ MÃ OTP NGẪU NHIÊN TRỰC TIẾP
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_clock, color: AppColors.primaryBlue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Mã OTP của bạn: $_generatedOtp',
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (i) => _buildOtpBox(i)),
                      ),
                      if (_errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(_errorText!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                      ],
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: _secondsLeft == 0 ? _generateNewOtp : null,
                        child: Text(
_secondsLeft == 0
                              ? 'Resend OTP'
                              : 'Resend OTP (${_secondsLeft}s)',
                          style: TextStyle(
                            color: _secondsLeft == 0 ? AppColors.primaryBlue : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('The OTP expires after 5:00',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _verifyOtp,
                              child: const Text('Confirm'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      height: 52,
      child: TextField(
        controller: _digitControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: '',
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.divider, width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.divider, width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  void _verifyOtp() {
    final code = _digitControllers.map((c) => c.text).join();

    if (code == _generatedOtp) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _errorText = 'Mã OTP không đúng, vui lòng nhập mã: $_generatedOtp');
    }
  }
}