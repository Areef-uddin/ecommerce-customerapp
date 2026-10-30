import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/checkout_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class PaymentMethodView extends StatefulWidget {
  const PaymentMethodView({super.key});

  @override
  State<PaymentMethodView> createState() => _PaymentMethodViewState();
}

class _PaymentMethodViewState extends State<PaymentMethodView> {
  final checkoutController = Get.isRegistered<CheckoutController>()
      ? Get.find<CheckoutController>()
      : Get.put(CheckoutController());
  final cartController = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartController.fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offNamed(AppRoutes.checkoutAddress);
            }
          },
        ),
        title: Text(
          'Select Payment Method',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Obx(() {
            final summaryTotal = cartController.cartSummary.value?.finalTotal;
            final calculatedTotal = cartController.cartItems.fold<double>(
              0.0,
              (sum, item) => sum + (item.product.price * item.quantity),
            );
            final cartTotal =
                summaryTotal ?? (calculatedTotal > 0 ? calculatedTotal : 0.0);
            final formattedTotal = '₹${cartTotal.toInt()}';
            final selectedMethod =
                checkoutController.selectedPaymentMethod.value;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        // 1. Security Banner (Exact Image 3 Screen 2)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDBEAFE),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified_user_outlined,
                                  color: Color(0xFF2563EB),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '100% Safe & Secure Payments',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Your payments are protected with 256-bit encryption.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: const Color(0xFF3B82F6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section Title: CHOOSE PAYMENT OPTION
                        Text(
                          'CHOOSE PAYMENT OPTION',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Payment Option 1: Online Payment (with logos row)
                        _buildOnlinePaymentCard(
                          isSelected: selectedMethod != 'Cash on Delivery',
                          onTap: () =>
                              checkoutController.selectedPaymentMethod.value =
                                  'Razorpay',
                        ),
                        const SizedBox(height: 14),

                        // Payment Option 2: Cash on Delivery
                        _buildCodPaymentCard(
                          isSelected: selectedMethod == 'Cash on Delivery',
                          onTap: () =>
                              checkoutController.selectedPaymentMethod.value =
                                  'Cash on Delivery',
                        ),
                      ],
                    ),
                  ),

                  // Bottom Summary & Dark Navy Button (Exact Image 3 Screen 2)
                  Container(
                    padding: const EdgeInsets.only(top: 14, bottom: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Total Amount Payable Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount Payable',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              formattedTotal,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (checkoutController
                                .pendingPaymentVerification
                                .value !=
                            null) ...[
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              border: Border.all(
                                color: const Color(0xFFFED7AA),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              checkoutController
                                      .paymentVerificationError
                                      .value
                                      .isEmpty
                                  ? 'Payment response received. Confirming your order… Please do not pay again.'
                                  : '${checkoutController.paymentVerificationError.value}\nRetry verification below; do not start another payment.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF9A3412),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: checkoutController.isPlacingOrder.value
                                  ? null
                                  : checkoutController.retryPaymentVerification,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xFF94A3B8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: checkoutController.isPlacingOrder.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Retry Payment Verification'),
                            ),
                          ),
                        ] else
                          // Dark Navy Button: [ 🔒  Pay ₹1,000 Securely  → ]
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: checkoutController.isPlacingOrder.value
                                  ? null
                                  : () => checkoutController.placeOrder(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xFF94A3B8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: checkoutController.isPlacingOrder.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.lock_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Pay $formattedTotal Securely',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // Card 1: Online Payment Card (Exact Image 3 Screen 2)
  Widget _buildOnlinePaymentCard({
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE11D48)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected ? const Color(0xFFFFF5F5) : Colors.white,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Radio Button
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF94A3B8),
                      width: isSelected ? 2 : 1.5,
                    ),
                    color: Colors.white,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE11D48),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Lightning Icon Container
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flash_on_rounded,
                    color: Color(0xFFE11D48),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Online Payment',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pay using UPI, Cards,\nNet Banking & Wallets',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Logos row: UPI, VISA, Mastercard, RuPay, Wallet
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBrandPill('UPI', const Color(0xFF00796B), isUpi: true),
                  _buildBrandPill(
                    'VISA',
                    const Color(0xFF1A1F71),
                    isVisa: true,
                  ),
                  _buildMastercardPill(),
                  _buildBrandPill('RuPay', const Color(0xFFF37021)),
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 22,
                    color: Color(0xFF334155),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card 2: Cash on Delivery Card (Exact Image 3 Screen 2)
  Widget _buildCodPaymentCard({
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE11D48)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected ? const Color(0xFFFFF5F5) : Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Radio Button
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF94A3B8),
                  width: isSelected ? 2 : 1.5,
                ),
                color: Colors.white,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE11D48),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Truck Icon Container
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Color(0xFF475569),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash on Delivery',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pay with cash at your doorstep upon delivery',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandPill(
    String name,
    Color color, {
    bool isUpi = false,
    bool isVisa = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        name,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          fontStyle: isVisa ? FontStyle.italic : FontStyle.normal,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMastercardPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SizedBox(
        width: 32,
        height: 16,
        child: Stack(
          children: [
            Positioned(
              left: 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFEB001B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFF79E1B).withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
