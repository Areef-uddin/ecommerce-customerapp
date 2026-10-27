import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../category/models/category_model.dart';
import '../../product/models/product_model.dart';

class HomeController extends GetxController {
  final currentNavIndex = 0.obs;
  final searchController = TextEditingController();

  final isLoading = true.obs;
  final banners = <Map<String, dynamic>>[].obs;
  final categories = <CategoryModel>[].obs;
  final trendingProducts = <ProductModel>[].obs;
  final cartItemCount = 2.obs;
  Timer? _autoRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    // Auto-refresh every 8 seconds so newly created admin products appear dynamically
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
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

      // 3. Fetch Trending Products
      final prodRes = await ApiClient.get('${ApiEndpoints.products}?trending=true');
      if (prodRes.data is List) {
        trendingProducts.assignAll(
          (prodRes.data as List).map((p) => ProductModel.fromJson(p)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching home data: $e');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> toggleWishlist(ProductModel product) async {
    product.isWishlisted = !product.isWishlisted;
    trendingProducts.refresh();

    try {
      await ApiClient.post(ApiEndpoints.wishlistToggle, data: {
        'product_id': product.id,
      });
    } catch (e) {
      product.isWishlisted = !product.isWishlisted;
      trendingProducts.refresh();
    }
  }
}
