import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/web_auth_helper.dart';
import '../../../core/storage/storage_service.dart';

class ProfileController extends GetxController {
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userAvatar = ''.obs;
  final userPhone = ''.obs;
  final isUpdating = false.obs;

  // Editing Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadLocalUser();
    fetchProfile();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }

  void loadLocalUser() {
    final user = StorageService.getUser();
    if (user != null) {
      _applyUserData(user);
    }
  }

  void _applyUserData(Map<String, dynamic> d) {
    final name =
        (d['full_name'] != null && d['full_name'].toString().trim().isNotEmpty)
        ? d['full_name'].toString().trim()
        : (d['first_name'] != null &&
              d['first_name'].toString().trim().isNotEmpty)
        ? '${d['first_name']} ${d['last_name'] ?? ''}'.trim()
        : (d['email'] != null && d['email'].toString().isNotEmpty)
        ? d['email'].toString().split('@')[0]
        : '';

    userName.value = name;
    userEmail.value = d['email'] != null ? d['email'].toString() : '';
    userPhone.value = d['phone'] != null ? d['phone'].toString() : '';

    if (d['avatar'] != null && d['avatar'].toString().trim().isNotEmpty) {
      userAvatar.value = d['avatar'].toString().trim();
    }

    _syncControllers();
  }

  void _syncControllers() {
    nameCtrl.text = userName.value;
    emailCtrl.text = userEmail.value;
    phoneCtrl.text = userPhone.value;
  }

  Future<void> fetchProfile() async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null || token.isEmpty) return;

      final res = await ApiClient.get(ApiEndpoints.profile);
      if (res.data is Map<String, dynamic>) {
        final d = res.data as Map<String, dynamic>;
        _applyUserData(d);
        await StorageService.saveUser(d);
      } else if (res.data is Map) {
        final d = Map<String, dynamic>.from(res.data);
        _applyUserData(d);
        await StorageService.saveUser(d);
      }
    } catch (e) {
      debugPrint('Profile dynamic fetch: $e');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      isUpdating.value = true;
      final payload = <String, dynamic>{};

      final newName = name ?? nameCtrl.text.trim();
      final newEmail = email ?? emailCtrl.text.trim();
      final newPhone = phone ?? phoneCtrl.text.trim();

      if (newName.isNotEmpty) payload['full_name'] = newName;
      if (newEmail.isNotEmpty) payload['email'] = newEmail;
      if (newPhone.isNotEmpty) payload['phone'] = newPhone;
      if (avatar != null) payload['avatar'] = avatar;

      final res = await ApiClient.patch(ApiEndpoints.profile, data: payload);
      if (res.data is Map) {
        final d = Map<String, dynamic>.from(res.data);
        _applyUserData(d);
        await StorageService.saveUser(d);

        Get.snackbar(
          'Profile Updated',
          'Your profile information has been saved successfully in the database.',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      }
    } catch (e) {
      debugPrint('Profile update error: $e');
      Get.snackbar(
        'Update Notice',
        'Profile updated locally.',
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      if (name != null || nameCtrl.text.isNotEmpty) {
        userName.value = name ?? nameCtrl.text;
      }
      if (email != null || emailCtrl.text.isNotEmpty) {
        userEmail.value = email ?? emailCtrl.text;
      }
      if (phone != null || phoneCtrl.text.isNotEmpty) {
        userPhone.value = phone ?? phoneCtrl.text;
      }
      if (avatar != null) userAvatar.value = avatar;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> pickAndUploadAvatar() async {
    try {
      final base64Image = await pickImageAsBase64();
      if (base64Image != null && base64Image.isNotEmpty) {
        userAvatar.value = base64Image;
        Get.snackbar(
          'Uploading Photo',
          'Saving your profile image to server...',
          backgroundColor: const Color(0xFF3B82F6),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
        await updateProfile(avatar: base64Image);
      }
    } catch (e) {
      debugPrint('Error picking avatar: $e');
      Get.snackbar(
        'Upload Failed',
        'Could not select or upload image: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }

  Future<void> removeAvatar() async {
    userAvatar.value = '';
    await updateProfile(avatar: '');
  }

  Future<void> logout() async {
    await StorageService.clearAuth();
    Get.offAllNamed('/login');
  }
}
