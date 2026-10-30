import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';

class ReturnRefundView extends StatelessWidget {
  const ReturnRefundView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());

    int orderId = 0;
    if (Get.arguments is OrderModel) {
      final ord = Get.arguments as OrderModel;
      orderId = ord.id;
      controller.currentOrder.value = ord;
    } else if (Get.arguments is int && (Get.arguments as int) > 0) {
      orderId = Get.arguments as int;
    } else if (Get.parameters['id'] != null &&
        int.tryParse(Get.parameters['id']!) != null) {
      orderId = int.parse(Get.parameters['id']!);
    } else if (controller.currentOrder.value != null) {
      orderId = controller.currentOrder.value!.id;
    }

    if (orderId > 0 &&
        (controller.currentOrder.value == null ||
            controller.currentOrder.value!.id != orderId)) {
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offNamed(AppRoutes.myOrders);
            }
          },
        ),
        title: const Text(
          'Return & Refund',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () {
              if (orderId > 0) {
                controller.fetchOrderDetail(orderId);
                controller.fetchOrders(silent: true);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final order = controller.currentOrder.value;

        if (controller.isLoading.value && order == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (order == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 56,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Order not found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Could not locate details for this return request.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => Get.offNamed(AppRoutes.myOrders),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Back to My Orders'),
                  ),
                ],
              ),
            ),
          );
        }

        // Check if this order already has an active or completed return request
        final hasActiveReturn = order.returns.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: hasActiveReturn
                  ? _buildReturnFlowTracker(context, order, controller)
                  : _buildReturnRequestForm(context, order, controller, reasons),
            ),
          ),
        );
      }),
    );
  }

  // -------------------------------------------------------------
  // VIEW A: LIVE RETURN & REFUND FLOW TRACKER
  // -------------------------------------------------------------
  Widget _buildReturnFlowTracker(
    BuildContext context,
    OrderModel order,
    OrdersController controller,
  ) {
    final returnRequest = order.returns.first;
    final status = returnRequest.status;
    final isComplete = status == 'Refund Processed';
    final isRejected = status == 'Rejected';

    Color themeColor = const Color(0xFFD97706); // Amber default for in-progress
    Color bgColor = const Color(0xFFFFFBEB);
    IconData statusIcon = Icons.autorenew;

    if (isComplete) {
      themeColor = const Color(0xFF15803D);
      bgColor = const Color(0xFFF0FDF4);
      statusIcon = Icons.verified;
    } else if (isRejected) {
      themeColor = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFEF2F2);
      statusIcon = Icons.cancel;
    } else if (status == 'Pickup Received' || status == 'Refund Pending') {
      themeColor = const Color(0xFF2563EB);
      bgColor = const Color(0xFFEFF6FF);
      statusIcon = Icons.inventory;
    }

    // Match order item
    final item = order.items.firstWhereOrNull(
      (i) => i.id == returnRequest.orderItemId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Status Banner Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeColor.withValues(alpha: 0.3)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: themeColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Return Status: $status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: themeColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Order ${order.orderNumber} • ${returnRequest.pickupType}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${returnRequest.refundAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: themeColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        returnRequest.timeline.isNotEmpty
                            ? returnRequest.timeline.last.note
                            : 'Return request is currently under review by StyleHub logistics.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. Returned Item Card
        if (item != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.imageUrl,
                    width: 65,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 65,
                      height: 70,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
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
                      const SizedBox(height: 3),
                      Text(
                        'Size: ${item.size} • Color: ${item.color} • Qty: ${item.quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reason: ${returnRequest.reason}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${(item.price * item.quantity).toInt()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 3. Return & Refund Progression Stepper Flow
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.timeline, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Return & Refund Tracking Flow',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Follow each step of your return from pickup to refund',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),

              _buildReturnFlowStages(returnRequest, order),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. Refund Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Refund Information',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _buildRefundRow('Refund Amount',
                  '₹${returnRequest.refundAmount.toStringAsFixed(2)}',
                  isBold: true, highlight: true),
              const SizedBox(height: 8),
              _buildRefundRow('Original Payment Mode', order.paymentMethod),
              const SizedBox(height: 8),
              _buildRefundRow('Payment Status', order.paymentStatus),
              const SizedBox(height: 8),
              _buildRefundRow(
                'Refund Target',
                order.paymentMethod == 'Cash on Delivery' ||
                        order.paymentMethod == 'COD'
                    ? 'Bank Transfer / Store Credit'
                    : 'Original ${order.paymentMethod} account',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 16, color: Color(0xFF0284C7)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isComplete
                            ? 'Refund has been completed. Check your bank or statement for confirmation.'
                            : 'Once item pickup is verified, the refund is processed directly to your account.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 5. Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    Get.toNamed(AppRoutes.orderDetails, arguments: order),
                icon: const Icon(Icons.receipt_long, size: 16),
                label: const Text('Order Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    Get.toNamed(AppRoutes.orderTracking, arguments: order),
                icon: const Icon(Icons.local_shipping_outlined, size: 16),
                label: const Text('Delivery Info'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () => Get.offNamed(AppRoutes.myOrders),
            icon: const Icon(Icons.arrow_back, size: 14),
            label: const Text('Back to My Orders'),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // RETURN FLOW STAGES STEPPER
  // -------------------------------------------------------------
  Widget _buildReturnFlowStages(ReturnRequestModel request, OrderModel order) {
    final status = request.status;
    final isRejected = status == 'Rejected';

    int currentStageIdx = 0;
    if (status == 'Pickup Scheduled') currentStageIdx = 1;
    if (status == 'Pickup Received') currentStageIdx = 2;
    if (status == 'Refund Pending') currentStageIdx = 2;
    if (status == 'Refund Processed') currentStageIdx = 3;

    final stages = [
      {
        'title': 'Return Initiated',
        'desc': 'Return request submitted by customer.',
        'detail': 'Reason: ${request.reason}',
        'date': request.createdAt.isNotEmpty
            ? request.createdAt.substring(0, 10)
            : 'Submitted',
      },
      {
        'title': 'Pickup Scheduled',
        'desc': 'StyleHub logistics scheduled courier pickup.',
        'detail': 'Type: ${request.pickupType}',
        'date': status != 'Initiated' ? 'Scheduled' : 'Pending scheduling',
      },
      {
        'title': 'Pickup Received & Inspected',
        'desc': 'Item received at hub and quality check completed.',
        'detail': 'Inspection: Verified items against return policy',
        'date': (status == 'Pickup Received' ||
                status == 'Refund Pending' ||
                status == 'Refund Processed')
            ? 'Received & Verified'
            : 'Pending pickup',
      },
      {
        'title': 'Refund Processed',
        'desc':
            'Refund of ₹${request.refundAmount.toStringAsFixed(2)} processed.',
        'detail': 'To original payment method (${order.paymentMethod})',
        'date': status == 'Refund Processed'
            ? 'Completed'
            : status == 'Refund Pending'
            ? 'Processing in bank'
            : 'Pending inspection',
      },
    ];

    if (isRejected) {
      stages.add({
        'title': 'Return Rejected',
        'desc': 'Return request could not be processed.',
        'detail': 'Contact customer support for more information.',
        'date': 'Closed',
      });
    }

    return Column(
      children: List.generate(stages.length, (idx) {
        final stage = stages[idx];
        final isLast = idx == stages.length - 1;

        bool isDone = false;
        bool isActive = false;

        if (isRejected && idx == stages.length - 1) {
          isDone = true;
          isActive = true;
        } else if (!isRejected) {
          isDone = currentStageIdx >= idx;
          isActive = currentStageIdx == idx;
        }

        // Timeline note match if available
        String? timelineNote;
        for (final ev in request.timeline) {
          if (ev.status.toLowerCase().contains(
                stage['title']!.toLowerCase().split(' ').first,
              )) {
            timelineNote = ev.note;
          }
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column with Circle Indicator and connecting line
              Column(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRejected && idx == stages.length - 1
                          ? const Color(0xFFDC2626)
                          : isDone
                          ? const Color(0xFF15803D)
                          : (isActive
                              ? const Color(0xFFD97706)
                              : const Color(0xFFE2E8F0)),
                      border: Border.all(
                        color: isActive ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: (isRejected
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFFD97706))
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : (isActive
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  '${idx + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                )),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isDone && currentStageIdx > idx
                            ? const Color(0xFF15803D)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Content of the stage
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stage['title']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isActive ? FontWeight.w800 : FontWeight.w700,
                              color: isDone || isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                          ),
                          Text(
                            stage['date']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? const Color(0xFFD97706)
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        timelineNote ?? stage['desc']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDone || isActive
                              ? AppColors.textSecondary
                              : AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                      if (stage['detail']!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          stage['detail']!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDone || isActive
                                ? const Color(0xFF475569)
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRefundRow(String label, String value,
      {bool isBold = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 15 : 13,
            fontWeight:
                isBold || highlight ? FontWeight.w800 : FontWeight.w600,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // VIEW B: RETURN REQUEST INITIATION FORM (For New Returns)
  // -------------------------------------------------------------
  Widget _buildReturnRequestForm(
    BuildContext context,
    OrderModel order,
    OrdersController controller,
    List<String> reasons,
  ) {
    final eligible = order.returnEligible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!eligible)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: const Text(
              'This order is outside the 7-day return window. New returns can only be requested within 7 days of delivery.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9A3412)),
            ),
          ),

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
          child: Column(
            children: order.items.map((item) {
              return Obx(() {
                final selected =
                    controller.selectedReturnItemId.value == item.id;
                return InkWell(
                  onTap: () => controller.selectedReturnItemId.value = item.id,
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl,
                            width: 50,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 54,
                              color: AppColors.primaryLight,
                            ),
                          ),
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
              });
            }).toList(),
          ),
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
                    color: Colors.white,
                    border: Border.all(
                      color: isSel ? AppColors.primary : AppColors.border,
                      width: isSel ? 1.5 : 1,
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSel ? FontWeight.w700 : FontWeight.w600,
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
                        width: isSel ? 1.5 : 1,
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
          'Refund Estimation',
          'Final amount confirmed upon quality review',
        ),
        Obx(() {
          final item = order.items.firstWhereOrNull(
            (i) => i.id == controller.selectedReturnItemId.value,
          );
          final subtotal = item == null ? 0.0 : item.price * item.quantity;
          final estimated = order.itemTotal <= 0
              ? subtotal
              : (subtotal - (order.discountAmount * subtotal / order.itemTotal))
                  .clamp(0.0, subtotal);
          final cod = order.paymentMethod == 'Cash on Delivery' ||
              order.paymentMethod == 'COD';
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
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
                    '${cod ? 'COD refunds are transferred manually to your bank after approval.' : 'Approved online refunds are returned to the original payment source.'}',
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

        // Initiate Return Button
        Obx(() {
          final itemId = controller.selectedReturnItemId.value;
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: !eligible ||
                      itemId == null ||
                      controller.isSubmittingReturn.value
                  ? null
                  : () => controller.initiateReturn(order.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isSubmittingReturn.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit Return Request',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          );
        }),
      ],
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
}
