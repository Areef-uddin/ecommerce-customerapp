import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import 'size_guide_sheet.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final controller = Get.put(ProductController());
  final cartController = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController());
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final int productId = Get.arguments as int? ?? 1;
    controller.fetchProductDetail(productId);
    cartController.fetchCart();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final product = controller.currentProduct.value;
        if (product == null) {
          return Center(
            child: Text(
              'Product not found',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          );
        }

        final displayImages = product.images.isNotEmpty
            ? (product.images.length >= 5
                ? product.images.take(5).toList()
                : [
                    ...product.images,
                    ...List.generate(5 - product.images.length, (i) => product.images[i % product.images.length])
                  ])
            : [
                'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=800',
                'https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=800',
                'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800',
                'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
                'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
              ];

        final availableSizes = product.sizes.isNotEmpty ? product.sizes : ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

        final fashionColors = [
          {'name': 'Yellow', 'color': const Color(0xFFFACC15)},
          {'name': 'Black', 'color': const Color(0xFF1E293B)},
          {'name': 'Pink', 'color': const Color(0xFFF472B6)},
          {'name': 'Grey', 'color': const Color(0xFF94A3B8)},
          {'name': 'Lavender', 'color': const Color(0xFFC084FC)},
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            if (isDesktop) {
              return _buildDesktopLayout(product, displayImages, availableSizes, fashionColors);
            }
            return _buildMobileLayout(product, displayImages, availableSizes, fashionColors);
          },
        );
      }),
    );
  }

  // DESKTOP LAYOUT (2 Columns, maxWidth 1180px)
  Widget _buildDesktopLayout(
    dynamic product,
    List<String> displayImages,
    List<String> availableSizes,
    List<Map<String, dynamic>> fashionColors,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Breadcrumbs & Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Get.back();
                      } else {
                        Get.offNamed(AppRoutes.home);
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF0F172A)),
                    label: Text(
                      'Back to Shopping',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.snackbar('Share', 'Product link copied to clipboard',
                              snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2));
                        },
                        icon: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => controller.toggleWishlist(),
                        icon: Obx(() {
                          final isFav = controller.currentProduct.value?.isWishlisted == true;
                          return Icon(
                            isFav ? Icons.favorite : Icons.favorite_border_rounded,
                            size: 22,
                            color: const Color(0xFFE11D48),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2 Column Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COLUMN: Gallery & Try-On
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        // Main Hero Image Slider
                        Container(
                          height: 480,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 4)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                PageView.builder(
                                  controller: _pageController,
                                  itemCount: displayImages.length,
                                  onPageChanged: (idx) => controller.currentImageIndex.value = idx,
                                  itemBuilder: (context, idx) {
                                    return Image.network(
                                      displayImages[idx],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFFF1F5F9),
                                        child: const Center(
                                          child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Count pill on bottom-left
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Obx(
                                      () => Text(
                                        '${controller.currentImageIndex.value + 1}/${displayImages.length}',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Clean Horizontal Thumbnails Row (Never overlaps image!)
                        _buildHorizontalThumbnails(displayImages),

                        const SizedBox(height: 16),

                        // AI Virtual Try-On Banner Card
                        _buildTryOnBannerCard(product),
                      ],
                    ),
                  ),

                  const SizedBox(width: 36),

                  // RIGHT COLUMN: Product Info & Actions
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductInfo(product, fashionColors, availableSizes),
                          const SizedBox(height: 24),
                          _buildActionButtons(product),
                          const SizedBox(height: 24),
                          _buildTrustBadgesCard(),
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
    );
  }

  // MOBILE LAYOUT
  Widget _buildMobileLayout(
    dynamic product,
    List<String> displayImages,
    List<String> availableSizes,
    List<Map<String, dynamic>> fashionColors,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image with floating back & heart
                      Stack(
                        children: [
                          SizedBox(
                            height: 380,
                            width: double.infinity,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: displayImages.length,
                              onPageChanged: (idx) => controller.currentImageIndex.value = idx,
                              itemBuilder: (context, idx) {
                                return Image.network(
                                  displayImages[idx],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(
                                      child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Top Floating Buttons
                          Positioned(
                            top: 40,
                            left: 16,
                            right: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (Navigator.canPop(context)) {
                                      Get.back();
                                    } else {
                                      Get.offNamed(AppRoutes.home);
                                    }
                                  },
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 2)),
                                      ],
                                    ),
                                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.snackbar('Share', 'Product link copied to clipboard',
                                            snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2));
                                      },
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: const [
                                            BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 2)),
                                          ],
                                        ),
                                        child: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF0F172A)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => controller.toggleWishlist(),
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: const [
                                            BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 2)),
                                          ],
                                        ),
                                        child: Obx(() {
                                          final isFav = controller.currentProduct.value?.isWishlisted == true;
                                          return Icon(
                                            isFav ? Icons.favorite : Icons.favorite_border_rounded,
                                            size: 22,
                                            color: const Color(0xFFE11D48),
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Count pill on bottom-left
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Obx(
                                () => Text(
                                  '${controller.currentImageIndex.value + 1}/${displayImages.length}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Horizontal Thumbnails Strip below hero image (Clean, zero overlap!)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: _buildHorizontalThumbnails(displayImages),
                      ),

                      // Details Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTryOnBannerCard(product),
                            const SizedBox(height: 12),
                            _buildProductInfo(product, fashionColors, availableSizes),
                            const SizedBox(height: 20),
                            _buildTrustBadgesCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Bar: [🛒] [Add to Cart] [Buy Now]
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
                    boxShadow: [
                      BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, -4)),
                    ],
                  ),
                  child: _buildActionButtons(product),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Horizontal Thumbnails Row
  Widget _buildHorizontalThumbnails(List<String> displayImages) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(displayImages.length, (idx) {
          return Obx(() {
            final isSel = controller.currentImageIndex.value == idx;
            return GestureDetector(
              onTap: () {
                controller.currentImageIndex.value = idx;
                _pageController.animateToPage(
                  idx,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 62,
                height: 62,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                    width: isSel ? 2.5 : 1.5,
                  ),
                  boxShadow: isSel ? const [BoxShadow(color: Color(0x33E11D48), blurRadius: 6)] : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    displayImages[idx],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.image, size: 20, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            );
          });
        }),
      ),
    );
  }

  // AI Virtual Try-On Banner
  Widget _buildTryOnBannerCard(dynamic product) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.virtualTryOn, arguments: product),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF1F2), Color(0xFFFAF5FF)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF472B6).withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE11D48), Color(0xFF9333EA)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTryOnLabel(product.categoryName),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Realistic mirror preview using your photo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Try Now',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Product Info (Title, Rating, Price, Color, Size, Description)
  Widget _buildProductInfo(
    dynamic product,
    List<Map<String, dynamic>> fashionColors,
    List<String> availableSizes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Pill & Trending Chip
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                product.categoryName.toUpperCase().isNotEmpty ? product.categoryName.toUpperCase() : 'MEN',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFE11D48),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Color(0xFFE11D48), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'TRENDING',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFE11D48),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Product Title
        Text(
          product.name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),

        // Product Subtitle / Description Summary
        Text(
          product.description.isNotEmpty
              ? product.description
              : 'Stylish and comfortable fashion for everyday wear.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),

        // Rating & Reviews
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text(
              '${product.rating}',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '|   ${product.reviewCount > 0 ? product.reviewCount : 120} reviews',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Price Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '₹${product.price.toInt()}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 10),
            if (product.originalPrice != null && product.originalPrice! > product.price) ...[
              Text(
                '₹${product.originalPrice!.toInt()}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  decoration: TextDecoration.lineThrough,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${product.discountPercent > 0 ? product.discountPercent : 33}% OFF',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFE91E63),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        // Color Selector Header & Quantity Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() {
              final selIdx = controller.selectedColorIndex.value;
              final colorName = selIdx < fashionColors.length
                  ? (fashionColors[selIdx]['name'] as String)
                  : 'Yellow';
              return Row(
                children: [
                  Text(
                    'Color: ',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    colorName,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: const Color(0xFFE11D48),
                    ),
                  ),
                ],
              );
            }),

            // Quantity Selector Pill: [ —   1   + ]
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16, color: Color(0xFF0F172A)),
                    onPressed: () => controller.decrementQuantity(),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                  ),
                  Obx(
                    () => SizedBox(
                      width: 24,
                      child: Text(
                        '${controller.quantity.value}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16, color: Color(0xFF0F172A)),
                    onPressed: () => controller.incrementQuantity(),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Color Circles in Scrollable Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(fashionColors.length, (idx) {
              return Obx(() {
                final isSel = controller.selectedColorIndex.value == idx;
                final c = fashionColors[idx]['color'] as Color;
                return GestureDetector(
                  onTap: () => controller.selectedColorIndex.value = idx,
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSel ? const Color(0xFF0F172A) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x22000000)),
                      ),
                    ),
                  ),
                );
              });
            }),
          ),
        ),
        const SizedBox(height: 22),

        // Select Size & Size Guide Link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Size',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: const Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const SizeGuideSheet(),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.straighten, size: 16, color: Color(0xFFE11D48)),
                  const SizedBox(width: 4),
                  Text(
                    'Size Guide',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFE11D48),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Size Chips
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableSizes.map((sz) {
            return Obx(() {
              final isSel = controller.selectedSize.value == sz;
              return GestureDetector(
                onTap: () => controller.selectedSize.value = sz,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 48,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    sz,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: isSel ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  // Action Buttons: Cart Button, Add to Cart, Buy Now
  Widget _buildActionButtons(dynamic product) {
    return Row(
      children: [
        // Cart icon button with item badge
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.cart),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  color: Colors.white,
                ),
                child: const Icon(Icons.shopping_cart_outlined, size: 22, color: Color(0xFF0F172A)),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Obx(() {
                  final count = cartController.totalQuantity;
                  if (count <= 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE11D48),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Add to Cart
        Expanded(
          child: OutlinedButton(
            onPressed: controller.isAddingToCart.value ? null : () => controller.addToCart(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0F172A), width: 1.8),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Add to Cart',
                maxLines: 1,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Buy Now
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.isAddingToCart.value ? null : () => controller.buyNow(),
            icon: const Icon(Icons.flash_on_rounded, size: 16, color: Colors.white),
            label: controller.isAddingToCart.value
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Buy Now',
                      maxLines: 1,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  // Trust Badges Card
  Widget _buildTrustBadgesCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTrustBadge(
            icon: Icons.shield_outlined,
            title: '100% Authentic',
            subtitle: 'Original Products',
          ),
          _buildTrustDivider(),
          _buildTrustBadge(
            icon: Icons.local_shipping_outlined,
            title: 'Free Express',
            subtitle: 'Delivery',
          ),
          _buildTrustDivider(),
          _buildTrustBadge(
            icon: Icons.replay_rounded,
            title: '7 Days Return',
            subtitle: 'Easy Returns',
          ),
          _buildTrustDivider(),
          _buildTrustBadge(
            icon: Icons.support_agent_rounded,
            title: '24/7 Support',
            subtitle: "We're here to help",
          ),
        ],
      ),
    );
  }

  String _getTryOnLabel(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('shoe') || cat.contains('footwear')) return 'Try It On';
    if (cat.contains('bag') || cat.contains('access') || cat.contains('watch')) return 'See It on Me';
    if (cat.contains('furn') || cat.contains('home') || cat.contains('decor')) return 'Visualize in My Space';
    return 'Try It On';
  }

  Widget _buildTrustBadge({required IconData icon, required String title, required String subtitle}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFE11D48), size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustDivider() {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFFFFE4E6),
    );
  }
}
