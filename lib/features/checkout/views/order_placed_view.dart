import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/checkout_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../orders/models/order_model.dart';

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

    OrderModel? order = controller.placedOrder.value;
    bool isCancelled = false;

    if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['cancelled'] == true) isCancelled = true;
      if (args['order'] is OrderModel) order = args['order'] as OrderModel;
    } else if (Get.arguments is OrderModel) {
      order = Get.arguments as OrderModel;
    }

    if (order?.orderStatus == 'Cancelled') {
      isCancelled = true;
    }

    final orderNumber = order?.orderNumber.isNotEmpty == true
        ? order!.orderNumber
        : (isCancelled ? '#CAN${DateTime.now().millisecondsSinceEpoch % 100000}' : '#OD58273491');
    final trackingNumber = order?.trackingNumber.isNotEmpty == true
        ? order!.trackingNumber
        : 'TEST-FASH-1011';
    final amountText = order != null ? '₹${order.totalAmount.toInt()}' : '₹3,999';
    final paymentMode = order?.paymentMethod.isNotEmpty == true
        ? order!.paymentMethod
        : (isCancelled ? 'Razorpay (Cancelled)' : 'Razorpay');
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

                  // 1. Status Icon Circle
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!isCancelled) ..._buildCelebrationRays(),
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: isCancelled ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: isCancelled
                                    ? const Color(0x33EF4444)
                                    : const Color(0x3310B981),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            isCancelled ? Icons.close_rounded : Icons.check_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Heading & Subtitle
                  Text(
                    isCancelled ? 'Order Cancelled' : 'Payment Successful!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isCancelled ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isCancelled
                        ? 'You cancelled the payment. The order was not processed and no money was deducted from your account.'
                        : 'Your order has been placed and confirmed.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3. Receipt Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCancelled ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                        width: 1.5,
                      ),
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

                        // Row 2: Courier Tracking / Status
                        if (!isCancelled) ...[
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
                        ] else ...[
                          _buildReceiptRow(
                            icon: Icons.info_outline_rounded,
                            label: 'Order Status',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Cancelled',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        ],

                        // Row 3: Amount Paid / Order Total
                        _buildReceiptRow(
                          icon: Icons.credit_card_outlined,
                          label: isCancelled ? 'Total Amount' : 'Amount Paid',
                          trailing: Text(
                            amountText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isCancelled ? const Color(0xFF64748B) : const Color(0xFF10B981),
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
                              Icon(
                                isCancelled ? Icons.cancel_outlined : Icons.check_circle_rounded,
                                color: isCancelled ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                paymentMode,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isCancelled ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Delivery Card (Only shown if NOT cancelled)
                  if (!isCancelled) ...[
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
                  ] else ...[
                    const SizedBox(height: 16),
                  ],

                  // 5. Action Buttons
                  if (!isCancelled) ...[
                    // Success Button 1: Track Order Live
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

                    // Success Button 2: View Order Details
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
                  ] else ...[
                    // Cancelled Button 1: Retry Payment
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offNamed(AppRoutes.checkoutPayment);
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
                            const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Retry Payment',
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

                    // Cancelled Button 2: View My Orders
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.offNamed(AppRoutes.myOrders);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 16, color: Color(0xFF0F172A)),
                            const SizedBox(width: 8),
                            Text(
                              'View My Orders',
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
                  ],
                  const SizedBox(height: 16),

                  // Button 3: Continue Shopping
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

  Widget _buildReceiptRow({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        trailing,
      ],
    );
  }

  List<Widget> _buildCelebrationRays() {
    return [
      Positioned(top: 8, child: _rayDot(const Color(0xFFFBBF24), 6)),
      Positioned(bottom: 8, child: _rayDot(const Color(0xFF38BDF8), 6)),
      Positioned(left: 8, child: _rayDot(const Color(0xFFF43F5E), 6)),
      Positioned(right: 8, child: _rayDot(const Color(0xFF10B981), 6)),
      Positioned(top: 18, left: 18, child: _rayPill(const Color(0xFF818CF8))),
      Positioned(top: 18, right: 18, child: _rayPill(const Color(0xFFF59E0B))),
      Positioned(bottom: 18, left: 18, child: _rayPill(const Color(0xFF34D399))),
      Positioned(bottom: 18, right: 18, child: _rayPill(const Color(0xFFEC4899))),
    ];
  }

  Widget _rayDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _rayPill(Color color) {
    return Container(
      width: 4,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
