import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Obx(
                () => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Login to continue shopping',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),

                // Pill Selector [ Login | Sign Up ]
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.isLoginTab.value = true,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: controller.isLoginTab.value ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: controller.isLoginTab.value
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: controller.isLoginTab.value ? AppColors.primary : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.isLoginTab.value = false,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !controller.isLoginTab.value ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: !controller.isLoginTab.value
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: !controller.isLoginTab.value ? AppColors.primary : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // If Sign Up tab, show Name & Phone field
                if (!controller.isLoginTab.value) ...[
                  TextField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
                      hintText: 'Full Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textMuted),
                      hintText: 'Phone Number',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email / Phone Input
                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted),
                    hintText: controller.isLoginTab.value ? 'Email or Phone' : 'Email Address',
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input
                TextField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => controller.isPasswordVisible.toggle(),
                    ),
                  ),
                ),

                if (controller.isLoginTab.value) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed('/forgot-password');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.referralCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.card_giftcard_outlined, color: AppColors.textMuted),
                      hintText: 'Referral Code (Optional)',
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (controller.isLoginTab.value) {
                              controller.login();
                            } else {
                              controller.register();
                            }
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(controller.isLoginTab.value ? 'Login' : 'Create Account'),
                  ),
                ),
                const SizedBox(height: 30),

                // "or continue with"
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        controller.isLoginTab.value ? 'or sign in with' : 'or sign up with',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: 24),

                // Social Icons: Google, Apple, Phone (OTP login)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialAssetButton(
                      assetPath: 'assets/google_logo.png',
                      size: 26,
                      onTap: () {
                        controller.signInWithGoogle();
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildSocialAssetButton(
                      assetPath: 'assets/apple.png',
                      size: 26,
                      onTap: () {
                        Get.snackbar('Notice', 'Apple Sign-In is configured for iOS devices.');
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      icon: Icons.smartphone,
                      size: 22,
                      onTap: () {
                        Get.toNamed('/forgot-password');
                      },
                    ),
                  ],
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

  Widget _buildSocialAssetButton({required String assetPath, required double size, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.public, size: 24, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required double size, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(icon, size: size, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
