import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../product/models/product_model.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/widgets/user_avatar.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, controller),
      body: Obx(() {
        if (controller.isLoading.value && controller.allProducts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchHomeData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // 1. Search Bar & Filter Button
                      _buildSearchBar(context),

                      const SizedBox(height: 14),

                      // 2. Hero Carousel Banner
                      _buildHeroBanner(context, controller),

                      const SizedBox(height: 16),

                      // 3. Trust & Value Badges Row
                      _buildTrustBadges(context),

                      const SizedBox(height: 20),

                      // 4. Shop by Category Header & Circular Items
                      _buildCategorySection(context, controller),

                      const SizedBox(height: 20),

                      // 5. Double Promotional Banners
                      _buildPromoBanners(context),

                      const SizedBox(height: 18),

                      // 6. Filter Chips Row
                      _buildFilterChips(controller),

                      const SizedBox(height: 16),

                      // 7. Product Grid
                      _buildProductGrid(context, controller),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    HomeController controller,
  ) {
    final notifications = Get.put(NotificationsController());
    final profile = Get.put(ProfileController());
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'STYLEHUB',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LUXE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 13,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 2),
              Text(
                'Deliver to Bangalore 560001',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF1E293B),
                size: 24,
              ),
              onPressed: () async {
                await notifications.refreshNotifications();
                Get.toNamed('/notifications');
              },
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Obx(() {
                final count = notifications.unreadCount.value;
                if (count < 1) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () {
            profile.loadLocalUser();
            controller.currentNavIndex.value = 4;
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Obx(
              () => UserAvatar(
                avatar: profile.userAvatar.value,
                name: profile.userName.value,
                radius: 15,
                backgroundColor: const Color(0xFF334155),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        // Search Input Bar
        Expanded(
          child: InkWell(
            onTap: () => Get.toNamed('/products?search=true'),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF64748B),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Search for fashion, sneakers, brands, outfits...',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Pink Filter Button
        InkWell(
          onTap: () => Get.toNamed('/products?filter=true'),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context, HomeController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final bannerHeight = isDesktop ? 260.0 : 190.0;

    return Container(
      width: double.infinity,
      height: bannerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1200',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFFFCE4EC)),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.72),
                    Colors.black.withOpacity(0.40),
                    Colors.black.withOpacity(0.10),
                  ],
                ),
              ),
            ),
            // Left Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 18,
                vertical: isDesktop ? 24 : 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'NEW COLLECTION',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trendy Looks\nfor Every You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 32 : 23,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Fashion • Sneakers • Accessories',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/products?category=women'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Shop Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right "UP TO 50% OFF" Circular Badge
            Positioned(
              right: isDesktop ? 40 : 16,
              top: isDesktop ? 30 : 16,
              child: Container(
                width: isDesktop ? 96 : 72,
                height: isDesktop ? 96 : 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE91E63).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'UP TO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '50%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 24 : 19,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    const Text(
                      'OFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-Right Carousel Dot Indicators
            Positioned(
              right: 18,
              bottom: 12,
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 10,
                    height: 5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 10,
                    height: 5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 10,
                    height: 5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadges(BuildContext context) {
    final badges = [
      {'icon': Icons.local_shipping_outlined, 'title': 'Free\nShipping'},
      {'icon': Icons.verified_outlined, 'title': 'Easy\nReturns'},
      {'icon': Icons.shield_outlined, 'title': '100%\nAuthentic'},
      {'icon': Icons.discount_outlined, 'title': 'Exclusive\nDeals'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: badges.map((b) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2F4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCE7EA), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        b['icon'] as IconData,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        b['title'] as String,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    HomeController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Shop by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            InkWell(
              onTap: () => controller.currentNavIndex.value = 1,
              child: const Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Circular Categories Horizontal List
        SizedBox(
          height: 98,
          child: Obx(() {
            final list = controller.categories;
            if (list.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final cat = list[index];
                return InkWell(
                  onTap: () => Get.toNamed(
                    '/category?slug=${cat.slug}&name=${cat.name}',
                  ),
                  borderRadius: BorderRadius.circular(35),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(cat.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPromoBanners(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 480;

    return Row(
      children: [
        // 1. Festive Fashion Sale (Pink)
        Expanded(
          child: Container(
            height: isCompact ? 130 : 145,
            padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFDE8EE), Color(0xFFFBCFE8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Right photo
                Positioned(
                  right: -10,
                  bottom: -12,
                  top: -6,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=400',
                    fit: BoxFit.cover,
                    width: isCompact ? 90 : 110,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
                // Left text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Festive\nFashion Sale',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'MIN 40% - 70% OFF',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => Get.toNamed('/products?category=women'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Shop Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Premium Sneakers (Ice Blue)
        Expanded(
          child: Container(
            height: isCompact ? 130 : 145,
            padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Right photo
                Positioned(
                  right: -10,
                  bottom: 0,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400',
                    fit: BoxFit.contain,
                    width: isCompact ? 90 : 110,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
                // Left text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Premium\nSneakers',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'New Arrivals',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => Get.toNamed('/products?category=footwear'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Shop Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(HomeController controller) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = controller.chips[index];
          return Obx(() {
            final isSelected = controller.selectedChip.value == chip;
            return InkWell(
              onTap: () => controller.selectChip(chip),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    chip,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, HomeController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive columns:
        // Mobile: 2
        // Tablet: 3
        // Desktop: 4
        // Ultra-wide: 5
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1100) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth > 850) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 580) {
          crossAxisCount = 3;
        }

        return Obx(() {
          final products = controller.trendingProducts;
          if (products.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No products available.'),
              ),
            );
          }

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(context, product, controller);
            },
          );
        });
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    HomeController controller,
  ) {
    final origPrice = product.originalPrice;
    int discount = 0;
    if (origPrice != null && origPrice > product.price) {
      discount =
          (((product.originalPrice! - product.price) / product.originalPrice!) *
                  100)
              .round();
    }

    return GestureDetector(
      onTap: () => Get.toNamed('/product-detail', arguments: product.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Discount Badge & Heart Button
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.primaryImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFFCE4EC),
                        child: const Center(
                          child: Icon(Icons.image_outlined, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                  // Pink Discount Badge
                  if (discount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$discount% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                  // Circular Heart / Wishlist Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => controller.toggleWishlist(product),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          product.isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: product.isWishlisted
                              ? AppColors.primary
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Category uppercase label (e.g. WOMEN, FOOTWEAR, MEN, ACCESSORIES)
            Text(
              (product.categoryName.isNotEmpty
                      ? product.categoryName
                      : 'FASHION')
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),

            // Product Name
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 3),

            // Price & Original Strikethrough Price
            Row(
              children: [
                Text(
                  '₹${product.price.toInt()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (origPrice != null && origPrice > product.price) ...[
                  const SizedBox(width: 6),
                  Text(
                    '₹${origPrice.toInt()}',
                    style: const TextStyle(
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),

            // Rating Star & Number
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 3),
                Text(
                  '${product.rating}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
