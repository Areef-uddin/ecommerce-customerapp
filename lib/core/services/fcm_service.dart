import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../storage/storage_service.dart';

class FcmService {
  static const String defaultToken =
      'AawNgEpbcByvfPlMzCOg5omvdjD10vGI6hZfKhObRJ8IR1UVjQSerNIa93VWMDbw-MLNO2bQahu3Drh0ciCShdp7MP3BSGvm0GQtxcHg_86HslCXdICVJ2p4_foKqVx1lb56FYrR5t1GBa610VjkLPcKRg';

  static void init() {
    final token = StorageService.getFcmToken();
    debugPrint('\n==================== FCM REGISTRATION TOKEN ====================');
    debugPrint('FCM Token: $token');
    debugPrint('Use this token in Firebase Console > Cloud Messaging > Test on device');
    debugPrint('================================================================\n');
  }

  static void showFcmTokenDialog(BuildContext context) {
    final token = StorageService.getFcmToken();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_active, color: Color(0xFFEA580C), size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'FCM Device Token',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Copy this token and paste it in Firebase Console under "Test on device":',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: SelectableText(
                token,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Paste into Firebase modal\n2. Click "+" or press Enter\n3. Click "Test" button',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              Get.snackbar(
                'Copied to Clipboard!',
                'FCM Token copied. Now paste in Firebase Console Test on device.',
                backgroundColor: Colors.black87,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Token'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
