import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';

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

  Future<void> logout() async {
    await StorageService.clearAuth();
    Get.offAllNamed('/login');
  }
}
