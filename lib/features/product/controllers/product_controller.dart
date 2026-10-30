import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';

class ProductController extends GetxController {
  final isLoading = true.obs;
  final products = <ProductModel>[].obs;
  final currentProduct = Rxn<ProductModel>();

  // Filter & Sort State
  final currentSort = 'newest'.obs;
  final isGridView = true.obs;
  final pageTitle = 'Products'.obs;

  // Detail View State
  final selectedColorIndex = 0.obs;
  final selectedSize = 'M'.obs;
  final currentImageIndex = 0.obs;
  final quantity = 1.obs;
  final isAddingToCart = false.obs;
  final isWishlisting = false.obs;

  void incrementQuantity() {
    if (quantity.value < 10) quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  // Size Guide State
  final sizeGuideCategory = 'Women'.obs;
  final isUnitInches = true.obs;
  final sizeGuideList = <Map<String, dynamic>>[].obs;

  Future<void> fetchProductList({
    String? category,
    String? subcategory,
    String? search,
    bool? trending,
  }) async {
    try {
      isLoading.value = true;
      String url = '${ApiEndpoints.products}?sort=${currentSort.value}';
      if (category != null && category.isNotEmpty) url += '&category=$category';
      if (subcategory != null && subcategory.isNotEmpty) url += '&subcategory=$subcategory';
      if (search != null && search.isNotEmpty) url += '&search=$search';
      if (trending == true) url += '&trending=true';

      final res = await ApiClient.get(url);
      if (res.data is List) {
        products.assignAll(
          (res.data as List).map((p) => ProductModel.fromJson(p)).toList(),
        );
      }
    } catch (e) {
      // error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductDetail(int id) async {
    try {
      isLoading.value = true;
      final res = await ApiClient.get('${ApiEndpoints.products}$id/');
      currentProduct.value = ProductModel.fromJson(res.data);
      if (currentProduct.value != null && currentProduct.value!.sizes.isNotEmpty) {
        selectedSize.value = currentProduct.value!.sizes.first;
      }
    } catch (e) {
      // error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSizeGuide() async {
    try {
      final res = await ApiClient.get('${ApiEndpoints.sizeGuide}?category=${sizeGuideCategory.value}');
      if (res.data is List) {
        sizeGuideList.assignAll(List<Map<String, dynamic>>.from(res.data));
      }
    } catch (e) {
      // error
    }
  }

  Future<void> addToCart() async {
    final product = currentProduct.value;
    if (product == null) return;

    try {
      isAddingToCart.value = true;
      String colorName = 'Standard';
      if (product.colors.isNotEmpty && selectedColorIndex.value < product.colors.length) {
        colorName = product.colors[selectedColorIndex.value].name;
      }

      await ApiClient.post(ApiEndpoints.cart, data: {
        'product_id': product.id,
        'quantity': quantity.value,
        'size': selectedSize.value,
        'color': colorName,
      });

      // Synchronize CartController immediately
      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().fetchCart();
      }

      Get.snackbar(
        'Added to Bag',
        '${product.name} added to your shopping bag',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add item to bag');
    } finally {
      isAddingToCart.value = false;
    }
  }

  Future<void> toggleWishlist() async {
    final product = currentProduct.value;
    if (product == null) return;

    product.isWishlisted = !product.isWishlisted;
    currentProduct.refresh();

    try {
      final res = await ApiClient.post(ApiEndpoints.wishlistToggle, data: {
        'product_id': product.id,
      });

      if (res.data != null && res.data['is_wishlisted'] != null) {
        product.isWishlisted = res.data['is_wishlisted'] == true;
        currentProduct.refresh();
      }

      // Synchronize WishlistController immediately
      if (Get.isRegistered<WishlistController>()) {
        Get.find<WishlistController>().fetchWishlist();
      }

      Get.snackbar(
        product.isWishlisted ? 'Saved to Wishlist' : 'Removed from Wishlist',
        product.name,
        backgroundColor: product.isWishlisted ? const Color(0xFFE91E63) : Colors.black87,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      product.isWishlisted = !product.isWishlisted;
      currentProduct.refresh();
      Get.snackbar('Error', 'Failed to update wishlist');
    }
  }

  Future<void> buyNow() async {
    final product = currentProduct.value;
    if (product == null) return;

    try {
      isAddingToCart.value = true;
      String colorName = 'Standard';
      if (product.colors.isNotEmpty && selectedColorIndex.value < product.colors.length) {
        colorName = product.colors[selectedColorIndex.value].name;
      }

      // Clear existing cart so Buy Now checks out ONLY this product with selected quantity
      try {
        await ApiClient.delete(ApiEndpoints.clearCart);
      } catch (_) {}

      await ApiClient.post(ApiEndpoints.cart, data: {
        'product_id': product.id,
        'quantity': quantity.value,
        'size': selectedSize.value,
        'color': colorName,
      });

      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().fetchCart();
      }

      Get.toNamed('/checkout-address');
    } catch (e) {
      Get.snackbar('Error', 'Failed to proceed to checkout');
    } finally {
      isAddingToCart.value = false;
    }
  }

  void toggleSort() {
    if (currentSort.value == 'newest') {
      currentSort.value = 'price_low_high';
    } else if (currentSort.value == 'price_low_high') {
      currentSort.value = 'price_high_low';
    } else {
      currentSort.value = 'newest';
    }
  }
}
