import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/checkout_controller.dart';
import '../../orders/controllers/orders_controller.dart';

class OrderPlacedView extends StatefulWidget {
  const OrderPlacedView({super.key});

  @override
  State<OrderPlacedView> createState() => _OrderPlacedViewState();
}

class _OrderPlacedViewState extends State<OrderPlacedView> {
  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<OrdersController>()) {
      Get.find<OrdersController>().fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<CheckoutController>()
        ? Get.find<CheckoutController>()
        : Get.put(CheckoutController());
    final order = controller.placedOrder.value;

    final orderNumber = order?.orderNumber.isNotEmpty == true
        ? order!.orderNumber
        : '#OD58273491';
    final trackingNumber = order?.trackingNumber.isNotEmpty == true
        ? order!.trackingNumber
        : 'TEST-FASH-1011';
    final amountText = order != null ? '₹${order.totalAmount.toInt()}' : '₹1,000';
    final paymentMode = order?.paymentMethod.isNotEmpty == true ? order!.paymentMethod : 'Razorpay';
    final estimatedDate = order?.estimatedDelivery.isNotEmpty == true
        ? order!.estimatedDelivery
        : '31 Oct - 03 Nov';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // 1. Success Circle with celebration rays (Exact Image 3 Screen 3)
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Celebration decorative rays
                        ..._buildCelebrationRays(),

                        // Green circle with checkmark
                        Container(
                          width: 76,
                          height: 76,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Color(0x3310B981), blurRadius: 20, offset: Offset(0, 8)),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded, size: 48, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Heading: Payment Successful!
                  Text(
                    'Payment Successful!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your order has been placed and confirmed.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 2. Receipt Card: Order Number, Tracking, Amount Paid, Payment Mode (Exact Image 3 Screen 3)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Row 1: Order Number
                        _buildReceiptRow(
                          icon: Icons.description_outlined,
                          label: 'Order Number',
                          trailing: Text(
                            orderNumber,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),

                        // Row 2: Courier Tracking (Blue Pill)
                        _buildReceiptRow(
                          icon: Icons.local_shipping_outlined,
                          label: 'Courier Tracking',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              trackingNumber,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),

                        // Row 3: Amount Paid
                        _buildReceiptRow(
                          icon: Icons.credit_card_outlined,
                          label: 'Amount Paid',
                          trailing: Text(
                            amountText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),

                        // Row 4: Payment Mode
                        _buildReceiptRow(
                          icon: Icons.payments_outlined,
                          label: 'Payment Mode',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                paymentMode,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Estimated Delivery Card (Mint Green Card, Exact Image 3 Screen 3)
                  GestureDetector(
                    onTap: () => Get.offNamed(AppRoutes.myOrders),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD1FAE5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF059669), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Delivery',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF047857),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  estimatedDate,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF065F46),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF059669), size: 22),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Action Buttons (Exact Image 3 Screen 3)
                  // Button 1: Track Order Live (Pink/Crimson filled button)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (order != null) {
                          Get.offNamed(AppRoutes.orderTracking, arguments: order);
                        } else {
                          Get.offNamed(AppRoutes.orderTracking);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Track Order Live',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Button 2: View Order Details (Outlined Button)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        if (order != null) {
                          Get.offNamed(AppRoutes.orderDetails, arguments: order);
                        } else {
                          Get.offNamed(AppRoutes.myOrders);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.assignment_outlined, size: 16, color: Color(0xFF0F172A)),
                          const SizedBox(width: 8),
                          Text(
                            'View Order Details',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF0F172A)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Button 3: Continue Shopping (Pink Text Link)
                  GestureDetector(
                    onTap: () => Get.offAllNamed(AppRoutes.home),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Continue Shopping',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFE11D48),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow({required IconData icon, required String label, required Widget trailing}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        trailing,
      ],
    );
  }

  List<Widget> _buildCelebrationRays() {
    return [
      Positioned(
        top: 6,
        left: 24,
        child: Container(width: 3, height: 10, decoration: BoxDecoration(color: const Color(0xFFF43F5E), borderRadius: BorderRadius.circular(2))),
      ),
      Positioned(
        top: 2,
        right: 32,
        child: Container(width: 3, height: 12, decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(2))),
      ),
      Positioned(
        bottom: 8,
        left: 20,
        child: Container(width: 10, height: 3, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2))),
      ),
      Positioned(
        bottom: 6,
        right: 22,
        child: Container(width: 10, height: 3, decoration: BoxDecoration(color: const Color(0xFF06B6D4), borderRadius: BorderRadius.circular(2))),
      ),
      Positioned(
        top: 36,
        left: 4,
        child: Container(width: 10, height: 3, decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(2))),
      ),
      Positioned(
        top: 34,
        right: 4,
        child: Container(width: 10, height: 3, decoration: BoxDecoration(color: const Color(0xFFEC4899), borderRadius: BorderRadius.circular(2))),
      ),
    ];
  }
}
