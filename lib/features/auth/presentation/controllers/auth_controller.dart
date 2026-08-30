import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:dio/dio.dart' as dio_instance;
import 'package:image_picker/image_picker.dart';
import '../../../../data/api_client/dio_client.dart';

/// المتحكم المركزي لإدارة عمليات التوثيق وبيانات السائق والملف الشخصي
class AuthController extends GetxController {
  final _storage = GetStorage();
  final _api = DioClient().instance;
  final _picker = ImagePicker();

  // حقول التحكم في النصوص للواجهات
  final loginPhoneController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final plateController = TextEditingController();
  final passwordController = TextEditingController();

  // متغيرات الحالة والبيانات التفاعلية
  final isLoading = false.obs;
  final driverData = {}.obs;
  final totalDeliveries = 0.obs;
  final selectedVehicle = RxnString();
  final selectedCity = RxnString();

  // ملفات الوثائق والصورة الشخصية
  final profileImage = Rxn<File>();
  final idCardFile = Rxn<File>();
  final licenseFile = Rxn<File>();
  final registrationFile = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    if (isLoggedIn()) {
      fetchDriverData();
      fetchTotalDeliveries();
      updateFCMTokenOnServer();
    }
  }

  /// التحقق من وجود توكن فعال في المخزن المحلي
  bool isLoggedIn() => _storage.read("token") != null;

  /// تنفيذ عملية تسجيل الدخول
  Future<void> login() async {
    if (loginPhoneController.text
        .trim()
        .isEmpty || loginPasswordController.text.isEmpty) {
      _showWarning("alert".tr, "يرجى إدخال البيانات المطلوبة");
      return;
    }
    try {
      isLoading.value = true;
      final response = await _api.post("api/driver/loginwithphone", data: {
        "phone": loginPhoneController.text.trim(),
        "password": loginPasswordController.text,
      });
      if (response.statusCode == 200) {
        if (response.data['requiresVerification'] ?? false) {
          Get.toNamed('/otp', arguments: {
            "phone": loginPhoneController.text,
            "otp": response.data['otp']
          });
        } else {
          _handleLoginSuccess(response.data);
        }
      }
    } on dio_instance.DioException catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل حساب جديد ورفع الوثائق
  Future<void> register() async {
    try {
      isLoading.value = true;
      dio_instance.FormData formData = dio_instance.FormData.fromMap({
        "name": fullNameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text,
        "vehicletype": (selectedVehicle.value ?? "car").toLowerCase(),
        "vehicleplate": plateController.text.trim(),
        "zone": selectedCity.value ?? "General",
      });

      if (profileImage.value != null) formData.files.add(MapEntry("driverImage",
          await dio_instance.MultipartFile.fromFile(profileImage.value!.path)));
      if (idCardFile.value != null) formData.files.add(MapEntry("idImage",
          await dio_instance.MultipartFile.fromFile(idCardFile.value!.path)));
      if (licenseFile.value != null) formData.files.add(MapEntry(
          "drivingLicenseImage",
          await dio_instance.MultipartFile.fromFile(licenseFile.value!.path)));
      if (registrationFile.value != null) formData.files.add(MapEntry(
          "vehicleRegistrationImage", await dio_instance.MultipartFile.fromFile(
          registrationFile.value!.path)));

      final response = await _api.post("api/driver/register", data: formData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar("نجاح", "تم إنشاء الحساب بنجاح");
        Get.back();
      }
    } on dio_instance.DioException catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// التحقق من رمز OTP
  Future<void> verifyOTP(String phone, String otp) async {
    try {
      isLoading.value = true;
      final response = await _api.post(
          "api/driver/verifyphone", data: {"phone": phone, "otp": otp});
      if (response.statusCode == 200) _handleLoginSuccess(response.data);
    } on dio_instance.DioException catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب بيانات السائق وفحص حالته الأمنية
  Future<void> fetchDriverData() async {
    try {
      final response = await _api.get("api/driver/dirver-info");
      if (response.statusCode == 200 && response.data['driver'] != null) {
        driverData.assignAll(response.data['driver']);
        _checkStatus();
      }
    } on dio_instance.DioException catch (e) {
      if (e.response?.statusCode == 401)
        logout();
      else
        handleError(e);
    }
  }

  void _checkStatus() {
    String status = driverData['status'] ?? 'active';
    if (status == 'blocked')
      Get.offAllNamed('/blocked');
    else if (status == 'pending')
      Get.offAllNamed('/documents-completion');
    else if (Get.currentRoute == '/login' || Get.currentRoute == '/splash') Get
        .offAllNamed('/main-navigation');
  }

  /// تحديث صورة الملف الشخصي
  Future<void> updateProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);
      if (image == null) return;
      isLoading.value = true;
      dio_instance.FormData formData = dio_instance.FormData();
      formData.files.add(MapEntry("driverImage",
          await dio_instance.MultipartFile.fromFile(image.path)));
      final response = await _api.patch(
          "api/driver/update-info", data: formData);
      if (response.statusCode == 200) {
        driverData['driverImage'] = response.data['driver']['driverImage'];
        driverData.refresh();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    finally {
      isLoading.value = false;
    }
  }

  /// تحديث بيانات الملف الشخصي العامة
  Future<void> updateDriverProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _api.patch("api/driver/update-info", data: data);
      driverData.addAll(data);
      driverData.refresh();
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  /// تغيير كلمة المرور
  Future<void> changePassword(String current, String next) async {
    try {
      isLoading.value = true;
      await _api.patch("api/driver/change-password",
          data: {"currentPassword": current, "newPassword": next});
      Get.back();
      Get.snackbar("نجاح", "تم تغيير كلمة المرور");
    } on dio_instance.DioException catch (e) {
      handleError(e);
    }
    finally {
      isLoading.value = false;
    }
  }

  /// جلب إحصائيات التوصيلات
  Future<void> fetchTotalDeliveries() async {
    try {
      final res = await _api.get("api/driver/orders-history");
      if (res.statusCode == 200)
        totalDeliveries.value = res.data['totalOrdersCount'] ?? 0;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// تغيير لغة التطبيق وحفظها
  void updateLanguage(String code) {
    Get.updateLocale(Locale(code));
    _storage.write('lang', code);
    Get.back();
  }

  void logout() {
    _storage.erase();
    Get.offAllNamed('/login');
  }

  void _handleLoginSuccess(Map<String, dynamic> data) async {
    await _storage.write("token", data['token']);
    await _storage.write(
        "driverId", data['driver']['id'] ?? data['driver']['_id']);
    await _storage.write("isLoggedIn", true);
    fetchDriverData();
    fetchTotalDeliveries();
    updateFCMTokenOnServer();
  }

  /// معالجة الأخطاء وتنفيذ سيناريوهات الحظر والرفض والانتظار (403)
  void handleError(dynamic e) {
    if (e is dio_instance.DioException && e.response?.statusCode == 403) {
      final responseData = e.response?.data;
      String msg = responseData is Map ? (responseData['message'] ?? "") : "";

      if (msg.contains("blocked")) {
        Get.offAllNamed('/blocked');
        return;
      }
      if (msg.contains("rejected")) {
        logout();
        return;
      }
      if (msg.contains("review") || msg.contains("pending") ||
          msg.contains("approval")) {
        Get.offAllNamed('/documents-completion');
        return;
      }
    }

    String message = "حدث خطأ في الاتصال";
    if (e is dio_instance.DioException) {
      final responseData = e.response?.data;
      if (responseData is Map) {
        message = responseData['message'] ?? message;
      }
    }
    _showWarning("تنبيه", message);
  }

  /// تحديث توكن FCM على السيرفر
  Future<void> updateFCMTokenOnServer() async {
    try {
      // منطق جلب التوكن وتحديثه يتم هنا عند إضافة باكيج Firebase
    } catch (e) {
      debugPrint("FCM Error: $e");
    }
  }

  void _showWarning(String title, String msg) {
    Get.snackbar(
        title, msg, backgroundColor: Colors.redAccent, colorText: Colors.white);
  }
}