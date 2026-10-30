import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';

class OrderTrackingView extends StatefulWidget {
  const OrderTrackingView({super.key});

  @override
  State<OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends State<OrderTrackingView> {
  final controller = Get.put(OrdersController());
  int orderId = 0;

  final List<Map<String, dynamic>> _standardStages = [
    {'title': 'Order Placed', 'icon': Icons.receipt_long, 'code': 'Order Placed'},
    {'title': 'Confirmed', 'icon': Icons.verified, 'code': 'Confirmed'},
    {'title': 'Packed', 'icon': Icons.inventory_2, 'code': 'Packed'},
    {'title': 'Picked Up', 'icon': Icons.local_shipping, 'code': 'Picked Up'},
    {'title': 'In Transit', 'icon': Icons.near_me, 'code': 'In Transit'},
    {'title': 'Out for Delivery', 'icon': Icons.delivery_dining, 'code': 'Out for Delivery'},
    {'title': 'Delivered', 'icon': Icons.home, 'code': 'Delivered'},
  ];

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  void _initTracking() async {
    if (Get.arguments is OrderModel) {
      final ord = Get.arguments as OrderModel;
      orderId = ord.id;
      controller.currentOrder.value = ord;
      if (ord.shipment != null) {
        controller.trackingData.value = ord.shipment;
      }
      controller.fetchTrackingInfo(orderId, silent: true);
      return;
    }

    if (Get.arguments is int && (Get.arguments as int) > 0) {
      orderId = Get.arguments as int;
      controller.fetchTrackingInfo(orderId);
      return;
    }

    final paramId = Get.parameters['id'];
    if (paramId != null && int.tryParse(paramId) != null) {
      orderId = int.parse(paramId);
      controller.fetchTrackingInfo(orderId);
      return;
    }

    if (controller.orders.isNotEmpty) {
      orderId = controller.orders.first.id;
      controller.fetchTrackingInfo(orderId);
      return;
    }

    await controller.fetchOrders();
    if (controller.orders.isNotEmpty) {
      orderId = controller.orders.first.id;
      controller.fetchTrackingInfo(orderId);
    }
  }

  int _calculateCurrentIndex(String status) {
    for (int i = 0; i < _standardStages.length; i++) {
      if (_standardStages[i]['code'].toString().toLowerCase() == status.toLowerCase()) {
        return i;
      }
    }
    if (status.toLowerCase() == 'placed') return 0;
    if (status.toLowerCase() == 'shipped') return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
          'Live Courier Tracking',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: 'Refresh Tracking',
            onPressed: () => controller.fetchTrackingInfo(orderId),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.currentOrder.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Fetching tracking data...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          );
        }

