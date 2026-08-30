import 'package:get/get.dart';
import 'app_routes.dart';

// 1. استيراد الـ Bindings (المسؤولة عن حقن الـ Controllers)
import '../features/navigation/presentation/bindings/navigation_binding.dart';
import '../features/orders/presentation/bindings/orders_binding.dart';

// 2. استيراد شاشات ميزة المصادقة (Auth)
import '../features/auth/presentation/views/auth_screen.dart';
import '../features/auth/presentation/views/blocked_screen.dart';
import '../features/auth/presentation/views/forgot_password_screen.dart';
import '../features/auth/presentation/views/otp_screen.dart';
import '../features/auth/presentation/views/completion_document_screen.dart';
import '../features/auth/presentation/views/reset_password_screen.dart';

// 3. استيراد شاشات ميزة التنقل والواجهة الرئيسية (Navigation & Home)
import '../features/navigation/presentation/views/main_wrapper.dart';
import '../features/splash/presentation/views/splash_screen.dart';

// 4. استيراد شاشات ميزة الطلبات (Orders)
import '../features/orders/presentation/views/new_order_request_screen.dart';
import '../features/orders/presentation/views/order_details_screen.dart';
import '../features/orders/presentation/views/pickup_confirmation_screen.dart';
import '../features/orders/presentation/views/delivery_map_screen.dart';

// 5. استيراد شاشات ميزة الإعدادات والتنبيهات (Settings & Notifications)
import '../features/settings/presentation/views/settings_screen.dart';
import '../features/notifications/presentation/views/notifications_screen.dart';

class AppPages {
  // تعريف المسار الابتدائي للتطبيق (عادة شاشة السبلاش)
  static const initial = AppRoutes.splash;

  static final routes = [
    // شاشة البداية
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),

    // شاشات المصادقة (تعتمد على AuthController المحقون عالمياً في InitialBinding)
    GetPage(
      name: AppRoutes.login,
      page: () => const AuthScreen(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OTPScreen(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.blocked,
      page: () => const BlockedScreen(),
    ),
    GetPage(
      name: AppRoutes.documentsCompletion,
      page: () => const CompletionDocumentScreen(),
    ),

    // الواجهة الرئيسية (مع ربطها بمتحكم التنقل ومتحكم المحفظة)
    GetPage(
      name: AppRoutes.mainNavigation,
      page: () => const MainWrapper(),
      binding: NavigationBinding(),
    ),

    // شاشات ميزة الطلبات (مع ربطها بمتحكمات الطلبات)
    GetPage(
      name: AppRoutes.newOrder,
      page: () => const NewOrderRequestScreen(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.detailsOrder,
      page: () => const OrderDetailsScreen(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.pickUpConfirmation,
      page: () => const PickUpConfirmationScreen(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.deliveryMap,
      page: () => const DeliveryMapScreen(),
      binding: OrdersBinding(),
    ),

    // شاشات عامة
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
    ),
  ];
}