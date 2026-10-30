import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';

import '../../../core/routes/app_routes.dart';

class ReturnRefundView extends StatelessWidget {
  const ReturnRefundView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());
    final int orderId = Get.arguments is int
        ? Get.arguments as int
        : controller.currentOrder.value?.id ?? 0;
    if (controller.currentOrder.value?.id != orderId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchOrderDetail(orderId, silent: true);
      });
    }

    final reasons = [
      'Size too small',
      'Size too large',
      'Defective product or stitching issue',
      'Wrong color or item delivered',
      'Quality not as expected',
    ];

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
          'Return / Refund',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final order = controller.currentOrder.value;
              if (order == null ||
                  order.id != orderId ||
                  order.returnEligible) {
                return const SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Text(
                  'This order is outside the 7-day return window, so a new return cannot be started.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9A3412)),
                ),
              );
            }),
            // Step 1: Select Item
            _buildStepHeader(
              '1',
              'Select Item',
              'Choose the item you want to return',
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFFFF1F2),
              ),
              child: Obx(() {
                final order = controller.currentOrder.value;
                if (order == null ||
                    order.id != orderId ||
                    order.items.isEmpty) {
                  return const Text(
                    'Loading items…',
                    style: TextStyle(color: AppColors.textSecondary),
                  );
                }
                return Column(
                  children: order.items.map((item) {
                    final selected =
                        controller.selectedReturnItemId.value == item.id;
                    return InkWell(
                      onTap: () =>
                          controller.selectedReturnItemId.value = item.id,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '₹${(item.price * item.quantity).toStringAsFixed(0)} • Qty: ${item.quantity} • Size: ${item.size}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Step 2: Select Reason
            _buildStepHeader(
              '2',
              'Select Reason',
              'Tell us why you are returning',
            ),
            Obx(
              () => Column(
                children: reasons.map((r) {
                  final isSel = controller.selectedReason.value == r;
                  return GestureDetector(
                    onTap: () => controller.selectedReason.value = r,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSel ? AppColors.primary : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                width: isSel ? 5 : 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              r,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Step 3: Pickup / Drop
            _buildStepHeader('3', 'Pickup / Drop', 'We will arrange a pickup'),
            Obx(
              () => Row(
                children: ['Pickup', 'Drop at Store'].map((mode) {
                  final isSel = controller.pickupType.value == mode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pickupType.value = mode,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primaryLight : Colors.white,
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            mode,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isSel
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Step 4: Refund
            _buildStepHeader(
              '4',
              'Refund',
              'Final amount confirmed after return review',
            ),
            Obx(() {
              final order = controller.currentOrder.value;
              final item = order?.items.firstWhereOrNull(
                (i) => i.id == controller.selectedReturnItemId.value,
              );
              final subtotal = item == null ? 0.0 : item.price * item.quantity;
              final estimated = order == null || order.itemTotal <= 0
                  ? subtotal
                  : (subtotal -
                            (order.discountAmount * subtotal / order.itemTotal))
                        .clamp(0.0, subtotal);
              final cod =
                  order?.paymentMethod == 'Cash on Delivery' ||
                  order?.paymentMethod == 'COD';
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Estimated refund ₹${estimated.toStringAsFixed(2)} after item discount. '
                        '${cod ? 'COD refunds are transferred manually after approval.' : 'Approved online refunds go to the original payment method.'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),

            Obx(() {
              final order = controller.currentOrder.value;
              final itemId = controller.selectedReturnItemId.value;
              final matches =
                  order?.returns
                      .where((request) => request.orderItemId == itemId)
                      .toList() ??
                  <ReturnRequestModel>[];
              return matches.isEmpty
                  ? const SizedBox.shrink()
                  : _buildReturnStatus(matches.last);
            }),
            const SizedBox(height: 16),

            // Initiate Return Button
            Obx(() {
              final order = controller.currentOrder.value;
              final itemId = controller.selectedReturnItemId.value;
              final matches =
                  order?.returns
                      .where((request) => request.orderItemId == itemId)
                      .toList() ??
                  <ReturnRequestModel>[];
              final currentReturn = matches.isEmpty ? null : matches.last;
              final alreadyOpen =
                  currentReturn != null && currentReturn.status != 'Rejected';
              final eligible = order?.returnEligible == true;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      controller.isSubmittingReturn.value ||
                          !eligible ||
                          itemId == null ||
                          alreadyOpen
                      ? null
                      : () => controller.initiateReturn(orderId),
                  child: controller.isSubmittingReturn.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          alreadyOpen
                              ? 'Return ${currentReturn.status}'
                              : currentReturn?.status == 'Rejected'
                              ? 'Request Return Again'
                              : 'Initiate Return',
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(String number, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReturnStatus(ReturnRequestModel request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Return status: ${request.status}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Estimated refund ₹${request.refundAmount.toStringAsFixed(2)} • ${request.pickupType}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          ...request.timeline.map(
            (event) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${event.status} — ${event.note}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
