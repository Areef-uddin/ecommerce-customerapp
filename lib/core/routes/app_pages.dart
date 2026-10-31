import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/auth/views/splash_view.dart';
import '../../features/auth/views/onboarding_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/otp_verification_view.dart';
import '../../features/home/views/main_navigation_view.dart';
import '../../features/category/views/category_view.dart';
import '../../features/product/views/product_list_view.dart';
import '../../features/product/views/product_detail_view.dart';
import '../../features/cart/views/cart_view.dart';
import '../../features/checkout/views/address_selection_view.dart';
import '../../features/checkout/views/payment_method_view.dart';
import '../../features/checkout/views/order_placed_view.dart';
import '../../features/orders/views/order_tracking_view.dart';
import '../../features/orders/views/my_orders_view.dart';
import '../../features/orders/views/order_details_view.dart';
import '../../features/orders/views/return_refund_view.dart';
import '../../features/wishlist/views/wishlist_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/support/views/help_support_view.dart';
import '../../features/notifications/views/notifications_view.dart';
import '../../features/virtual_tryon/views/virtual_tryon_view.dart';
import '../../features/referral/views/referral_history_view.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.register, page: () => const LoginView()),
    GetPage(name: '/register', page: () => const LoginView()),
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordView()),
    GetPage(name: AppRoutes.otp, page: () => const OtpVerificationView()),
    GetPage(name: AppRoutes.home, page: () => const MainNavigationView()),
    GetPage(name: AppRoutes.category, page: () => const CategoryView()),
    GetPage(name: AppRoutes.products, page: () => const ProductListView()),
    GetPage(name: AppRoutes.productDetail, page: () => const ProductDetailView()),
    GetPage(name: AppRoutes.cart, page: () => const CartView()),
    GetPage(name: AppRoutes.checkoutAddress, page: () => const AddressSelectionView()),
    GetPage(name: AppRoutes.checkoutPayment, page: () => const PaymentMethodView()),
    GetPage(name: AppRoutes.orderPlaced, page: () => const OrderPlacedView()),
    GetPage(name: AppRoutes.orderTracking, page: () => const OrderTrackingView()),
    GetPage(name: AppRoutes.myOrders, page: () => const MyOrdersView()),
    GetPage(name: AppRoutes.orderDetails, page: () => const OrderDetailsView()),
    GetPage(name: AppRoutes.returnRefund, page: () => const ReturnRefundView()),
    GetPage(name: AppRoutes.wishlist, page: () => const WishlistView()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView()),
    GetPage(name: AppRoutes.helpSupport, page: () => const HelpSupportView()),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationsView()),
    GetPage(name: AppRoutes.virtualTryOn, page: () => const VirtualTryOnView()),
    GetPage(name: AppRoutes.referralHistory, page: () => const ReferralHistoryView()),
  ];
}
