import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    final menuItems = [
      {'title': 'My Orders', 'icon': Icons.shopping_bag_outlined, 'route': '/my-orders'},
      {'title': 'My Addresses', 'icon': Icons.location_on_outlined, 'route': '/checkout-address'},
      {'title': 'Payment Methods', 'icon': Icons.credit_card_outlined, 'route': '/checkout-payment'},
      {'title': 'My Wishlist', 'icon': Icons.favorite_border, 'route': '/wishlist'},
      {'title': 'My Reviews', 'icon': Icons.star_border, 'route': null},
      {'title': 'Notifications', 'icon': Icons.notifications_none, 'route': '/notifications'},
      {'title': 'Settings', 'icon': Icons.settings_outlined, 'route': null},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Account', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // User Header Profile Card matching Screen 19
            Obx(
              () => Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(controller.userAvatar.value),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.userName.value,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.userEmail.value,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 10),

            // Profile Menu List matching Screen 19
            ...menuItems.map((item) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: Icon(item['icon'] as IconData, color: AppColors.textPrimary, size: 22),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                onTap: () {
                  final route = item['route'] as String?;
                  if (route != null) {
                    Get.toNamed(route);
                  }
                },
              );
            }),

            // Logout Option
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              leading: const Icon(Icons.logout, color: AppColors.error, size: 22),
              title: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.error),
              ),
              onTap: () => controller.logout(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
