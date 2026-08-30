import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
class DioClient {
  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;

  late Dio _dio;

  // الرابط الذي طلبته للاستضافة
  static const String baseUrl = "https://nomnow-o4ba.onrender.com/";

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 40), // مهم جداً لسيرفر Render
        receiveTimeout: const Duration(seconds: 40),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // إضافة التوكن تلقائياً لكل الطلبات ومعالجة الأخطاء عالمياً
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final storage = GetStorage();
        String? token = storage.read('token');

        String lang = storage.read('lang') ?? Get.locale?.languageCode ?? 'en';
        options.headers['Accept-Language'] = lang;

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // ✅ اكتشاف حالات الحظر والرفض والانتظار (403) عالمياً من أي مكان في التطبيق
        if (e.response?.statusCode == 403) {
          if (Get.isRegistered<AuthController>()) {
            // استدعاء معالج الأخطاء المركزي في AuthController لتنفيذ سيناريو مبرمج الباك إند
            Get.find<AuthController>().handleError(e);
          }
        }
        return handler.next(e);
      },
    ));
  }

  Dio get instance => _dio;
}