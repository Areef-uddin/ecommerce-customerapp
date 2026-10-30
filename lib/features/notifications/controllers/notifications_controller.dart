import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';

class NotificationsController extends GetxController {
  final notifications = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    refreshNotifications();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => refreshNotifications(),
    );
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> refreshNotifications({String category = 'All'}) async {
    final token = StorageService.getAccessToken();
    if (token == null || token.isEmpty) {
      notifications.clear();
      unreadCount.value = 0;
      return;
    }

    try {
      isLoading.value = true;
      final query = category == 'All'
          ? ''
          : '?category=${Uri.encodeComponent(category.toLowerCase())}';
      final responses = await Future.wait([
        ApiClient.get('${ApiEndpoints.notifications}$query'),
        ApiClient.get('${ApiEndpoints.notifications}unread_count/'),
      ]);
      final listData = responses[0].data;
      if (listData is List) {
        notifications.assignAll(
          listData.map((item) => Map<String, dynamic>.from(item as Map)),
        );
      }
      final countData = responses[1].data;
      if (countData is Map) {
        unreadCount.value = int.tryParse(countData['count'].toString()) ?? 0;
      }
    } catch (error) {
      debugPrint('Could not refresh notifications: $error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(Map<String, dynamic> notification) async {
    if (notification['is_read'] == true ||
        notification['can_mark_read'] != true) {
      return;
    }
    final id = notification['id'];
    if (id == null) return;

    try {
      await ApiClient.post('${ApiEndpoints.notifications}$id/mark_as_read/');
      final index = notifications.indexWhere((item) => item['id'] == id);
      if (index >= 0) {
        notifications[index] = {...notifications[index], 'is_read': true};
      }
      if (unreadCount.value > 0) unreadCount.value--;
    } catch (error) {
      debugPrint('Could not mark notification as read: $error');
    }
  }
}
