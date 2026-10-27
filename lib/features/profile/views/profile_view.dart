import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/fcm_service.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Account & VIP Lounge',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: 'Refresh Profile',
            onPressed: () => controller.fetchProfile(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => controller.fetchProfile(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Luxury VIP Member Card
              Obx(
                () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(controller.userAvatar.value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.userName.value,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
                                      ),
                                      child: const Text(
                                        'VIP GOLD',
                                        style: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.userEmail.value.isNotEmpty
                                      ? controller.userEmail.value
                                      : 'Real Firebase Verified Account',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFF334155), height: 1),
                      const SizedBox(height: 16),

                      // Quick Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Orders', 'Track', Icons.local_shipping_outlined, () => Get.toNamed('/my-orders')),
                          _buildStatItem('Wishlist', 'Saved', Icons.favorite_border, () => Get.toNamed('/wishlist')),
                          _buildStatItem('Addresses', 'Saved', Icons.place_outlined, () => Get.toNamed('/checkout-address')),
                          _buildStatItem('FCM Token', 'Copy', Icons.key_outlined, () => FcmService.showFcmTokenDialog(context)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Orders & Shopping Section
              const Text(
                'SHOPPING & ORDERS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Column(
                  children: [
                    _buildMenuTile(
                      icon: Icons.inventory_2_outlined,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'My Orders & Order History',
                      subtitle: 'Track current shipments and view invoices',
                      onTap: () => Get.toNamed('/my-orders'),
                    ),
                    const Divider(height: 1, indent: 56, color: Color(0xFFF3F4F6)),
                    _buildMenuTile(
                      icon: Icons.favorite_border,
                      iconColor: const Color(0xFFE91E63),
                      title: 'My Saved Wishlist',
                      subtitle: 'Your curated luxury boutique pieces',
                      onTap: () => Get.toNamed('/wishlist'),
                    ),
                    const Divider(height: 1, indent: 56, color: Color(0xFFF3F4F6)),
                    _buildMenuTile(
                      icon: Icons.location_on_outlined,
                      iconColor: const Color(0xFF10B981),
                      title: 'Delivery Addresses',
                      subtitle: 'Manage home, office and saved locations',
                      onTap: () => Get.toNamed('/checkout-address'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Firebase & Security Section
              const Text(
                'FIREBASE & CLOUD INTEGRATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Column(
                  children: [
                    _buildMenuTile(
                      icon: Icons.notifications_active_outlined,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Firebase FCM Push Token',
                      subtitle: '1-tap copy token for Firebase Console device testing',
                      onTap: () => FcmService.showFcmTokenDialog(context),
                    ),
                    const Divider(height: 1, indent: 56, color: Color(0xFFF3F4F6)),
                    _buildMenuTile(
                      icon: Icons.verified_user_outlined,
                      iconColor: const Color(0xFF6366F1),
                      title: 'Authentication & Security',
                      subtitle: 'Real Firebase Google Sign-In & OTP verification',
                      onTap: () {
                        Get.snackbar(
                          'Security Status',
                          'Your account is secured with NeonDB PostgreSQL and Firebase Authentication.',
                          backgroundColor: const Color(0xFF10B981),
                          colorText: Colors.white,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Logout Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: _buildMenuTile(
                  icon: Icons.logout,
                  iconColor: const Color(0xFFEF4444),
                  title: 'Sign Out',
                  subtitle: 'Safely log out of this device',
                  isDestructive: true,
                  onTap: () {
                    Get.defaultDialog(
                      title: 'Sign Out',
                      middleText: 'Are you sure you want to sign out of your account?',
                      textConfirm: 'Sign Out',
                      textCancel: 'Cancel',
                      confirmTextColor: Colors.white,
                      buttonColor: const Color(0xFFEF4444),
                      onConfirm: () {
                        Get.back();
                        controller.logout();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: isDestructive ? const Color(0xFFEF4444) : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
    );
  }
}
