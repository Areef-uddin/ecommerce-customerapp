import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/referral_model.dart';

class ReferralController extends GetxController {
  final stats = Rxn<ReferralStatsModel>();
  final referralsList = <ReferralItemModel>[].obs;
  final isLoadingStats = false.obs;
  final isLoadingReferrals = false.obs;
  final isApplyingCode = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      isLoadingStats.value = true;
      final res = await ApiClient.get(ApiEndpoints.referralMyStats);
      if (res.data != null && res.data is Map) {
        stats.value = ReferralStatsModel.fromJson(res.data);
      }
    } catch (e) {
      debugPrint('[ReferralController] fetchStats error: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> fetchReferralsList() async {
    try {
      isLoadingReferrals.value = true;
      final res = await ApiClient.get(ApiEndpoints.referralMyReferrals);
      if (res.data != null) {
        final List items = res.data is Map && res.data['results'] is List
            ? res.data['results']
            : (res.data is List ? res.data : []);
        referralsList.assignAll(items.map((i) => ReferralItemModel.fromJson(i)).toList());
      }
    } catch (e) {
      debugPrint('[ReferralController] fetchReferralsList error: $e');
    } finally {
      isLoadingReferrals.value = false;
    }
  }

  String getActiveReferralCode() {
    String code = stats.value?.referralCode ?? '';
    if (code.isNotEmpty && code != '---') return code;

    // Check stored user data
    final user = StorageService.getUser();
    if (user != null && user['referral_code'] != null && user['referral_code'].toString().isNotEmpty) {
      return user['referral_code'].toString();
    }
    return '';
  }

  String getCustomerAppReferralLink([String? explicitCode]) {
    final code = (explicitCode != null && explicitCode.isNotEmpty) ? explicitCode : getActiveReferralCode();
    if (code.isEmpty) return '';

    try {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty &&
          !origin.contains('localhost') &&
          !origin.contains('127.0.0.1') &&
          !origin.contains(':8000') &&
          !origin.contains('onrender.com')) {
        return '$origin/register?ref=$code';
      }
    } catch (_) {}

    String link = stats.value?.referralLink ?? '';
    if (link.isEmpty || link.contains('onrender.com') || link.contains('vercel.app') || link.contains(':8000')) {
      link = 'http://157.15.203.209/register?ref=$code';
    }
    return link;
  }

  void copyReferralCode() {
    final code = getActiveReferralCode();
    if (code.isEmpty) {
      Get.snackbar(
        'Login Required',
        'Please login to view and copy your referral code.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE11D48),
        colorText: Colors.white,
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'Copied to Clipboard',
      'Referral code $code copied successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void copyReferralLink() {
    final link = getCustomerAppReferralLink();
    if (link.isEmpty) return;
    Clipboard.setData(ClipboardData(text: link));
    Get.snackbar(
      'Copied Link',
      'Referral link copied to clipboard!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<void> shareOnWhatsApp() async {
    // 1. Prompt login if user is not authenticated
    if (!StorageService.isLoggedIn) {
      Get.snackbar(
        'Login Required',
        'Please login or create an account to share your unique referral link & earn rewards!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE11D48),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      Get.toNamed('/login');
      return;
    }

    // 2. Retrieve referral code from stats or cached user profile
    String code = getActiveReferralCode();
    if (code.isEmpty) {
      Get.snackbar(
        'Generating Link...',
        'Retrieving your referral code, please wait a moment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
      await fetchStats();
      code = getActiveReferralCode();
    }

    if (code.isEmpty) {
      Get.snackbar(
        'Referral Notice',
        'Could not load your referral code. Please pull to refresh or check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE11D48),
        colorText: Colors.white,
      );
      return;
    }

    final link = getCustomerAppReferralLink(code);

    final message = "Hey! I'm using this awesome shopping app. Join using my referral link and enjoy the experience!\n\n"
        "My Referral Code: $code\n"
        "Join here: $link";

    final encoded = Uri.encodeComponent(message);
    final waUri = Uri.parse("https://wa.me/?text=$encoded");
    final appUri = Uri.parse("whatsapp://send?text=$encoded");

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(waUri)) {
        await launchUrl(waUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: copy to clipboard
        copyReferralCode();
        Get.snackbar(
          'WhatsApp Notice',
          'WhatsApp is not installed. Referral message copied to clipboard.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0F172A),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('[ReferralController] WhatsApp launch error: $e');
      copyReferralCode();
    }
  }

  Future<bool> applyReferralCode(String code) async {
    if (code.trim().isEmpty) {
      Get.snackbar('Input Error', 'Please enter a referral code.');
      return false;
    }
    try {
      isApplyingCode.value = true;
      final res = await ApiClient.post(
        ApiEndpoints.referralApply,
        data: {'code': code.trim().toUpperCase()},
      );
      if (res.statusCode == 201 || res.data?['success'] == true) {
        Get.snackbar(
          'Success!',
          res.data?['detail'] ?? 'Referral code applied successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        fetchStats();
        return true;
      }
      return false;
    } catch (e) {
      String err = 'Failed to apply referral code.';
      if (e is DioException && e.response?.data != null) {
        final d = e.response!.data;
        if (d is Map) {
          err = d['detail']?.toString() ?? (d['code'] is List ? d['code'][0].toString() : err);
        }
      }
      Get.snackbar(
        'Referral Error',
        err,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isApplyingCode.value = false;
    }
  }
}
