import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Automatically choose localhost according to platform
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  // Auth endpoints
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String google = '/auth/google/';
  static const String sendOtp = '/auth/otp/send/';
  static const String verifyOtp = '/auth/otp/verify/';
  static const String refreshToken = '/auth/token/refresh/';
  static const String profile = '/auth/profile/';
  static const String addresses = '/auth/addresses/';

  // Products & Categories
  static const String categories = '/products/categories/';
  static const String subcategories = '/products/subcategories/';
  static const String products = '/products/items/';
  static const String sizeGuide = '/products/sizeguide/';
  static const String wishlist = '/products/wishlist/';
  static const String wishlistToggle = '/products/wishlist/toggle/';

  // Orders & Cart
  static const String cart = '/orders/cart/';
  static const String cartSummary = '/orders/cart/summary/';
  static const String applyCoupon = '/orders/cart/apply_coupon/';
  static const String clearCart = '/orders/cart/clear/';
  static const String orders = '/orders/orders/';
  static const String returns = '/orders/returns/';
  static const String razorpayCreateOrder = '/orders/orders/create_razorpay_order/';
  static const String razorpayVerifyPayment = '/orders/orders/verify_razorpay_payment/';

  // Common
  static const String banners = '/common/banners/';
  static const String notifications = '/common/notifications/';
  static const String faqs = '/common/faqs/';
  static const String contact = '/common/contact/';
}
