import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/cart_model.dart';

class CartController extends GetxController {
  final isLoading = true.obs;
  final cartItems = <CartItemModel>[].obs;
  final cartSummary = Rxn<CartSummaryModel>();
  final couponController = TextEditingController(text: 'STYLE300');
  final isApplyingCoupon = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  @override
  void onClose() {
    couponController.dispose();
    super.onClose();
  }

  Future<void> fetchCart() async {
    try {
      isLoading.value = true;
      final res = await ApiClient.get(ApiEndpoints.cart);
      if (res.data is List) {
        cartItems.assignAll(
          (res.data as List).map((i) => CartItemModel.fromJson(i)).toList(),
        );
      }

      final sumRes = await ApiClient.get(
        '${ApiEndpoints.cartSummary}?coupon=${couponController.text.trim()}',
      );
      cartSummary.value = CartSummaryModel.fromJson(sumRes.data);
    } catch (e) {
      debugPrint('Error fetching cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateQuantity(CartItemModel item, int newQty) async {
    if (newQty <= 0) {
      deleteCartItem(item.id);
      return;
    }

    item.quantity = newQty;
    cartItems.refresh();

    try {
      await ApiClient.patch('${ApiEndpoints.cart}${item.id}/', data: {
        'quantity': newQty,
      });
      fetchCart();
    } catch (e) {
      // rollback
    }
  }

  Future<void> deleteCartItem(int id) async {
    try {
      await ApiClient.delete('${ApiEndpoints.cart}$id/');
      cartItems.removeWhere((i) => i.id == id);
      fetchCart();
    } catch (e) {
      // error
    }
  }

  Future<void> applyCoupon() async {
    final code = couponController.text.trim();
    if (code.isEmpty) return;

    try {
      isApplyingCoupon.value = true;
      final res = await ApiClient.post(ApiEndpoints.applyCoupon, data: {'code': code});
      Get.snackbar('Success', res.data['message'] ?? 'Coupon applied!');
      fetchCart();
    } catch (e) {
      Get.snackbar('Coupon Error', 'Invalid or expired coupon');
    } finally {
      isApplyingCoupon.value = false;
    }
  }

  Future<void> clearCart() async {
    try {
      await ApiClient.delete(ApiEndpoints.clearCart);
      cartItems.clear();
      fetchCart();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
}
