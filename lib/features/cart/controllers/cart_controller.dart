import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/cart_model.dart';

class CartController extends GetxController {
  final isLoading = true.obs;
  final cartItems = <CartItemModel>[].obs;
  final cartSummary = Rxn<CartSummaryModel>();
  final couponController = TextEditingController(text: 'STYLE300');
  final isApplyingCoupon = false.obs;

  int get cartCount => cartItems.length;
  int get totalQuantity =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get finalTotal {
    if (cartSummary.value != null && cartSummary.value!.finalTotal > 0) {
      return cartSummary.value!.finalTotal;
    }
    return cartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  @override
  void onInit() {
    super.onInit();
    final token = StorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      fetchCart();
    } else {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    couponController.dispose();
    super.onClose();
  }

  Future<void> fetchCart() async {
    final token = StorageService.getAccessToken();
    if (token == null || token.isEmpty) {
      cartItems.clear();
      cartSummary.value = null;
      isLoading.value = false;
      return;
    }
    try {
      isLoading.value = true;
      final res = await ApiClient.get(ApiEndpoints.cart);
      // The server is the source of truth: an empty response must clear any
      // stale in-memory items left from a previous session or checkout.
      cartItems.assignAll(
        res.data is List
            ? (res.data as List).map((i) => CartItemModel.fromJson(i)).toList()
            : const <CartItemModel>[],
      );

      final sumRes = await ApiClient.get(
        '${ApiEndpoints.cartSummary}?coupon=${couponController.text.trim()}',
      );
      cartSummary.value = CartSummaryModel.fromJson(sumRes.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        cartItems.clear();
        cartSummary.value = null;
      }
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
      await ApiClient.patch(
        '${ApiEndpoints.cart}${item.id}/',
        data: {'quantity': newQty},
      );
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
      final res = await ApiClient.post(
        ApiEndpoints.applyCoupon,
        data: {'code': code},
      );
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