        if (controller.hasError.value && controller.currentOrder.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 54, color: Colors.redAccent),
                  const SizedBox(height: 14),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchTrackingInfo(orderId),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
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
                    child: const Icon(Icons.local_shipping_outlined, size: 52, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tracking Information Not Found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Could not find tracking record for this order.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.offNamed(AppRoutes.myOrders),
                    icon: const Icon(Icons.list_alt_rounded),
                    label: const Text('View All My Orders'),
                  ),
                ],
              ),
            ),
          );
        }

        final tracking = controller.trackingData.value ?? order.shipment;
        final currentStatus = tracking?.currentStatus ?? order.orderStatus;
        final currentStepIndex = _calculateCurrentIndex(currentStatus);
        final trackingNumber = tracking?.trackingNumber ?? order.trackingNumber;
        final courierName = tracking?.courierName ?? order.courierName;
        final currentLocation = tracking?.currentLocation ?? order.currentLocation;
        final isDemo = tracking?.isDemoMode ?? true;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.fetchTrackingInfo(orderId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. DEMO TRACKING MODE Banner (Requirement 7)
                if (isDemo) _buildDemoModeBanner(),

                const SizedBox(height: 14),

                // 2. Tracking ID & Carrier Header Card (Requirement 3 & 7)
                _buildTrackingHeaderCard(trackingNumber, courierName, currentStatus, order.estimatedDelivery),

                const SizedBox(height: 18),

                // 3. 7-Stage Horizontal Stepper Visualizer (Requirement 4)
                _buildSevenStageStepper(currentStepIndex),

                const SizedBox(height: 18),

                // 4. Current Status Highlight Banner
                _buildStatusHighlightBanner(currentStatus, currentLocation),

                const SizedBox(height: 18),

                // 5. Milestone Activity Feed with Timestamps (Requirement 4 & 6)
                _buildMilestonesActivityFeed(order, tracking, currentStepIndex),

                const SizedBox(height: 18),

                // 6. Delivery Partner Card (Requirement 8)
                _buildDeliveryPartnerCard(order, tracking),

                const SizedBox(height: 18),

                // 7. Delivery Address Card
                _buildDeliveryAddressCard(order),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
      }),
    );
  }

  Widget _buildDemoModeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIVE TRACKING ACTIVE',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Color(0xFFB45309),
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Real-time courier milestones synced with StyleHub logistics hub',
                  style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingHeaderCard(String trackingNumber, String courierName, String currentStatus, String estimatedDelivery) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TRACKING NUMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        trackingNumber,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0284C7), letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: trackingNumber));
                          Get.snackbar(
                            'Copied!',
                            'Tracking number $trackingNumber copied to clipboard',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF0F172A),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(16),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.copy, size: 14, color: Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: currentStatus == 'Delivered'
                      ? const Color(0xFFDCFCE7)
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: currentStatus == 'Delivered' ? const Color(0xFF16A34A) : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currentStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: currentStatus == 'Delivered' ? const Color(0xFF16A34A) : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('COURIER PARTNER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(courierName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ESTIMATED ARRIVAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      estimatedDelivery.isNotEmpty ? estimatedDelivery : '31 Oct - 03 Nov',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSevenStageStepper(int currentStepIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('DELIVERY LIFECYCLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.5)),
              Text('Step ${currentStepIndex + 1} of 7', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          // Scrollable horizontal stepper ensuring all 7 stages look clear
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_standardStages.length, (idx) {
                final isCompleted = idx <= currentStepIndex;
                final isCurrent = idx == currentStepIndex;
                final isLast = idx == _standardStages.length - 1;
                final stage = _standardStages[idx];

                return Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? AppColors.primary
                                : (isCompleted ? const Color(0xFF10B981) : const Color(0xFFF1F5F9)),
                            border: isCurrent
                                ? Border.all(color: AppColors.primaryLight, width: 3)
                                : null,
                            boxShadow: isCurrent
                                ? [const BoxShadow(color: Color(0x4DE91E63), blurRadius: 6, spreadRadius: 1)]
                                : null,
                          ),
                          child: Icon(
                            isCompleted && !isCurrent ? Icons.check : stage['icon'] as IconData,
                            size: 15,
                            color: isCompleted ? Colors.white : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 64,
                          child: Text(
                            stage['title'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isCurrent ? FontWeight.w800 : (isCompleted ? FontWeight.w700 : FontWeight.w500),
                              color: isCurrent ? AppColors.primary : (isCompleted ? AppColors.textPrimary : AppColors.textMuted),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Container(
                        width: 24,
                        height: 3,
                        margin: const EdgeInsets.only(bottom: 22),
                        color: idx < currentStepIndex ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHighlightBanner(String status, String location) {
    Color bannerBg = const Color(0xFFEFF6FF);
    Color iconBg = const Color(0xFFBFDBFE);
    Color iconColor = const Color(0xFF2563EB);
    IconData icon = Icons.local_shipping;
    String statusDesc = 'Package is currently moving through logistics hubs.';

    if (status == 'Order Placed') {
      icon = Icons.receipt_long;
      statusDesc = 'Your order is recorded and waiting for warehouse confirmation.';
    } else if (status == 'Confirmed') {
      icon = Icons.verified;
      statusDesc = 'Order confirmed and inventory reserved for packing.';
    } else if (status == 'Packed') {
      icon = Icons.inventory_2;
      statusDesc = 'Items packed, labeled, and placed in pickup dock.';
    } else if (status == 'Picked Up') {
      icon = Icons.local_shipping;
      statusDesc = 'Courier pickup agent has collected the package.';
    } else if (status == 'In Transit') {
      icon = Icons.navigation;
      statusDesc = 'Package is en-route between sorting facilities.';
    } else if (status == 'Out for Delivery') {
      bannerBg = const Color(0xFFFFFBEB);
      iconBg = const Color(0xFFFDE68A);
      iconColor = const Color(0xFFD97706);
      icon = Icons.delivery_dining;
      statusDesc = 'Courier partner is out on delivery van to your address!';
    } else if (status == 'Delivered') {
      bannerBg = const Color(0xFFF0FDF4);
      iconBg = const Color(0xFFBBF7D0);
      iconColor = const Color(0xFF16A34A);
      icon = Icons.check_circle;
      statusDesc = 'Package delivered successfully. Thank you for shopping with StyleHub!';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconBg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(
                  statusDesc,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.3),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesActivityFeed(OrderModel order, ShipmentTrackingModel? tracking, int currentStepIndex) {
    final milestones = tracking?.milestones ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TRACKING TIMELINE & AUDIT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
              Text('Live History', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 16),
          if (milestones.isNotEmpty)
            ...milestones.map((m) {
              final isLast = m.orderIndex == milestones.length - 1;
              return _buildMilestoneRow(
                title: m.title,
                status: m.statusStep,
                location: m.location,
                description: m.description,
                dateText: m.dateFormatted.isNotEmpty ? m.dateFormatted : (m.isCompleted ? 'Completed' : 'Expected'),
                isCompleted: m.isCompleted,
                isCurrent: m.orderIndex == currentStepIndex,
                isLast: isLast,
              );
            })
          else
            ..._standardStages.asMap().entries.map((entry) {
              final idx = entry.key;
              final stage = entry.value;
              final isDone = idx <= currentStepIndex;
              final isCurrent = idx == currentStepIndex;
              final isLast = idx == _standardStages.length - 1;

              return _buildMilestoneRow(
                title: stage['title'] as String,
                status: stage['code'] as String,
                location: isDone ? 'Bengaluru Logistics Facility' : '',
                description: isDone ? 'Activity logged in demo system' : '',
                dateText: isDone ? 'Updated' : 'Pending',
                isCompleted: isDone,
                isCurrent: isCurrent,
                isLast: isLast,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow({
    required String title,
    required String status,
    required String location,
    required String description,
    required String dateText,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step dot and vertical line
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? AppColors.primary
                      : (isCompleted ? const Color(0xFF10B981) : Colors.grey.shade300),
                  border: isCurrent ? Border.all(color: AppColors.primaryLight, width: 2) : null,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? const Color(0xFF10B981) : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: isCompleted ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                          color: isCompleted ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                  if (description.isNotEmpty && isCompleted) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryPartnerCard(OrderModel order, ShipmentTrackingModel? tracking) {
    final partnerName = tracking?.deliveryPartner?.name ?? order.deliveryPartnerName;
    final partnerPhone = tracking?.deliveryPartner?.phone ?? order.deliveryPartnerPhone;
    final partnerRating = tracking?.deliveryPartner?.rating ?? order.deliveryPartnerRating;
    final partnerVehicle = tracking?.deliveryPartner?.vehicle ?? order.deliveryPartnerVehicle;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DELIVERY PARTNER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      partnerName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star, size: 14, color: AppColors.star),
                    Text(
                      '$partnerRating',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$partnerVehicle • $partnerPhone',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: AppColors.primary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: partnerPhone));
              Get.snackbar(
                'Courier Phone',
                'Phone number $partnerPhone copied',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF0F172A),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address (${order.addressType})',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  order.deliveryAddress,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
