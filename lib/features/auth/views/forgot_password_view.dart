import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Header
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.lock_reset, size: 34, color: AppColors.primary),
              ),
              const SizedBox(height: 24),

              const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your mobile number. A real Firebase SMS verification code (OTP) will be dispatched directly to your device.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 32),

              // Phone Number Input
              const Text(
                'Mobile Number',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.5),
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_android, color: AppColors.primary, size: 22),
                        SizedBox(width: 8),
                        Text(
                          '+91',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          height: 20,
                          child: VerticalDivider(color: Color(0xFFE5E7EB), thickness: 1.5),
                        ),
                      ],
                    ),
                  ),
                  hintText: '98765 43210',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 32),

              // Send Verification Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            final raw = _phoneCtrl.text.trim();
                            if (raw.isEmpty || raw.length < 10) {
                              Get.snackbar(
                                'Invalid Mobile',
                                'Please enter a valid 10-digit mobile number.',
                                backgroundColor: Colors.amber.shade800,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            final fullNumber = raw.startsWith('+') ? raw : '+91$raw';
                            controller.sendPhoneOtp(fullNumber);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Send Verification Code (OTP)',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Back to Login link
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Remember password? Back to Login',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
