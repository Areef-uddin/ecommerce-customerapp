import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../product/models/product_model.dart';

class WishlistController extends GetxController {
  final isLoading = true.obs;
  final wishlistItems = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    try {
      isLoading.value = true;
      final res = await ApiClient.get(ApiEndpoints.wishlist);
      if (res.data is List) {
        wishlistItems.assignAll(
          (res.data as List).map((w) => ProductModel.fromJson(w['product'])).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFromWishlist(ProductModel product) async {
    wishlistItems.removeWhere((p) => p.id == product.id);
    try {
      await ApiClient.post(ApiEndpoints.wishlistToggle, data: {'product_id': product.id});
    } catch (e) {
      fetchWishlist();
    }
  }

  Future<void> moveAllToCart() async {
    for (var item in wishlistItems) {
      try {
        await ApiClient.post(ApiEndpoints.cart, data: {
          'product_id': item.id,
          'quantity': 1,
          'size': item.sizes.isNotEmpty ? item.sizes.first : 'M',
          'color': item.colors.isNotEmpty ? item.colors.first.name : 'Standard',
        });
      } catch (_) {}
    }
    Get.toNamed('/cart');
  }
}
