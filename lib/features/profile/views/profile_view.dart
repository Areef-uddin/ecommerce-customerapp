import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../widgets/user_avatar.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Widget _buildAvatarWidget(ProfileController controller, double radius) {
    return Obx(() {
      return UserAvatar(
        avatar: controller.userAvatar.value,
        name: controller.userName.value,
        radius: radius,
      );
    });
  }

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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
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
                              // Dynamic Profile Image with Camera Upload Badge
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showAvatarOptionsSheet(
                                      context,
                                      controller,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFD700),
                                            Color(0xFFFFA000),
                                          ],
                                        ),
                                      ),
                                      child: _buildAvatarWidget(controller, 32),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: GestureDetector(
                                      onTap: () => _showAvatarOptionsSheet(
                                        context,
                                        controller,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Dynamic Name, Email, and Phone
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            controller.userName.value.isNotEmpty
                                                ? controller.userName.value
                                                : 'VIP Member',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFD700)
                                                .withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFFFD700),
                                              width: 0.8,
                                            ),
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
                                      'Exclusive StyleHub Privilege Member',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFF334155), height: 1),
                          const SizedBox(height: 16),

                          // Quick Actions Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Orders',
                                'Track',
                                Icons.local_shipping_outlined,
                                () => Get.toNamed('/my-orders'),
                              ),
                              _buildStatItem(
                                'Wishlist',
                                'Saved',
                                Icons.favorite_border,
                                () => Get.toNamed('/wishlist'),
                              ),
                              _buildStatItem(
                                'Addresses',
                                'Saved',
                                Icons.place_outlined,
                                () => Get.toNamed('/checkout-address'),
                              ),
                              _buildStatItem(
                                'Edit Profile',
                                'Update',
                                Icons.edit_note_rounded,
                                () =>
                                    _showEditProfileSheet(context, controller),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Dynamic Personal Information Card with Edit Button
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'PERSONAL INFORMATION',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    _showEditProfileSheet(context, controller),
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            icon: Icons.person_outline,
                            label: 'Full Name',
                            value: controller.userName.value.isNotEmpty
                                ? controller.userName.value
                                : 'Not provided',
                          ),
                          const Divider(height: 20, color: Color(0xFFF3F4F6)),
                          _buildDetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email Address',
                            value: controller.userEmail.value.isNotEmpty
                                ? controller.userEmail.value
                                : 'Not provided',
                          ),
                          const Divider(height: 20, color: Color(0xFFF3F4F6)),
                          _buildDetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Mobile Number',
                            value: controller.userPhone.value.isNotEmpty
                                ? controller.userPhone.value
                                : 'Not provided',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Orders & Shopping Section
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
                        const Divider(
                          height: 1,
                          indent: 56,
                          color: Color(0xFFF3F4F6),
                        ),
                        _buildMenuTile(
                          icon: Icons.favorite_border,
                          iconColor: const Color(0xFFE91E63),
                          title: 'My Saved Wishlist',
                          subtitle: 'Your curated luxury boutique pieces',
                          onTap: () => Get.toNamed('/wishlist'),
                        ),
                        const Divider(
                          height: 1,
                          indent: 56,
                          color: Color(0xFFF3F4F6),
                        ),
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

                  // 4. Flagship Store & Customer Care
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'StyleHub Flagship & Care',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.phone_outlined,
                                size: 18,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '+91 98765 43210',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Mon - Sat: 09:00 AM - 08:00 PM',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.email_outlined,
                                size: 18,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'concierge@stylehub.com',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'VIP Priority Support',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '100 Feet Rd, Indiranagar, Bengaluru',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Open today: 10:00 AM - 10:00 PM',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Logout Card
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
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF334155)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
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
          color: isDestructive
              ? const Color(0xFFEF4444)
              : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.textMuted,
      ),
    );
  }

  // --- Dynamic Edit & Avatar Modals ---

  void _showEditProfileSheet(
    BuildContext context,
    ProfileController controller,
  ) {
    // Dynamically populate text controllers from current values
    controller.nameCtrl.text = controller.userName.value;
    controller.emailCtrl.text = controller.userEmail.value;
    controller.phoneCtrl.text = controller.userPhone.value;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profile Information',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Full Name
              const Text(
                'Full Name',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller.nameCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  hintText: 'Enter your name',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Email Address
              const Text(
                'Email Address',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller.emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  hintText: 'Enter email address',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Mobile Number
              const Text(
                'Mobile Number',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller.phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  hintText: 'Enter mobile number (e.g. +91 7386872991)',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Changes Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isUpdating.value
                        ? null
                        : () async {
                            await controller.updateProfile();
                            Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isUpdating.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAvatarOptionsSheet(
    BuildContext context,
    ProfileController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Option: Upload from Device
            ListTile(
              onTap: () async {
                Get.back();
                await controller.pickAndUploadAvatar();
              },
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text(
                'Upload Photo from Device',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              subtitle: const Text(
                'Pick any image file (PNG, JPG, WebP) from your device gallery or files',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textMuted,
              ),
            ),

            if (controller.userAvatar.value.isNotEmpty) ...[
              const Divider(height: 12),
              ListTile(
                onTap: () async {
                  Get.back();
                  await controller.removeAvatar();
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEF4444),
                  ),
                ),
                title: const Text(
                  'Remove Current Photo',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFFEF4444),
                  ),
                ),
                subtitle: const Text(
                  'Reset to default dynamic monogram avatar',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
