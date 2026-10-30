import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../controllers/category_controller.dart';
import '../models/category_model.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _resolveImageUrl(String url) {
    if (url.isEmpty) {
      return 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600';
    }
    if (url.startsWith('/media/') || url.startsWith('media/')) {
      return '${ApiEndpoints.serverHost}/${url.replaceAll(RegExp(r'^/+'), '')}';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            }
          },
        ),
        title: const Text(
          'Collections & Categories',
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
            tooltip: 'Refresh Categories',
            onPressed: () => controller.fetchCategories(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('No categories found', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => controller.fetchCategories(),
                  child: const Text('Reload'),
                ),
              ],
            ),
          );
        }

        final currentCat = controller.currentCategory;
        final allSubcategories = currentCat?.subcategories ?? [];
        final filteredSubcategories = _searchQuery.isEmpty
            ? allSubcategories
            : allSubcategories
                .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.fetchCategories(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                children: [
                  // 1. Search Bar with luxury pill design
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 16,
                      vertical: 10,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search within ${currentCat?.name ?? "collections"}...',
                            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Horizontal Category Tabs with dynamic pills
                  Container(
                    height: 56,
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 12, vertical: 6),
                    alignment: Alignment.centerLeft,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      itemBuilder: (context, idx) {
                        final cat = controller.categories[idx];
                        final isSelected = controller.selectedCategoryIndex.value == idx;
                        return GestureDetector(
                          onTap: () {
                            controller.selectedCategoryIndex.value = idx;
                            setState(() {
                              _searchQuery = '';
                              _searchCtrl.clear();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected ? null : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                  // 3. Main Content: Hero Banner + Responsive Subcategories
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 16,
                        vertical: 20,
                      ),
                      children: [
                        // Category Hero Banner
                        if (currentCat != null && currentCat.imageUrl.isNotEmpty)
                          Container(
                            height: isDesktop ? 180 : 140,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    _resolveImageUrl(currentCat.imageUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.8),
                                          Colors.black.withValues(alpha: 0.25),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: isDesktop ? 32 : 20,
                                    top: 20,
                                    bottom: 20,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'CURATED LUXURY BOUTIQUE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          currentCat.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isDesktop ? 28 : 22,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${currentCat.subcategories.length} Handcrafted Collections • Discover Trendy Styles',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Section Heading
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${currentCat?.name ?? "Category"} Collections',
                              style: TextStyle(
                                fontSize: isDesktop ? 20 : 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${filteredSubcategories.length} Collections',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Subcategories Cards: Responsive Grid on Desktop, Sleek List on Mobile
                        if (filteredSubcategories.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(40),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  'No matching collections for "$_searchQuery"',
                                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        else if (isDesktop)
                          // Grid on Wide Screen
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: screenWidth > 1100 ? 3 : 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.8,
                            ),
                            itemCount: filteredSubcategories.length,
                            itemBuilder: (context, idx) {
                              return _buildSubcategoryCard(context, currentCat, filteredSubcategories[idx]);
                            },
                          )
                        else
                          // List on Mobile Screen
                          Column(
                            children: filteredSubcategories.map((sub) {
                              return _buildSubcategoryCard(context, currentCat, sub);
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubcategoryCard(BuildContext context, CategoryModel? currentCat, SubCategoryModel sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(
            '/products?category=${currentCat?.slug ?? ""}&subcategory=${sub.slug}&title=${sub.name}',
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // High-resolution Dynamic Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: const Color(0xFFF1F5F9),
                    child: Image.network(
                      _resolveImageUrl(sub.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFFCE4EC),
                        child: const Icon(Icons.checkroom, color: AppColors.primary, size: 32),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Title + Item Count + Trending Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sub.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${sub.itemCount}+ Items',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Row(
                            children: [
                              Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                              SizedBox(width: 4),
                              Text(
                                'Trending',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Forward Circular Action Button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
