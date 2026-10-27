import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/orders_controller.dart';

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({super.key});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  final controller = Get.find<OrdersController>();

  @override
  void initState() {
    super.initState();
    final int orderId = Get.arguments as int? ?? 1;
    controller.fetchOrderDetail(orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Order Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final order = controller.currentOrder.value;
        if (order == null) return const Center(child: Text('Order not found'));

        final firstItem = order.items.isNotEmpty ? order.items.first : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          errorBuilder: (_, _, _) => Container(width: 70, height: 75, color: AppColors.primaryLight),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstItem.productName,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${firstItem.price.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Size: ${firstItem.size} | Color: ${firstItem.color} | Qty: ${firstItem.quantity}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Get.toNamed('/cart'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Buy Again', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
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
                        Text('Need to return this item?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('7-day return guarantee available', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/return-refund', arguments: order.id),
                      child: const Text('Return / Refund', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Vertical Tracking Stepper matching Screen 16
              const Text('Timeline Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ...order.timeline.map((step) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: step.isCompleted ? AppColors.success : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: step.isCompleted
                              ? const Icon(Icons.check, size: 10, color: Colors.white)
                              : null,
                        ),
                        Container(
                          width: 2,
                          height: 38,
                          color: step.isCompleted ? AppColors.success : Colors.grey.shade300,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.statusStep,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: step.isCompleted ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.dateText,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),

              // Track Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/order-tracking', arguments: order.id),
                  child: const Text('Track Order'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
