import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final controller = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    final args = Get.parameters;
    controller.pageTitle.value = args['title'] ?? 'Products';
    controller.fetchProductList(
      category: args['category'],
      subcategory: args['subcategory'],
      search: args['search'],
      trending: args['trending'] == 'true',
    );
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
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            controller.pageTitle.value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0F172A), size: 24),
            onPressed: () => Get.toNamed('/cart'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              children: [
                // Filter & Sort Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: Row(
                    children: [
                      // Sort button
                      InkWell(
                        onTap: () {
                          controller.toggleSort();
                          controller.fetchProductList();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.swap_vert_rounded, size: 18, color: Color(0xFF0F172A)),
                              const SizedBox(width: 4),
                              Text(
                                'Sort: ${controller.currentSort.value == 'newest' ? 'Newest' : controller.currentSort.value == 'price_low_high' ? 'Price: Low' : 'Price: High'}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Filter button
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              Icon(Icons.tune_rounded, size: 18, color: Color(0xFF0F172A)),
                              SizedBox(width: 4),
                              Text('Filter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Grid / List Toggle
                      IconButton(
                        icon: Icon(
                          controller.isGridView.value ? Icons.grid_view_rounded : Icons.view_list_rounded,
                          size: 20,
                          color: const Color(0xFF0F172A),
                        ),
                        onPressed: () => controller.isGridView.toggle(),
                      ),
                    ],
                  ),
                ),

                // Responsive Products Grid / List
                Expanded(
                  child: controller.products.isEmpty
                      ? const Center(child: Text('No products available', style: TextStyle(fontWeight: FontWeight.w600)))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 2;
                            if (!controller.isGridView.value) {
                              crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
                            } else {
                              if (constraints.maxWidth > 1150) {
                                crossAxisCount = 5;
                              } else if (constraints.maxWidth > 850) {
                                crossAxisCount = 4;
                              } else if (constraints.maxWidth > 580) {
                                crossAxisCount = 3;
                              } else {
                                crossAxisCount = 2;
                              }
                            }

                            final childRatio = controller.isGridView.value ? 0.65 : 1.35;

                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: childRatio,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 18,
                              ),
                              itemCount: controller.products.length,
                              itemBuilder: (context, idx) {
                                final product = controller.products[idx];
                                return _buildProductCard(product);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final origPrice = product.originalPrice;
    int discount = 0;
    if (origPrice != null && origPrice > product.price) {
      discount = (((origPrice - product.price) / origPrice) * 100).round();
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
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.primaryImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFFFCE4EC)),
                    ),
                  ),
                  if (discount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                  Positioned(
                    top: 8,
                    right: 8,
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
                        product.isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 16,
                        color: product.isWishlisted ? AppColors.primary : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              (product.categoryName.isNotEmpty ? product.categoryName : 'FASHION').toUpperCase(),
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Text(
                  '₹${product.price.toInt()}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
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
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                const SizedBox(width: 3),
                Text(
                  '${product.rating}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
