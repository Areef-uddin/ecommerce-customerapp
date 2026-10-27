import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/orders_controller.dart';

class OrderTrackingView extends StatefulWidget {
  const OrderTrackingView({super.key});

  @override
  State<OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends State<OrderTrackingView> {
  final controller = Get.put(OrdersController());

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
        title: const Text('Order Tracking', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final order = controller.currentOrder.value;
        if (order == null) {
          return const Center(child: Text('Order not found'));
        }

        final steps = [
          {'title': 'Order Placed', 'date': '28 Oct'},
          {'title': 'Packed', 'date': '29 Oct'},
          {'title': 'Shipped', 'date': '30 Oct'},
          {'title': 'Out for Delivery', 'date': '31 Oct'},
          {'title': 'Delivered', 'date': 'Delivered'},
        ];

        int currentStepIndex = 2;
        if (order.orderStatus == 'Placed') currentStepIndex = 0;
        if (order.orderStatus == 'Packed') currentStepIndex = 1;
        if (order.orderStatus == 'Shipped') currentStepIndex = 2;
        if (order.orderStatus == 'Out for Delivery') currentStepIndex = 3;
        if (order.orderStatus == 'Delivered') currentStepIndex = 4;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal Timeline Progress matching Screen 14
              SizedBox(
                height: 70,
                child: Row(
                  children: List.generate(steps.length, (idx) {
                    final isCompleted = idx <= currentStepIndex;
                    final isLast = idx == steps.length - 1;

                    return Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompleted ? AppColors.primary : Colors.grey.shade300,
                                ),
                                child: isCompleted
                                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                                    : null,
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    height: 3,
                                    color: idx < currentStepIndex ? AppColors.primary : Colors.grey.shade300,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            steps[idx]['title']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                              color: isCompleted ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ),
                          Text(
                            steps[idx]['date']!,
                            style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // Status Banner with Truck Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_shipping, color: Color(0xFFD97706), size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Out for Delivery', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          SizedBox(height: 2),
                          Text(
                            'Your order is on the way\nExpected today by 7 PM',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Delivery Partner Card matching Screen 14
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200'),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Delivery Partner', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          Row(
                            children: [
                              Text(
                                order.deliveryPartnerName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.star, size: 14, color: AppColors.star),
                              Text(
                                '${order.deliveryPartnerRating}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${order.deliveryPartnerVehicle} • ${order.deliveryPartnerPhone}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Delivery Address with Map Pin icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            order.deliveryAddress,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View Map', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
