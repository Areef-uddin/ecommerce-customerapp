class ApiEndpoints {
  static const String serverHost = 'https://ecommerce-backened-jsiy.onrender.com';
  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  // The embedded browser cannot reach the host machine's loopback address.
  // Use Render by default and allow an explicit local override for CLI runs.
  static String get baseUrl => _apiBaseUrlOverride.isNotEmpty
      ? _apiBaseUrlOverride
      : '$serverHost/api';

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
  static const String razorpayCancelPayment = '/orders/orders/record_cancelled_payment/';

  // Common
  static const String banners = '/common/banners/';
  static const String notifications = '/common/notifications/';
  static const String faqs = '/common/faqs/';
  static const String contact = '/common/contact/';

  // Virtual Try-On & AI Visualization
  static const String tryonGenerate = '/virtual-tryon/generate/';
  static const String tryonJobs = '/virtual-tryon/jobs/';
  static const String tryonHistory = '/virtual-tryon/history/';
}
