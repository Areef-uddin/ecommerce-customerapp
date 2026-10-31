import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/home_controller.dart';
import 'home_view.dart';
import '../../category/views/category_view.dart';
import '../../wishlist/views/wishlist_view.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../../cart/views/cart_view.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../profile/views/profile_view.dart';

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    final List<Widget> pages = [
      const HomeView(),
      const CategoryView(),
      const WishlistView(),
      const CartView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: Obx(() => pages[controller.currentNavIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                offset: const Offset(0, -2),
                blurRadius: 10,
              ),
            ],
            border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8)),
          ),
          child: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.home_rounded,
                        inactiveIcon: Icons.home_outlined,
                        label: 'Home',
                        controller: controller,
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.grid_view_rounded,
                        inactiveIcon: Icons.grid_view_outlined,
                        label: 'Categories',
                        controller: controller,
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.favorite_rounded,
                        inactiveIcon: Icons.favorite_border_rounded,
                        label: 'Wishlist',
                        controller: controller,
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.shopping_bag_rounded,
                        inactiveIcon: Icons.shopping_bag_outlined,
                        label: 'Cart',
                        badgeCount: Get.isRegistered<CartController>() ? Get.find<CartController>().totalQuantity : 0,
                        controller: controller,
                      ),
                      _buildNavItem(
                        index: 4,
                        icon: Icons.person_rounded,
                        inactiveIcon: Icons.person_outline_rounded,
                        label: 'Profile',
                        controller: controller,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData inactiveIcon,
    required String label,
    required HomeController controller,
    int? badgeCount,
  }) {
    final isSelected = controller.currentNavIndex.value == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          controller.currentNavIndex.value = index;
          if (index == 2) {
            if (Get.isRegistered<WishlistController>()) {
              Get.find<WishlistController>().fetchWishlist();
            }
          } else if (index == 3) {
            if (Get.isRegistered<CartController>()) {
              Get.find<CartController>().fetchCart();
            }
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? icon : inactiveIcon,
                  size: 24,
                  color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppColors.primary : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 3),
            // Pink underline indicator for active tab
            Container(
              height: 2.5,
              width: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
