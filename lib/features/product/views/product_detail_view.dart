import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/product_controller.dart';
import 'size_guide_sheet.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final controller = Get.put(ProductController());
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final int productId = Get.arguments as int? ?? 1;
    controller.fetchProductDetail(productId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Details',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 22),
            onPressed: () {
              Get.snackbar('Share', 'Product link copied to clipboard',
                  snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2));
            },
          ),
          IconButton(
            icon: Obx(() {
              final p = controller.currentProduct.value;
              return Icon(
                p?.isWishlisted == true ? Icons.favorite : Icons.favorite_border,
                color: p?.isWishlisted == true ? const Color(0xFFE11D48) : AppColors.textPrimary,
                size: 24,
              );
            }),
            onPressed: () => controller.toggleWishlist(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final product = controller.currentProduct.value;
        if (product == null) {
          return const Center(child: Text('Product not found'));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Image Slider with Multi-Angle View
                    Stack(
                      children: [
                        Container(
                          height: 380,
                          width: double.infinity,
                          color: const Color(0xFFF8FAFC),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: product.images.length,
                            onPageChanged: (idx) => controller.currentImageIndex.value = idx,
                            itemBuilder: (context, idx) {
                              return Image.network(
                                product.images[idx],
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
                        // Page index indicator pill (e.g. "1/6")
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Obx(
                              () => Text(
                                '${controller.currentImageIndex.value + 1}/${product.images.length}',
                                style: const TextStyle(
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

                    // 2. Multi-Angle Horizontal Thumbnails Strip (matching Reference 1 & 2)
                    if (product.images.length > 1) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 60,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: product.images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, idx) {
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
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                                      width: isSel ? 2.5 : 1,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(product.images[idx]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      ),
                    ],

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category & Trending badge
                          Row(
                            children: [
                              Text(
                                product.categoryName.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Spacer(),
                              if (product.isTrending)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1F2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.local_fire_department, color: Color(0xFFE11D48), size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'TRENDING',
                                        style: TextStyle(
                                          color: Color(0xFFE11D48),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Product Title
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.4,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Rating and Reviews Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFD97706)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${product.rating}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${product.reviewCount} reviews)',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Pricing & Stepper Row (matching Reference 1 & 3)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '₹${product.price.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      if (product.originalPrice != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '₹${product.originalPrice!.toInt()}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            decoration: TextDecoration.lineThrough,
                                            color: Color(0xFF94A3B8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (product.discountPercent > 0)
                                    Text(
                                      'Save ${product.discountPercent}% Off today',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),

                              // Quantity Stepper [- 01 +]
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 18, color: Color(0xFF0F172A)),
                                      onPressed: () => controller.decrementQuantity(),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                    Obx(
                                      () => SizedBox(
                                        width: 32,
                                        child: Text(
                                          controller.quantity.value.toString().padLeft(2, '0'),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18, color: Color(0xFF0F172A)),
                                      onPressed: () => controller.incrementQuantity(),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Color Selector with Name Label (matching Reference 2)
                          Obx(() {
                            String activeColorName = '';
                            if (product.colors.isNotEmpty &&
                                controller.selectedColorIndex.value < product.colors.length) {
                              activeColorName = product.colors[controller.selectedColorIndex.value].name;
                            }
                            return Row(
                              children: [
                                const Text('Color:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  activeColorName,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 10),
                          Row(
                            children: List.generate(
                              product.colors.length,
                              (idx) {
                                final color = product.colors[idx];
                                return Obx(() {
                                  final isSel = controller.selectedColorIndex.value == idx;
                                  Color parsedColor = Colors.grey;
                                  try {
                                    parsedColor = Color(int.parse(color.hexCode.replaceFirst('#', '0xFF')));
                                  } catch (_) {}

                                  return GestureDetector(
                                    onTap: () => controller.selectedColorIndex.value = idx,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.all(2.5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSel ? const Color(0xFF0F172A) : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: parsedColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0x22000000)),
                                        ),
                                      ),
                                    ),
                                  );
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Size Selector & Size Guide Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Select Size', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const SizeGuideSheet(),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(Icons.straighten, size: 15, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      'Size Guide',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: (product.sizes.isNotEmpty ? product.sizes : ['XS', 'S', 'M', 'L', 'XL']).map((sz) {
                              return Obx(() {
                                final isSel = controller.selectedSize.value == sz;
                                return GestureDetector(
                                  onTap: () => controller.selectedSize.value = sz,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSel ? const Color(0xFF0F172A) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSel ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                                        width: isSel ? 2 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      sz,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: isSel ? Colors.white : const Color(0xFF0F172A),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Description
                          const Text('Product Description', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Value proposition pills (matching Reference 2)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Icon(Icons.verified_outlined, color: Color(0xFF10B981), size: 24),
                                    SizedBox(height: 6),
                                    Text('100% Authentic', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(Icons.local_shipping_outlined, color: Color(0xFF3B82F6), size: 24),
                                    SizedBox(height: 6),
                                    Text('Free Express', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(Icons.replay_outlined, color: Color(0xFF8B5CF6), size: 24),
                                    SizedBox(height: 6),
                                    Text('7 Days Return', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Action Bar with Dual Buttons: Add to Cart and Buy Now
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Add to Cart
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.isAddingToCart.value ? null : () => controller.addToCart(),
                      icon: const Icon(Icons.shopping_bag_outlined, size: 18, color: Color(0xFF0F172A)),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0F172A), width: 1.8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Buy Now
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.isAddingToCart.value ? null : () => controller.buyNow(),
                      icon: const Icon(Icons.flash_on_rounded, size: 18, color: Colors.white),
                      label: controller.isAddingToCart.value
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
