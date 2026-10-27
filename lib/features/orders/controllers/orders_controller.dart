import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/order_model.dart';

class OrdersController extends GetxController {
  final isLoading = true.obs;
  final orders = <OrderModel>[].obs;
  final currentOrder = Rxn<OrderModel>();
  final selectedFilter = 'All'.obs;
  Timer? _refreshTimer;

  // Return & Refund State
  final selectedReason = 'Size too small'.obs;
  final pickupType = 'Pickup'.obs;
  final isSubmittingReturn = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    // Auto-refresh orders every 5 seconds so status changes reflect live
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchOrders(silent: true);
      if (currentOrder.value != null) {
        fetchOrderDetail(currentOrder.value!.id, silent: true);
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
      if (!silent) isLoading.value = true;
      String url = ApiEndpoints.orders;
      if (selectedFilter.value != 'All') {
        url += '?status=${selectedFilter.value}';
      }

      final res = await ApiClient.get(url);
      if (res.data is List) {
        orders.assignAll(
          (res.data as List).map((o) => OrderModel.fromJson(o)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> fetchOrderDetail(int orderId, {bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      final res = await ApiClient.get('${ApiEndpoints.orders}$orderId/');
      currentOrder.value = OrderModel.fromJson(res.data);
    } catch (e) {
      debugPrint('Error fetching order detail: $e');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> initiateReturn(int orderId) async {
    try {
      isSubmittingReturn.value = true;
      await ApiClient.post(ApiEndpoints.returns, data: {
        'order_id': orderId,
        'reason': selectedReason.value,
        'pickup_type': pickupType.value,
      });

      Get.back();
      Get.snackbar('Return Initiated', 'Pickup will be arranged within 2 business days.');
      fetchOrders();
    } catch (e) {
      Get.snackbar('Error', 'Failed to initiate return');
    } finally {
      isSubmittingReturn.value = false;
    }
  }
}
