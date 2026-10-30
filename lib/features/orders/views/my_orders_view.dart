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

    final tabs = ['All', 'Processing', 'Shipped', 'Delivered'];

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
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              // Filter Tabs (All, Processing, Shipped, Delivered) matching Screen 15
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: tabs.map((tab) {
                    return Obx(() {
                      final isSel = controller.selectedFilter.value == tab;
                      return GestureDetector(
                        onTap: () {
                          controller.selectedFilter.value = tab;
                          controller.fetchOrders();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSel ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),
              ),

              // Orders List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (controller.orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'No orders found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Looks like you haven\'t placed any orders yet.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Get.offAllNamed(AppRoutes.home),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Start Shopping'),
                          ),
                        ],
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

    Color badgeColor = Colors.orange;
    if (['Picked Up', 'Shipped', 'In Transit', 'Out for Delivery'].contains(order.orderStatus)) badgeColor = Colors.blue;
    if (order.orderStatus == 'Delivered') badgeColor = Colors.green;
    if (order.orderStatus == 'Cancelled') badgeColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
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
                    firstItem?.imageUrl ?? 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=200',
                    width: 70,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 70, height: 75, color: AppColors.primaryLight),
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
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.trackingNumber,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${order.totalAmount.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${order.orderStatus} • ${order.estimatedDelivery.isNotEmpty ? order.estimatedDelivery : "Arriving soon"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: badgeColor),
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

          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Direct Action Buttons: Track Order & Details
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.orderTracking, arguments: order),
                  icon: const Icon(Icons.local_shipping_outlined, size: 16),
                  label: const Text('Track Order', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.orderDetails, arguments: order),
                  icon: const Icon(Icons.receipt_long_outlined, size: 16),
                  label: const Text('View Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
