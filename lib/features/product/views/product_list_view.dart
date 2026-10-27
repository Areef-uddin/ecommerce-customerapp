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
    controller.pageTitle.value = args['title'] ?? 'Dresses (124)';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            controller.pageTitle.value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Get.toNamed('/cart'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return Column(
          children: [
            // Filter Bar matching Screen 7: Sort, Filter, Grid
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
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
                          const Icon(Icons.swap_vert, size: 18, color: AppColors.textPrimary),
                          const SizedBox(width: 4),
                          Text(
                            'Sort: ${controller.currentSort.value == 'newest' ? 'Newest' : controller.currentSort.value == 'price_low_high' ? 'Price: Low' : 'Price: High'}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
                          Icon(Icons.tune, size: 18, color: AppColors.textPrimary),
                          SizedBox(width: 4),
                          Text('Filter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Grid Toggle button
                  IconButton(
                    icon: Icon(
                      controller.isGridView.value ? Icons.grid_view : Icons.view_list,
                      size: 20,
                    ),
                    onPressed: () => controller.isGridView.toggle(),
                  ),
                ],
              ),
            ),

            // Products Grid / List
            Expanded(
              child: controller.products.isEmpty
                  ? const Center(child: Text('No products available'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: controller.isGridView.value ? 2 : 1,
                        childAspectRatio: controller.isGridView.value ? 0.62 : 1.3,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 18,
                      ),
                      itemCount: controller.products.length,
                      itemBuilder: (context, idx) {
                        final product = controller.products[idx];
                        return _buildProductCard(product);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => Get.toNamed('/product-detail', arguments: product.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    product.primaryImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      product.isWishlisted ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: product.isWishlisted ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '₹${product.price.toInt()}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              if (product.originalPrice != null) ...[
                const SizedBox(width: 6),
                Text(
                  '₹${product.originalPrice!.toInt()}',
                  style: const TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.star),
              const SizedBox(width: 4),
              Text(
                '${product.rating} (${(product.reviewCount / 1000).toStringAsFixed(1)}k)',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
