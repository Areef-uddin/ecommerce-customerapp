class ApiEndpoints {
  static const String serverHost = 'http://157.15.203.209';
  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  // VPS Production backend host (http://157.15.203.209)
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

  // Common & Footer
  static const String banners = '/common/banners/';
  static const String notifications = '/common/notifications/';
  static const String faqs = '/common/faqs/';
  static const String contact = '/common/contact/';
  static const String footer = '/common/footer/';
  static const String storeSettings = '/common/store-settings/';
  static const String footerSections = '/common/footer-sections/';
  static const String policies = '/common/policies/';
  static const String newsletter = '/common/newsletter/';

  // Virtual Try-On & AI Visualization
  static const String tryonGenerate = '/virtual-tryon/generate/';
  static const String tryonJobs = '/virtual-tryon/jobs/';
  static const String tryonHistory = '/virtual-tryon/history/';

  // Referrals & Rewards
  static const String referralMyCode = '/referrals/my-code/';
  static const String referralMyStats = '/referrals/my-stats/';
  static const String referralMyReferrals = '/referrals/my-referrals/';
  static const String referralValidate = '/referrals/validate/';
  static const String referralApply = '/referrals/apply/';
  static const String referralRewards = '/referrals/rewards/';
}
