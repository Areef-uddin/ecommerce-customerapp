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

  @override
  void initState() {
    super.initState();
    final int productId = Get.arguments as int? ?? 1;
    controller.fetchProductDetail(productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(
            icon: Obx(() {
              final p = controller.currentProduct.value;
              return Icon(
                p?.isWishlisted == true ? Icons.favorite : Icons.favorite_border,
                color: p?.isWishlisted == true ? AppColors.primary : AppColors.textPrimary,
              );
            }),
            onPressed: () {
              final p = controller.currentProduct.value;
              if (p != null) {
                p.isWishlisted = !p.isWishlisted;
                controller.currentProduct.refresh();
              }
            },
          ),
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
                    // 1. Image Slider Carousel matching Screen 8
                    SizedBox(
                      height: 380,
                      child: PageView.builder(
                        itemCount: product.images.length,
                        onPageChanged: (idx) => controller.currentImageIndex.value = idx,
                        itemBuilder: (context, idx) {
                          return Image.network(
                            product.images[idx],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
                          );
                        },
                      ),
                    ),

                    // Slider Dots
                    if (product.images.length > 1) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.images.length,
                          (idx) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: controller.currentImageIndex.value == idx ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: controller.currentImageIndex.value == idx ? AppColors.primary : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Wishlist Button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Rating
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: AppColors.star),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${product.reviewCount} reviews)',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Pricing: ₹1,299  ₹2,499 (48% OFF)
                          Row(
                            children: [
                              Text(
                                '₹${product.price.toInt()}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              if (product.originalPrice != null) ...[
                                const SizedBox(width: 10),
                                Text(
                                  '₹${product.originalPrice!.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                              if (product.discountPercent > 0) ...[
                                const SizedBox(width: 10),
                                Text(
                                  '(${product.discountPercent}% OFF)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.discountRed,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Color Selector Circles
                          const Text('Color', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 10),
                          Row(
                            children: List.generate(
                              product.colors.length,
                              (idx) {
                                final color = product.colors[idx];
                                final isSel = controller.selectedColorIndex.value == idx;
                                Color parsedColor = Colors.grey;
                                try {
                                  parsedColor = Color(int.parse(color.hexCode.replaceFirst('#', '0xFF')));
                                } catch (_) {}

                                return GestureDetector(
                                  onTap: () => controller.selectedColorIndex.value = idx,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSel ? AppColors.primary : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: parsedColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.black12),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Size Selector & Size Guide Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Size', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const SizeGuideSheet(),
                                  );
                                },
                                child: const Text(
                                  'Size Guide',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: (product.sizes.isNotEmpty ? product.sizes : ['XS', 'S', 'M', 'L', 'XL']).map((sz) {
                              final isSel = controller.selectedSize.value == sz;
                              return GestureDetector(
                                onTap: () => controller.selectedSize.value = sz,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.primary : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
                                  ),
                                  child: Text(
                                    sz,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isSel ? Colors.white : AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Description
                          const Text('Product Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Action Bar with Add to Cart and Buy Now
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.isAddingToCart.value ? null : () => controller.addToCart(),
                      icon: const Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.primary),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.isAddingToCart.value ? null : () => controller.buyNow(),
                      icon: const Icon(Icons.flash_on, size: 18, color: Colors.white),
                      label: controller.isAddingToCart.value
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
