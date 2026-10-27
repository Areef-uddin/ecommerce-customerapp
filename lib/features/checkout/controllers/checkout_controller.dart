import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../orders/models/order_model.dart';
import '../../profile/models/address_model.dart';

class CheckoutController extends GetxController {
  final isLoading = true.obs;
  final addresses = <AddressModel>[].obs;
  final selectedAddressId = 0.obs;

  // Payment method
  final selectedPaymentMethod = 'UPI'.obs;
  final isPlacingOrder = false.obs;
  final placedOrder = Rxn<OrderModel>();

  // New Address Inputs
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController(text: 'Bengaluru');
  final pinController = TextEditingController(text: '560001');
  final addressType = 'Home'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    pinController.dispose();
    super.onClose();
  }

  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      final res = await ApiClient.get(ApiEndpoints.addresses);
      if (res.data is List) {
        addresses.assignAll(
          (res.data as List).map((a) => AddressModel.fromJson(a)).toList(),
        );
        if (addresses.isNotEmpty) {
          final defaultAddr = addresses.firstWhereOrNull((a) => a.isDefault) ?? addresses.first;
          selectedAddressId.value = defaultAddr.id;
        }
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNewAddress() async {
    if (addressController.text.trim().isEmpty) return;

    try {
      final res = await ApiClient.post(ApiEndpoints.addresses, data: {
        'full_name': fullNameController.text.trim().isEmpty ? 'Shopper' : fullNameController.text.trim(),
        'phone': phoneController.text.trim().isEmpty ? '+91 9876543210' : phoneController.text.trim(),
        'address_line': addressController.text.trim(),
        'city': cityController.text.trim(),
        'postal_code': pinController.text.trim(),
        'address_type': addressType.value,
        'is_default': false,
      });

      final newAddr = AddressModel.fromJson(res.data);
      addresses.add(newAddr);
      selectedAddressId.value = newAddr.id;
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add address');
    }
  }

  Future<void> placeOrder() async {
    if (selectedPaymentMethod.value == 'Razorpay') {
      await startRazorpayPayment();
      return;
    }

    try {
      isPlacingOrder.value = true;
      final res = await ApiClient.post(ApiEndpoints.orders, data: {
        'address_id': selectedAddressId.value,
        'payment_method': selectedPaymentMethod.value,
      });

      placedOrder.value = OrderModel.fromJson(res.data);
      Get.offNamed('/order-placed');
    } catch (e) {
      Get.snackbar('Order Failed', 'Could not complete order, please try again.');
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<void> startRazorpayPayment() async {
    try {
      isPlacingOrder.value = true;
      
      // 1. Create Razorpay order on backend
      final orderRes = await ApiClient.post(ApiEndpoints.razorpayCreateOrder, data: {
        'address_id': selectedAddressId.value,
      });

      final razorpayOrderId = orderRes.data['razorpay_order_id'] ?? 'order_sim_123';
      final keyId = orderRes.data['key_id'] ?? 'rzp_test_Tt3TjWZ9FqBAW6';
      final totalAmount = orderRes.data['total_amount'] ?? '2998';

      // 2. Open sleek Razorpay checkout modal
      _showRazorpayPaymentModal(
        orderId: razorpayOrderId,
        keyId: keyId,
        amount: totalAmount,
      );
    } catch (e) {
      Get.snackbar('Payment Error', 'Unable to initiate Razorpay payment. Please try again.');
    } finally {
      isPlacingOrder.value = false;
    }
  }

  void _showRazorpayPaymentModal({
    required String orderId,
    required String keyId,
    required String amount,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Razorpay Header with official branding style
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C2340),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt, color: Color(0xFF00BAF2), size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Razorpay',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'TEST MODE',
                      style: TextStyle(
                        color: Color(0xFF0284C7),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'StyleHub Luxe Fashion',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Order ID: $orderId',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount Payable', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('₹$amount', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0C2340))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await completeRazorpayPayment(
                          razorpayOrderId: orderId,
                          razorpayPaymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                          razorpaySignature: 'sig_${DateTime.now().millisecondsSinceEpoch}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BAF2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> completeRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      isPlacingOrder.value = true;
      final res = await ApiClient.post(ApiEndpoints.razorpayVerifyPayment, data: {
        'address_id': selectedAddressId.value,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      });

      placedOrder.value = OrderModel.fromJson(res.data);
      Get.offNamed('/order-placed');
    } catch (e) {
      Get.snackbar('Payment Failed', 'Razorpay transaction verification failed.');
    } finally {
      isPlacingOrder.value = false;
    }
  }
}
