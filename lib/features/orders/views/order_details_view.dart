import '../models/order_model.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/orders_controller.dart';

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({super.key});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  final controller = Get.put(OrdersController());
  int orderId = 0;

  @override
  void initState() {
    super.initState();
    _initOrder();
  }

  void _initOrder() async {
    // 1. Check Get.arguments for OrderModel
    if (Get.arguments is OrderModel) {
      final ord = Get.arguments as OrderModel;
      orderId = ord.id;
      controller.currentOrder.value = ord;
      controller.fetchOrderDetail(orderId, silent: true);
      return;
    }

    // 2. Check Get.arguments for int id
    if (Get.arguments is int && (Get.arguments as int) > 0) {
      orderId = Get.arguments as int;
      controller.fetchOrderDetail(orderId);
      return;
    }

    // 2. Check query parameter id (e.g. ?id=2)
    final paramId = Get.parameters['id'];
    if (paramId != null && int.tryParse(paramId) != null) {
      orderId = int.parse(paramId);
      controller.fetchOrderDetail(orderId);
      return;
    }

    // 3. Check existing loaded orders in controller
    if (controller.orders.isNotEmpty) {
      orderId = controller.orders.first.id;
      controller.fetchOrderDetail(orderId);
      return;
    }

    // 4. Fallback: fetch orders and pick the user's latest order
    await controller.fetchOrders();
    if (controller.orders.isNotEmpty) {
      orderId = controller.orders.first.id;
      controller.fetchOrderDetail(orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offNamed(AppRoutes.myOrders);
            }
          },
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () {
              if (orderId > 0) controller.fetchOrderDetail(orderId);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final order = controller.currentOrder.value;
        if (order == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size: 52,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Order Not Found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We could not locate this order. It may have been created in another session or the link is expired.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.offNamed(AppRoutes.myOrders),
                    icon: const Icon(Icons.list_alt_rounded),
                    label: const Text('View All My Orders'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    child: const Text(
                      'Continue Shopping',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final firstItem = order.items.isNotEmpty ? order.items.first : null;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.fetchOrderDetail(orderId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tracking Number Quick Card
                    InkWell(
                      onTap: () =>
                          Get.toNamed('/order-tracking', arguments: order.id),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_shipping,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        order.trackingNumber,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          'DEMO',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFB45309),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Status: ${order.orderStatus} • Tap to view live tracking',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF15803D),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF16A34A),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Product Info Card with "Buy Again" button matching Screen 16
                    if (firstItem != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                firstItem.imageUrl,
                                width: 70,
                                height: 75,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 70,
                                  height: 75,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    firstItem.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${firstItem.price.toInt()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Size: ${firstItem.size} | Color: ${firstItem.color} | Qty: ${firstItem.quantity}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => controller.buyAgain(order.id),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Obx(
                                () => controller.isBuyingAgain.value
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Buy Again',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Return / Refund Action if Delivered
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need to return this item?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '7-day return guarantee available',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed(
                              '/return-refund',
                              arguments: order.id,
                            ),
                            child: const Text(
                              'Return / Refund',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Vertical Tracking Stepper matching Screen 16
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Timeline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Get.toNamed(
                            AppRoutes.orderTracking,
                            arguments: order,
                          ),
                          icon: const Icon(
                            Icons.open_in_new,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Full Tracking',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...order.timeline.map((step) {
                      final isLast =
                          order.timeline.indexOf(step) ==
                          order.timeline.length - 1;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: step.isCompleted
                                      ? const Color(0xFF10B981)
                                      : Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: step.isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        size: 10,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 38,
                                  color: step.isCompleted
                                      ? const Color(0xFF10B981)
                                      : Colors.grey.shade300,
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.statusStep,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: step.isCompleted
                                        ? AppColors.textPrimary
                                        : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  step.dateText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 24),

                    // Track Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed(
                          AppRoutes.orderTracking,
                          arguments: order,
                        ),
                        icon: const Icon(Icons.local_shipping_outlined),
                        label: const Text('Track Order Live'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
