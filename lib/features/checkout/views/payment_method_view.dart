import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/checkout_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class PaymentMethodView extends StatelessWidget {
  const PaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    final checkoutController = Get.find<CheckoutController>();
    final cartController = Get.find<CartController>();

    final paymentOptions = [
      {'name': 'Razorpay', 'desc': 'UPI, Cards, Net Banking (Instant & Secure)', 'icon': Icons.bolt, 'isRazorpay': true},
      {'name': 'UPI', 'desc': 'Pay with GPay, PhonePe, Paytm', 'icon': Icons.account_balance_wallet_outlined, 'isRazorpay': false},
      {'name': 'Credit / Debit Card', 'desc': 'Visa, Mastercard, Rupay', 'icon': Icons.credit_card_outlined, 'isRazorpay': false},
      {'name': 'Net Banking', 'desc': 'All major banks', 'icon': Icons.account_balance_outlined, 'isRazorpay': false},
      {'name': 'Cash on Delivery', 'desc': 'Pay at your doorstep', 'icon': Icons.money_outlined, 'isRazorpay': false},
    ];

    final total = cartController.cartSummary.value?.finalTotal.toInt() ?? 2998;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: paymentOptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final opt = paymentOptions[idx];
                  return Obx(() {
                    final isSel = checkoutController.selectedPaymentMethod.value == opt['name'];

                    return GestureDetector(
                      onTap: () => checkoutController.selectedPaymentMethod.value = opt['name'] as String,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                            width: isSel ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          color: isSel ? const Color(0xFFFFF1F2) : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(opt['icon'] as IconData, size: 24, color: isSel ? AppColors.primary : AppColors.textPrimary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    opt['desc'] as String,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel ? AppColors.primary : AppColors.textMuted,
                                  width: isSel ? 6 : 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            // Pay ₹X Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: checkoutController.isPlacingOrder.value
                      ? null
                      : () => checkoutController.placeOrder(),
                  child: checkoutController.isPlacingOrder.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Pay ₹$total'),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
