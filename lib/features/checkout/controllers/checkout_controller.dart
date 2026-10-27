import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/web_auth_helper.dart';
import '../../../core/storage/storage_service.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../orders/models/order_model.dart';
import '../../profile/models/address_model.dart';

class CheckoutController extends GetxController {
  final isLoading = true.obs;
  final addresses = <AddressModel>[].obs;
  final selectedAddressId = 0.obs;

  // Selected Payment Method: 'PhonePe', 'Paytm', 'Razorpay', or 'Cash on Delivery'
  final selectedPaymentMethod = 'PhonePe'.obs;
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
    if (selectedPaymentMethod.value == 'Cash on Delivery') {
      await placeCodOrder();
      return;
    }

    // PhonePe, Paytm, or Razorpay opens the real Razorpay standard gateway modal
    await startRazorpayPayment(preferredMethod: selectedPaymentMethod.value);
  }

  Future<void> placeCodOrder() async {
    try {
      isPlacingOrder.value = true;
      final res = await ApiClient.post(ApiEndpoints.orders, data: {
        'address_id': selectedAddressId.value,
        'payment_method': 'Cash on Delivery',
      });

      placedOrder.value = OrderModel.fromJson(res.data);
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().fetchCart();
      }
      Get.offNamed('/order-placed');
    } catch (e) {
      Get.snackbar('Order Failed', 'Could not complete COD order, please try again.');
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<void> startRazorpayPayment({String? preferredMethod}) async {
    final method = preferredMethod ?? selectedPaymentMethod.value;
    try {
      isPlacingOrder.value = true;

      // 1. Create Razorpay order on backend
      final orderRes = await ApiClient.post(ApiEndpoints.razorpayCreateOrder, data: {
        'address_id': selectedAddressId.value,
        'payment_method': method,
      });

      final razorpayOrderId = orderRes.data['razorpay_order_id']?.toString() ?? '';
      final keyId = orderRes.data['key_id']?.toString() ?? 'rzp_test_Tt3TjWZ9FqBAW6';
      final totalAmount = orderRes.data['total_amount'] ?? '2998';
      final amountInPaise = orderRes.data['amount'] ?? ((double.tryParse(totalAmount.toString()) ?? 2998) * 100).toInt();

      final selectedAddr = addresses.firstWhereOrNull((a) => a.id == selectedAddressId.value);
      final user = StorageService.getUser();
      final customerName = selectedAddr?.fullName.isNotEmpty == true
          ? selectedAddr!.fullName
          : (user?['full_name'] ?? 'Shopper');
      final customerEmail = user?['email'] ?? 'customer@example.com';
      final customerPhone = selectedAddr?.phone.isNotEmpty == true
          ? selectedAddr!.phone
          : (user?['phone'] ?? '+919876543210');

      String paymentDesc = 'Online Payment';
      String themeColor = '#0C2340';
      if (method == 'PhonePe') {
        paymentDesc = 'PhonePe UPI Payment';
        themeColor = '#5F259F';
      } else if (method == 'Paytm') {
        paymentDesc = 'Paytm UPI/Wallet Payment';
        themeColor = '#002970';
      }

      // 2. Trigger real Razorpay Standard Checkout Gateway Modal
      final options = <String, dynamic>{
        'key': keyId,
        'amount': amountInPaise,
        'currency': 'INR',
        'name': 'StyleHub Luxe Fashion',
        'description': paymentDesc,
        'order_id': razorpayOrderId,
        'prefill': {
          'name': customerName,
          'email': customerEmail,
          'contact': customerPhone,
        },
        'theme': {
          'color': themeColor,
        },
      };

      final paymentResult = await triggerRazorpayCheckout(options);

      if (paymentResult != null && paymentResult['success'] == true) {
        await completeRazorpayPayment(
          razorpayOrderId: paymentResult['razorpay_order_id']?.toString() ?? razorpayOrderId,
          razorpayPaymentId: paymentResult['razorpay_payment_id']?.toString() ?? '',
          razorpaySignature: paymentResult['razorpay_signature']?.toString() ?? '',
          paymentMethod: method,
        );
      } else {
        Get.snackbar('Payment Cancelled', 'Payment window was closed or cancelled.');
      }
    } catch (e) {
      debugPrint('Razorpay checkout notice: $e');
      Get.snackbar('Payment Notice', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<void> completeRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String paymentMethod,
  }) async {
    try {
      isPlacingOrder.value = true;
      final res = await ApiClient.post(ApiEndpoints.razorpayVerifyPayment, data: {
        'address_id': selectedAddressId.value,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        'payment_method': paymentMethod,
      });

      placedOrder.value = OrderModel.fromJson(res.data);
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().fetchCart();
      }
      Get.offNamed('/order-placed');
    } catch (e) {
      Get.snackbar('Payment Failed', 'Razorpay transaction verification failed.');
    } finally {
      isPlacingOrder.value = false;
    }
  }
}
