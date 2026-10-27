import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
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
            if (Navigator.canPop(context)) Get.back();
          },
        ),
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: Column(
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

          // Orders List matching Screen 15
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (controller.orders.isEmpty) {
                return const Center(child: Text('No orders found'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, idx) {
                  final order = controller.orders[idx];
                  return _buildOrderCard(order);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    Color badgeColor = Colors.orange;
    if (order.orderStatus == 'Shipped') badgeColor = Colors.blue;
    if (order.orderStatus == 'Delivered') badgeColor = Colors.green;
    if (order.orderStatus == 'Cancelled') badgeColor = Colors.red;

    return InkWell(
      onTap: () => Get.toNamed('/order-details', arguments: order.id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
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
                      Text(
                        '${order.orderStatus} • ${order.estimatedDelivery.isNotEmpty ? order.estimatedDelivery : "Arriving soon"}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: badgeColor),
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
    );
  }
}
