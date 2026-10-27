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
      {
        'id': 'PhonePe',
        'title': 'PhonePe (UPI)',
        'subtitle': 'Instant UPI payment via PhonePe app / QR code',
        'badge': 'MOST POPULAR',
        'icon': Icons.qr_code_2_rounded,
        'iconColor': const Color(0xFF5F259F),
        'iconBg': const Color(0xFFF3E8FF),
        'btnColor': const Color(0xFF5F259F),
      },
      {
        'id': 'Paytm',
        'title': 'Paytm (UPI & Wallet)',
        'subtitle': 'Instant payment via Paytm UPI, Wallet or Postpaid',
        'badge': 'FAST & EASY',
        'icon': Icons.account_balance_wallet_rounded,
        'iconColor': const Color(0xFF002970),
        'iconBg': const Color(0xFFE0F2FE),
        'btnColor': const Color(0xFF002970),
      },
      {
        'id': 'Razorpay',
        'title': 'Razorpay Secure Gateway',
        'subtitle': 'Credit/Debit Cards, Net Banking, GPay & all major banks',
        'badge': 'ALL CARDS & BANKS',
        'icon': Icons.bolt_rounded,
        'iconColor': const Color(0xFF00BAF2),
        'iconBg': const Color(0xFF0C2340),
        'btnColor': const Color(0xFF0C2340),
      },
      {
        'id': 'Cash on Delivery',
        'title': 'Cash on Delivery (COD)',
        'subtitle': 'Pay with cash or UPI at your doorstep upon delivery',
        'badge': 'PAY AT DOORSTEP',
        'icon': Icons.local_shipping_outlined,
        'iconColor': const Color(0xFF10B981),
        'iconBg': const Color(0xFFECFDF5),
        'btnColor': AppColors.primary,
      },
    ];

    final total = cartController.cartSummary.value?.finalTotal.toInt() ?? 2998;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Select Payment Method',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '100% Safe & RBI compliant 256-bit encrypted payments.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'CHOOSE PAYMENT OPTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Payment Options List
                    ...paymentOptions.map((opt) {
                      return Obx(() {
                        final isSel = checkoutController.selectedPaymentMethod.value == opt['id'];

                        return GestureDetector(
                          onTap: () => checkoutController.selectedPaymentMethod.value = opt['id'] as String,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSel ? (opt['btnColor'] as Color) : const Color(0xFFE2E8F0),
                                width: isSel ? 2 : 1,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: (opt['btnColor'] as Color).withOpacity(0.12),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon badge
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: opt['iconBg'] as Color,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    opt['icon'] as IconData,
                                    color: opt['iconColor'] as Color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            opt['title'] as String,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isSel ? (opt['btnColor'] as Color) : const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              opt['badge'] as String,
                                              style: TextStyle(
                                                color: isSel ? Colors.white : const Color(0xFF64748B),
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        opt['subtitle'] as String,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Radio check indicator
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSel ? (opt['btnColor'] as Color) : const Color(0xFFCBD5E1),
                                      width: isSel ? 6.5 : 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    }),

                    const SizedBox(height: 12),

                    // Amount breakdown preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount Payable', style: TextStyle(fontSize: 14, color: Color(0xFF475569))),
                              Text('₹$total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Obx(() {
                final isPlacing = checkoutController.isPlacingOrder.value;
                final sel = checkoutController.selectedPaymentMethod.value;

                Color btnBg = const Color(0xFF0C2340);
                String btnText = 'Pay ₹$total with Razorpay';
                IconData btnIcon = Icons.bolt_rounded;

                if (sel == 'PhonePe') {
                  btnBg = const Color(0xFF5F259F);
                  btnText = 'Pay ₹$total with PhonePe';
                  btnIcon = Icons.qr_code_2_rounded;
                } else if (sel == 'Paytm') {
                  btnBg = const Color(0xFF002970);
                  btnText = 'Pay ₹$total with Paytm';
                  btnIcon = Icons.account_balance_wallet_rounded;
                } else if (sel == 'Cash on Delivery') {
                  btnBg = AppColors.primary;
                  btnText = 'Place Order (Cash on Delivery)';
                  btnIcon = Icons.check_circle_outline;
                }

                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isPlacing ? null : () => checkoutController.placeOrder(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnBg,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isPlacing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 12),
                              Text('Opening Payment Gateway...', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(btnIcon, color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                btnText,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ],
                          ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
