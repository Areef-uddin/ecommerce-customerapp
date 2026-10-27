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
      body: Obx(() => pages[controller.currentNavIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentNavIndex.value,
            onTap: (index) {
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
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.grid_view),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Categories',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Wishlist',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_bag_outlined),
                    if (controller.cartItemCount.value > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: const Icon(Icons.shopping_bag),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
