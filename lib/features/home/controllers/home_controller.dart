import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../category/models/category_model.dart';
import '../../product/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';

class HomeController extends GetxController {
  final currentNavIndex = 0.obs;
  final currentBannerIndex = 0.obs;
  final selectedChip = 'Trending'.obs;
  final searchController = TextEditingController();

  final isLoading = true.obs;
  final banners = <Map<String, dynamic>>[].obs;
  final categories = <CategoryModel>[].obs;
  final trendingProducts = <ProductModel>[].obs;
  final allProducts = <ProductModel>[].obs;
  int get cartItemCount => Get.isRegistered<CartController>() ? Get.find<CartController>().totalQuantity : 0;
  Timer? _autoRefreshTimer;

  final chips = [
    'Trending',
    'New Arrivals',
    'Best Sellers',
    'Offers',
    'Premium',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    // Auto-refresh every 12 seconds so newly created admin products appear dynamically
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      fetchHomeData(silent: true);
    });
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchHomeData({bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;

      // 1. Fetch Banners
      final bannerRes = await ApiClient.get(ApiEndpoints.banners);
      if (bannerRes.data is List) {
        banners.assignAll(List<Map<String, dynamic>>.from(bannerRes.data));
      }

      // 2. Fetch Categories
      final catRes = await ApiClient.get(ApiEndpoints.categories);
      if (catRes.data is List) {
        categories.assignAll(
          (catRes.data as List).map((c) => CategoryModel.fromJson(c)).toList(),
        );
      }

      // 3. Fetch Products
      final prodRes = await ApiClient.get(ApiEndpoints.products);
      if (prodRes.data is List) {
        final list = (prodRes.data as List).map((p) => ProductModel.fromJson(p)).toList();
        allProducts.assignAll(list);
        applyChipFilter(selectedChip.value);
      }
    } catch (e) {
      debugPrint('Error fetching home data: $e');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  void selectChip(String chip) {
    selectedChip.value = chip;
    applyChipFilter(chip);
  }

  void applyChipFilter(String chip) {
    if (chip == 'Trending') {
      final filtered = allProducts.where((p) => p.isTrending).toList();
      trendingProducts.assignAll(filtered.isNotEmpty ? filtered : allProducts);
    } else if (chip == 'New Arrivals') {
      final filtered = allProducts.where((p) => p.isNewArrival).toList();
      trendingProducts.assignAll(filtered.isNotEmpty ? filtered : allProducts);
    } else if (chip == 'Offers') {
      final filtered = allProducts.where((p) => p.originalPrice != null && p.originalPrice! > p.price).toList();
      trendingProducts.assignAll(filtered.isNotEmpty ? filtered : allProducts);
    } else if (chip == 'Best Sellers' || chip == 'Premium') {
      final sorted = List<ProductModel>.from(allProducts)..sort((a, b) => b.rating.compareTo(a.rating));
      trendingProducts.assignAll(sorted);
    } else {
      trendingProducts.assignAll(allProducts);
    }
  }

  Future<void> toggleWishlist(ProductModel product) async {
    product.isWishlisted = !product.isWishlisted;
    trendingProducts.refresh();
    allProducts.refresh();

    try {
      await ApiClient.post(ApiEndpoints.wishlistToggle, data: {
        'product_id': product.id,
      });
    } catch (e) {
      product.isWishlisted = !product.isWishlisted;
      trendingProducts.refresh();
      allProducts.refresh();
    }
  }
}
