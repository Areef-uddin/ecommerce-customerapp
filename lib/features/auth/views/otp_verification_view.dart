import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationView extends StatelessWidget {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAllNamed('/login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Obx(
                () => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Verify Your Number',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the 6-digit code sent to',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.otpIdentifier.value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 36),

                // 6 OTP Box Inputs matching Screen 4
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: controller.otpDigitControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: controller.otpDigitControllers[index].text.isNotEmpty
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          } else if (val.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),

                // Resend Timer & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (controller.timerSeconds.value > 0) ...[
                      Text(
                        'Resend code in ',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      Text(
                        '00:${controller.timerSeconds.value.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ] else ...[
                      TextButton(
                        onPressed: () => controller.sendPhoneOtp(controller.otpIdentifier.value),
                        child: const Text(
                          'Resend Verification Code',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () => controller.verifyOtp(),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Verify'),
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
