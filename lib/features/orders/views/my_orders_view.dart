import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';

class MyOrdersView extends StatelessWidget {
  const MyOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());

    final tabs = ['All', 'Processing', 'Shipped', 'Delivered', 'Returns'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAllNamed(AppRoutes.home);
            }
          },
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh orders and return updates',
            onPressed: () => controller.fetchOrders(),
            icon: const Icon(Icons.refresh, color: AppColors.primary),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              // Filter Tabs (All, Processing, Shipped, Delivered, Returns)
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final tab = tabs[i];
                    return Obx(() {
                      final isSel = controller.selectedFilter.value.toLowerCase() ==
                          tab.toLowerCase();
                      final count = controller.countForTab(tab);
                      return GestureDetector(
                        onTap: () => controller.setFilter(tab),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primary
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tab,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSel
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isSel
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),

              // Orders List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.allOrders.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (controller.hasError.value && controller.allOrders.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 42,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => controller.fetchOrders(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.orders.isEmpty) {
                    final hasAnyOrder = controller.allOrders.isNotEmpty;
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              hasAnyOrder
                                  ? Icons.filter_alt_off_outlined
                                  : Icons.shopping_bag_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              hasAnyOrder
                                  ? 'No ${controller.selectedFilter.value} orders'
                                  : 'No orders found',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hasAnyOrder
                                  ? 'You do not have any orders in the ${controller.selectedFilter.value} category.'
                                  : 'Looks like you haven\'t placed any orders yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (hasAnyOrder) {
                                  controller.setFilter('All');
                                } else {
                                  Get.offAllNamed(AppRoutes.home);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                hasAnyOrder
                                    ? 'View All Orders (${controller.countForTab('All')})'
                                    : 'Start Shopping',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => controller.fetchOrders(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, idx) {
                        final order = controller.orders[idx];
                        return _buildOrderCard(order);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildOrderCard(OrderModel order) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final latestReturn = order.returns.isEmpty ? null : order.returns.first;
    final hasReturn = latestReturn != null;

    Color badgeColor = Colors.orange;
    if ([
      'Picked Up',
      'Shipped',
      'In Transit',
      'Out for Delivery',
    ].contains(order.orderStatus)) {
      badgeColor = Colors.blue;
    }
    if (order.orderStatus == 'Delivered') {
      badgeColor = Colors.green;
    }
    if (order.orderStatus == 'Cancelled') {
      badgeColor = Colors.red;
    }
    if (hasReturn) {
      if (latestReturn.status == 'Refund Processed') {
        badgeColor = const Color(0xFF15803D);
      } else if (latestReturn.status == 'Rejected') {
        badgeColor = const Color(0xFFDC2626);
      } else {
        badgeColor = const Color(0xFFD97706);
      }
    }

    final orderMark = hasReturn
        ? (latestReturn.status == 'Refund Processed'
            ? Icons.verified
            : latestReturn.status == 'Rejected'
            ? Icons.cancel
            : Icons.autorenew)
        : (order.orderStatus == 'Delivered'
            ? Icons.check_circle
            : order.orderStatus == 'Cancelled'
            ? Icons.cancel
            : Icons.schedule);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: hasReturn ? badgeColor.withValues(alpha: 0.35) : AppColors.border,
          width: hasReturn ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header with details tap
          InkWell(
            onTap: () => Get.toNamed(AppRoutes.orderDetails, arguments: order),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    firstItem?.imageUrl ??
                        'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=200',
                    width: 70,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 75,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem?.productName ?? 'Fashion Apparel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.trackingNumber,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${order.totalAmount.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            orderMark,
                            color: badgeColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              hasReturn
                                  ? 'Return: ${latestReturn.status}'
                                  : '${order.orderStatus} • ${order.estimatedDelivery.isNotEmpty ? order.estimatedDelivery : "Arriving soon"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),

          if (hasReturn) ...[
            const SizedBox(height: 10),
            _buildReturnUpdate(latestReturn),
          ],

          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Direct Action Buttons
          if (hasReturn) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Get.toNamed(AppRoutes.returnRefund, arguments: order),
                    icon: const Icon(Icons.rotate_left_rounded, size: 16),
                    label: const Text(
                      'Track Return & Refund',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Get.toNamed(AppRoutes.orderDetails, arguments: order),
                    icon: const Icon(Icons.receipt_long_outlined, size: 16),
                    label: const Text(
                      'View Details',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () =>
                  Get.toNamed(AppRoutes.orderTracking, arguments: order),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_shipping_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      'Delivery tracking (${order.orderStatus})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Get.toNamed(AppRoutes.orderTracking, arguments: order),
                    icon: const Icon(Icons.local_shipping_outlined, size: 16),
                    label: const Text(
                      'Track Order',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Get.toNamed(AppRoutes.orderDetails, arguments: order),
                    icon: const Icon(Icons.receipt_long_outlined, size: 16),
                    label: const Text(
                      'View Details',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (order.returnEligible) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () =>
                      Get.toNamed(AppRoutes.returnRefund, arguments: order),
                  icon: const Icon(Icons.assignment_return_outlined,
                      size: 14, color: AppColors.primary),
                  label: const Text(
                    'Return or Replace Items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildReturnUpdate(ReturnRequestModel request) {
    final status = request.status;
    final isComplete = status == 'Refund Processed';
    final isRejected = status == 'Rejected';
    final color = isComplete
        ? const Color(0xFF15803D)
        : isRejected
        ? const Color(0xFFB91C1C)
        : const Color(0xFFB45309);
    final background = isComplete
        ? const Color(0xFFF0FDF4)
        : isRejected
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFFFFBEB);
    final icon = isComplete
        ? Icons.check_circle
        : isRejected
        ? Icons.cancel
        : Icons.autorenew;
    final latestNote = request.timeline.isEmpty
        ? 'Return requested. Our team will update you on pickup and refund.'
        : request.timeline.last.note;

    // Mini 4-stage stepper status
    final steps = ['Requested', 'Pickup', 'Received', 'Refunded'];
    int activeIdx = 0;
    if (status == 'Pickup Scheduled') activeIdx = 1;
    if (status == 'Pickup Received' || status == 'Refund Pending') activeIdx = 2;
    if (status == 'Refund Processed') activeIdx = 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Return ${request.status} • Refund ₹${request.refundAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      latestNote,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (isComplete) Icon(Icons.verified, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 10),
          // Mini visual return flow line
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final lineIdx = i ~/ 2;
                final isDone = activeIdx > lineIdx;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isDone ? color : const Color(0xFFCBD5E1),
                  ),
                );
              }
              final stepIdx = i ~/ 2;
              final isDone = activeIdx >= stepIdx;
              final isCurrent = activeIdx == stepIdx;
              return Column(
                children: [
                  Container(
                    width: isCurrent ? 14 : 10,
                    height: isCurrent ? 14 : 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? color : Colors.white,
                      border: Border.all(
                        color: isDone ? color : const Color(0xFF94A3B8),
                        width: 2,
                      ),
                    ),
                    child: isDone && !isCurrent
                        ? const Icon(Icons.check, size: 6, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[stepIdx],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                      color: isDone ? color : AppColors.textMuted,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
