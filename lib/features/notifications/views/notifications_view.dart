import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final controller = Get.isRegistered<NotificationsController>()
      ? Get.find<NotificationsController>()
      : Get.put(NotificationsController());
  String _selectedTab = 'All';

  static const tabs = ['All', 'Orders', 'Offers', 'Updates'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh notifications',
            onPressed: () =>
                controller.refreshNotifications(category: _selectedTab),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.map((tab) {
                  final isSelected = _selectedTab == tab;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTab = tab);
                      controller.refreshNotifications(category: tab);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notifications.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.notifications.isEmpty) {
                return const Center(child: Text('No notifications'));
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    controller.refreshNotifications(category: _selectedTab),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.notifications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = controller.notifications[index];
                    return _notificationCard(notification);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> notification) {
    IconData icon = Icons.notifications_outlined;
    var iconBackground = AppColors.primaryLight;
    var iconColor = AppColors.primary;
    final category = notification['category']?.toString().toLowerCase();
    if (category == 'orders') {
      icon = Icons.shopping_bag_outlined;
    } else if (category == 'offers') {
      icon = Icons.local_offer_outlined;
      iconBackground = const Color(0xFFFEF3C7);
      iconColor = const Color(0xFFD97706);
    } else if (category == 'updates') {
      icon = Icons.campaign_outlined;
      iconBackground = const Color(0xFFEFF6FF);
      iconColor = const Color(0xFF2563EB);
    }

    final isRead = notification['is_read'] == true;
    return InkWell(
      onTap: () => controller.markAsRead(notification),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFFFF8FA),
          border: Border.all(
            color: isRead ? AppColors.border : AppColors.primaryLight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title']?.toString() ?? 'Notification',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification['created_at_formatted']?.toString() ??
                        'Just now',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (notification['can_mark_read'] == true && !isRead)
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 4),
                child: Icon(Icons.circle, size: 8, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
