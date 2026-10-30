import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/order_model.dart';

class OrdersController extends GetxController {
  final isLoading = true.obs;
  final orders = <OrderModel>[].obs;
  final currentOrder = Rxn<OrderModel>();
  final trackingData = Rxn<ShipmentTrackingModel>();
  final isTrackingLoading = false.obs;
  final selectedFilter = 'All'.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  Timer? _refreshTimer;

  // Return & Refund State
  final selectedReason = 'Size too small'.obs;
  final pickupType = 'Pickup'.obs;
  final isSubmittingReturn = false.obs;
  final selectedReturnItemId = RxnInt();
  final isBuyingAgain = false.obs;

  @override
  void onInit() {
    super.onInit();
    final token = StorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      fetchOrders();
    } else {
      isLoading.value = false;
    }
    // Auto-refresh orders every 5 seconds only when user is authenticated
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final t = StorageService.getAccessToken();
      if (t != null && t.isNotEmpty) {
        fetchOrders(silent: true);
        if (currentOrder.value != null) {
          fetchOrderDetail(currentOrder.value!.id, silent: true);
        }
      }
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchOrders({bool silent = false}) async {
    try {
      if (!silent) {
        isLoading.value = true;
        hasError.value = false;
      }
      String url = ApiEndpoints.orders;
      if (selectedFilter.value != 'All') {
        url += '?status=${Uri.encodeComponent(selectedFilter.value)}';
      }

      final res = await ApiClient.get(url);
      if (res.data is List) {
        orders.assignAll(
          (res.data as List).map((o) => OrderModel.fromJson(o)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (!silent) {
        hasError.value = true;
        errorMessage.value = 'Failed to load orders. Please try again.';
      }
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> fetchOrderDetail(int orderId, {bool silent = false}) async {
    try {
      if (!silent) {
        isLoading.value = true;
        hasError.value = false;
      }
      final res = await ApiClient.get('${ApiEndpoints.orders}$orderId/');
      final order = OrderModel.fromJson(res.data);
      final previousOrderId = currentOrder.value?.id;
      currentOrder.value = order;
      if (previousOrderId != order.id || selectedReturnItemId.value == null) {
        selectedReturnItemId.value = order.items.isEmpty
            ? null
            : order.items.first.id;
      }
      if (order.shipment != null) {
        trackingData.value = order.shipment;
      }
    } catch (e) {
      debugPrint('Error fetching order detail: $e');
      if (!silent) {
        hasError.value = true;
        errorMessage.value = 'Failed to load order details.';
      }
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> fetchTrackingInfo(int orderId, {bool silent = false}) async {
    try {
      if (!silent) isTrackingLoading.value = true;
      final res = await ApiClient.get(
        '${ApiEndpoints.orders}$orderId/tracking/',
      );
      if (res.data is Map<String, dynamic>) {
        trackingData.value = ShipmentTrackingModel.fromJson(res.data);
      }
      // Also sync current order
      await fetchOrderDetail(orderId, silent: true);
    } catch (e) {
      debugPrint('Error fetching tracking info: $e');
    } finally {
      if (!silent) isTrackingLoading.value = false;
    }
  }

  Future<void> initiateReturn(int orderId) async {
    try {
      isSubmittingReturn.value = true;
      await ApiClient.post(
        ApiEndpoints.returns,
        data: {
          'order_id': orderId,
          if (selectedReturnItemId.value != null)
            'order_item_id': selectedReturnItemId.value,
          'reason': selectedReason.value,
          'pickup_type': pickupType.value,
        },
      );

      Get.back();
      Get.snackbar(
        'Return Requested',
        'We will review your request and update pickup and refund status here.',
      );
      fetchOrders();
    } catch (e) {
      var message = 'Failed to initiate return';
      if (e is DioException && e.response?.data is Map) {
        final detail = (e.response!.data as Map)['detail'];
        if (detail is String) message = detail;
      } else if (e is DioException && e.response?.data is String) {
        final detail = (e.response!.data as String).trim();
        if (detail.isNotEmpty) message = detail;
      } else if (e is DioException && e.response == null) {
        message = 'Could not reach the return service. Check your connection and try again.';
      }
      Get.snackbar('Return unavailable', message);
    } finally {
      isSubmittingReturn.value = false;
    }
  }

  Future<void> buyAgain(int orderId) async {
    if (isBuyingAgain.value) return;
    isBuyingAgain.value = true;
    try {
      final response = await ApiClient.post(
        '${ApiEndpoints.orders}$orderId/buy_again/',
      );
      final added = int.tryParse(response.data['added_items'].toString()) ?? 0;
      final unavailable =
          (response.data['unavailable_items'] as List?) ?? const [];
      if (added == 0) {
        final detail = unavailable.isEmpty
            ? 'No available products from this order can be added again.'
            : 'These products are no longer available: ${unavailable.join(', ')}';
        Get.snackbar('Unavailable', detail);
        return;
      }

      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().fetchCart();
      }
      final message = unavailable.isEmpty
          ? 'Items from this order are back in your bag.'
          : 'Available items were added. Some products are unavailable: ${unavailable.join(', ')}';
      Get.snackbar('Added to Bag', message);
      await Get.toNamed(AppRoutes.cart);
    } catch (e) {
      var message = 'Could not add this order to your bag. Please try again.';
      if (e is DioException && e.response?.data is Map) {
        final detail = (e.response!.data as Map)['detail'];
        if (detail is String && detail.isNotEmpty) message = detail;
      }
      Get.snackbar('Buy Again unavailable', message);
    } finally {
      isBuyingAgain.value = false;
    }
  }
}
