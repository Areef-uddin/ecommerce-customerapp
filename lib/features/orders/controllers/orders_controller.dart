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
  final allOrders = <OrderModel>[].obs;
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
  bool _isFetchingOrders = false;
  int _ordersRequestVersion = 0;

  @override
  void onInit() {
    super.onInit();
    final token = StorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      fetchOrders();
    } else {
      isLoading.value = false;
    }
    // Auto-refresh orders every 10 seconds only when user is authenticated
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
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

  int countForTab(String tab) {
    switch (tab.toLowerCase()) {
      case 'processing':
        return allOrders
            .where((o) => [
                  'processing',
                  'placed',
                  'order placed',
                  'confirmed',
                  'packed',
                ].contains(o.orderStatus.toLowerCase()))
            .length;
      case 'shipped':
        return allOrders
            .where((o) => [
                  'picked up',
                  'in transit',
                  'shipped',
                  'dispatched',
                  'out for delivery',
                ].contains(o.orderStatus.toLowerCase()))
            .length;
      case 'delivered':
        return allOrders
            .where((o) => o.orderStatus.toLowerCase() == 'delivered')
            .length;
      case 'returns':
      case 'return / refund':
        return allOrders.where((o) => o.returns.isNotEmpty).length;
      case 'cancelled':
        return allOrders.where((o) => o.orderStatus.toLowerCase() == 'cancelled').length;
      case 'all':
      default:
        return allOrders.length;
    }
  }

  void setFilter(String tab) {
    selectedFilter.value = tab;
    applyFilter();
  }

  void applyFilter() {
    final filter = selectedFilter.value.toLowerCase();
    List<OrderModel> filtered;
    if (filter == 'processing') {
      filtered = allOrders
          .where((o) => [
                'processing',
                'placed',
                'order placed',
                'confirmed',
                'packed',
              ].contains(o.orderStatus.toLowerCase()))
          .toList();
    } else if (filter == 'shipped') {
      filtered = allOrders
          .where((o) => [
                'picked up',
                'in transit',
                'shipped',
                'dispatched',
                'out for delivery',
              ].contains(o.orderStatus.toLowerCase()))
          .toList();
    } else if (filter == 'delivered') {
      filtered = allOrders
          .where((o) => o.orderStatus.toLowerCase() == 'delivered')
          .toList();
    } else if (filter == 'returns' || filter == 'return / refund') {
      filtered = allOrders.where((o) => o.returns.isNotEmpty).toList();
    } else if (filter == 'cancelled') {
      filtered = allOrders.where((o) => o.orderStatus.toLowerCase() == 'cancelled').toList();
    } else {
      filtered = List<OrderModel>.from(allOrders);
    }
    orders.assignAll(filtered);
  }

  Future<void> fetchOrders({bool silent = false}) async {
    if (silent && _isFetchingOrders) return;
    final requestVersion = ++_ordersRequestVersion;
    _isFetchingOrders = true;
    try {
      if (!silent) {
        isLoading.value = true;
        hasError.value = false;
      }
      
      // Fetch all orders and returns together for complete state
      final res = await ApiClient.get(ApiEndpoints.orders);
      if (res.data is List) {
        List<dynamic> returnRecords = const [];
        try {
          final returnResponse = await ApiClient.get(ApiEndpoints.returns);
          if (returnResponse.data is List) {
            returnRecords = returnResponse.data as List<dynamic>;
          }
        } catch (error) {
          debugPrint('Could not refresh return badges: $error');
        }
        if (requestVersion != _ordersRequestVersion) return;
        final returnsByOrder = <int, List<Map<String, dynamic>>>{};
        for (final record in returnRecords.whereType<Map>()) {
          final orderId = int.tryParse(record['order'].toString());
          if (orderId == null) continue;
          returnsByOrder.putIfAbsent(orderId, () => []).add(
            Map<String, dynamic>.from(record),
          );
        }
        final parsed = (res.data as List).whereType<Map>().map((rawOrder) {
          final json = Map<String, dynamic>.from(rawOrder);
          final id = int.tryParse(json['id'].toString());
          final directReturns = id == null
              ? const <Map<String, dynamic>>[]
              : returnsByOrder[id] ?? const <Map<String, dynamic>>[];
          json['returns'] = directReturns.isNotEmpty
              ? directReturns
              : (json['returns'] as List?) ?? const [];
          return OrderModel.fromJson(json);
        }).toList();

        allOrders.assignAll(parsed);
        applyFilter();

        if (currentOrder.value != null) {
          final updatedCurrent = parsed.firstWhereOrNull(
            (o) => o.id == currentOrder.value!.id,
          );
          if (updatedCurrent != null) {
            currentOrder.value = updatedCurrent;
          }
        }
      } else {
        throw const FormatException('The orders response is not a list.');
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (!silent && requestVersion == _ordersRequestVersion) {
        hasError.value = true;
        errorMessage.value = 'Failed to load orders. Please try again.';
      }
    } finally {
      if (requestVersion == _ordersRequestVersion) {
        _isFetchingOrders = false;
        isLoading.value = false;
      }
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
      final itemId = selectedReturnItemId.value;
      if (itemId == null) {
        Get.snackbar('Choose an item', 'Select the item you want to return.');
        return;
      }
      isSubmittingReturn.value = true;
      await ApiClient.post(
        ApiEndpoints.returns,
        data: {
          'order_id': orderId,
          'order_item_id': itemId,
          'reason': selectedReason.value,
          'pickup_type': pickupType.value,
        },
      );

      await Future.wait([
        fetchOrderDetail(orderId, silent: true),
        fetchOrders(silent: true),
      ]);
      Get.back();
      Get.snackbar(
        'Return Requested',
        'Your return status and every update will appear in Order Details and Notifications.',
      );
    } catch (e) {
      var message = 'Failed to initiate return';
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map;
        final detail = data['detail'] ?? data['message'];
        if (detail is String && detail.isNotEmpty) message = detail;
      } else if (e is DioException && e.response?.data is String) {
        final detail = (e.response!.data as String).trim();
        if (detail.isNotEmpty) message = detail;
      } else if (e is DioException && e.response == null) {
        message = 'Could not reach the return service. Check your connection and try again.';
      } else if (e is DioException) {
        message =
            'Return request failed (HTTP ${e.response?.statusCode ?? 'unknown'}). Please refresh the order and try again.';
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
