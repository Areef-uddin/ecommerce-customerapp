import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/orders_controller.dart';

class ReturnRefundView extends StatelessWidget {
  const ReturnRefundView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final int orderId = Get.arguments as int? ?? 1;

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
          onPressed: () => Get.back(),
        ),
        title: const Text('Return / Refund', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Select Item
            _buildStepHeader('1', 'Select Item', 'Choose the item you want to return'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFFFF1F2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Floral Maxi Dress', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('₹1,299 • Size: M', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step 2: Select Reason
            _buildStepHeader('2', 'Select Reason', 'Tell us why you are returning'),
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
                        border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isSel ? AppColors.primary : AppColors.textMuted, width: isSel ? 5 : 1.5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(r, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
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
                          border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            mode,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isSel ? AppColors.primary : AppColors.textPrimary,
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
            _buildStepHeader('4', 'Refund', 'Refund after pickup (3-5 days)'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Full refund of ₹1,299 will be transferred to your original payment method.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Initiate Return Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSubmittingReturn.value ? null : () => controller.initiateReturn(orderId),
                  child: controller.isSubmittingReturn.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Initiate Return'),
                ),
              ),
            ),
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
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
