import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/services/web_auth_helper.dart';

class AuthController extends GetxController {
  // Empty inputs without dummy credentials
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // OTP inputs
  final otpDigitControllers = List.generate(6, (_) => TextEditingController());

  final isLoginTab = true.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final otpIdentifier = ''.obs;
  final timerSeconds = 25.obs;
  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    nameController.dispose();
    for (var c in otpDigitControllers) {
      c.dispose();
    }
    super.onClose();
  }

  void startOtpTimer() {
    _timer?.cancel();
    timerSeconds.value = 25;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  String _extractErrorMessage(dynamic error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
        if (data.containsKey('errors') && data['errors'] is Map) {
          final errMap = data['errors'] as Map;
          if (errMap.isNotEmpty) {
            final firstKey = errMap.keys.first;
            final val = errMap[firstKey];
            if (val is List && val.isNotEmpty) return '${val.first}';
            return '$firstKey: $val';
          }
        }
        // Check standard DRF field errors e.g. {"phone": ["..."], "email": ["..."]}
        if (data.isNotEmpty) {
          final firstKey = data.keys.first;
          final val = data[firstKey];
          if (val is List && val.isNotEmpty) return '${val.first}';
          return '$firstKey: $val';
        }
      }
    }
    return fallback;
  }

  Future<void> login() async {
    final input = emailController.text.trim();
    final pwd = passwordController.text;

    if (input.isEmpty || pwd.isEmpty) {
      Get.snackbar('Required', 'Please enter email/phone and password',
          backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      isLoading.value = true;
      final res = await ApiClient.post(ApiEndpoints.login, data: {
        'email_or_phone': input,
        'password': pwd,
      });

      final access = res.data['access'];
      final refresh = res.data['refresh'];
      final user = res.data['user'];

      await StorageService.saveTokens(access: access, refresh: refresh);
      await StorageService.saveUser(user);

      Get.offAllNamed('/home');
    } catch (e) {
      final msg = _extractErrorMessage(e, 'Invalid credentials. Please try again.');
      Get.snackbar('Login Failed', msg,
          backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final pwd = passwordController.text;
    final name = nameController.text.trim();

    if (email.isEmpty || pwd.isEmpty) {
      Get.snackbar('Required', 'Please fill in required fields (Email & Password)',
          backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      isLoading.value = true;
      final res = await ApiClient.post(ApiEndpoints.register, data: {
        'email': email,
        'phone': phone.isNotEmpty ? phone : null,
        'first_name': name.isNotEmpty ? name : email.split('@')[0],
        'password': pwd,
      });

      final access = res.data['access'];
      final refresh = res.data['refresh'];
      final user = res.data['user'];

      await StorageService.saveTokens(access: access, refresh: refresh);
      await StorageService.saveUser(user);

      Get.snackbar('Success', 'Account created successfully!',
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);

      Get.offAllNamed('/home');
    } catch (e) {
      final msg = _extractErrorMessage(e, 'Registration failed. Please check your information.');
      Get.snackbar('Registration Error', msg,
          backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp(String identifier) async {
    try {
      isLoading.value = true;
      otpIdentifier.value = identifier;
      final res = await ApiClient.post(ApiEndpoints.sendOtp, data: {
        'identifier': identifier,
      });

      final code = res.data['code'];
      if (code != null && code.toString().length == 6) {
        String cStr = code.toString();
        for (int i = 0; i < 6; i++) {
          otpDigitControllers[i].text = cStr[i];
        }
      }

      startOtpTimer();
      Get.toNamed('/otp');
    } catch (e) {
      final msg = _extractErrorMessage(e, 'Failed to send OTP code');
      Get.snackbar('Error', msg,
          backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final code = otpDigitControllers.map((c) => c.text).join();
    if (code.length < 6) {
      Get.snackbar('Incomplete', 'Please enter all 6 digits',
          backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      isLoading.value = true;
      final res = await ApiClient.post(ApiEndpoints.verifyOtp, data: {
        'identifier': otpIdentifier.value,
        'code': code,
      });

      final access = res.data['access'];
      final refresh = res.data['refresh'];
      final user = res.data['user'];

      await StorageService.saveTokens(access: access, refresh: refresh);
      await StorageService.saveUser(user);

      Get.offAllNamed('/home');
    } catch (e) {
      final msg = _extractErrorMessage(e, 'Invalid or expired OTP code');
      Get.snackbar('Verification Failed', msg,
          backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle({String? customEmail, String? customName, BuildContext? context}) async {
    try {
      isLoading.value = true;
      String email = customEmail?.trim() ?? '';
      String name = customName?.trim() ?? '';
      String avatar = 'https://lh3.googleusercontent.com/a/default-user';

      if (email.isEmpty) {
        // Trigger real Firebase Google Sign-In popup
        try {
          final googleUser = await triggerFirebaseGoogleSignIn();
          if (googleUser != null && googleUser['email'] != null) {
            email = googleUser['email'].toString().trim();
            name = googleUser['name']?.toString().trim() ?? email.split('@')[0];
            if (googleUser['avatar'] != null && googleUser['avatar'].toString().isNotEmpty) {
              avatar = googleUser['avatar'].toString();
            }
          }
        } catch (fbErr) {
          debugPrint('Firebase Google Sign-In error: $fbErr');
          Get.snackbar(
            'Google Sign-In Alert',
            fbErr.toString(),
            backgroundColor: Colors.amber.shade800,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          if (context != null) {
            promptGoogleSignIn(context);
          }
          return;
        }
      }

      if (email.isEmpty) {
        // No email received (e.g. cancelled by user)
        return;
      }

      final res = await ApiClient.post(ApiEndpoints.google, data: {
        'email': email,
        'name': name.isNotEmpty ? name : email.split('@')[0],
        'avatar': avatar,
      });

      final access = res.data['access'];
      final refresh = res.data['refresh'];
      final user = res.data['user'];

      await StorageService.saveTokens(access: access, refresh: refresh);
      await StorageService.saveUser(user);

      Get.snackbar(
        'Google Sign-In Successful',
        'Welcome, ${user['full_name'] ?? user['email']}!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      Get.offAllNamed('/home');
    } catch (e) {
      final msg = _extractErrorMessage(e, 'Google Sign-In failed');
      Get.snackbar(
        'Authentication Error',
        msg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void promptGoogleSignIn(BuildContext context) {
    final googleEmailCtrl = TextEditingController(
      text: emailController.text.trim(),
    );
    final googleNameCtrl = TextEditingController(
      text: nameController.text.trim(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/google_logo.png', width: 28, height: 28),
                const SizedBox(width: 12),
                const Text(
                  'Sign in with Google Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your Google account email to sign in directly',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: googleEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Google Email Address',
                hintText: 'yourname@gmail.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: googleNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Your Name (Optional)',
                hintText: 'e.g. Alex',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final enteredEmail = googleEmailCtrl.text.trim();
                  if (enteredEmail.isEmpty || !enteredEmail.contains('@')) {
                    Get.snackbar('Invalid Email', 'Please enter a valid Google email address.');
                    return;
                  }
                  Navigator.pop(ctx);
                  signInWithGoogle(
                    customEmail: enteredEmail,
                    customName: googleNameCtrl.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showPhoneLoginSheet(BuildContext context) {
    final phoneInputCtrl = TextEditingController(
      text: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : '+91 ',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.smartphone, color: Color(0xFFE91E63), size: 28),
                SizedBox(width: 12),
                Text(
                  'Phone Verification (OTP)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'We will send a 6-digit verification code to your mobile number',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneInputCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '+91 98765 43210',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final phone = phoneInputCtrl.text.trim();
                  if (phone.isEmpty || phone.length < 8) {
                    Get.snackbar('Invalid', 'Please enter a valid mobile number');
                    return;
                  }
                  Navigator.pop(ctx);
                  sendOtp(phone);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Send Verification Code', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logout() async {
    await StorageService.clearAuth();
    Get.offAllNamed('/login');
  }
}
