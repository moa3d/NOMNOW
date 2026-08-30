import 'package:delivery_app/data/api_client/dio_client.dart';
import 'package:get/get.dart';

class PastOrderDetailsController extends GetxController {
  final _dio = DioClient().instance;
  var isLoading = false.obs;
  var orderDetails = {}.obs;

  // دالة يتم استدعاؤها من شاشة السجل قبل الانتقال
  void setOrderAndFetch(String orderId) {
    orderDetails.value = {}; // مسح البيانات القديمة
    fetchOrderDetails(orderId);
  }

  Future<void> fetchOrderDetails(String orderId) async {
    try {
      isLoading.value = true;
      var response = await _dio.get("api/driver/orders/$orderId");

      if (response.statusCode == 200 && response.data['success']) {
        orderDetails.value = response.data['order'];
      }
    } catch (e) {
      print("🔥 Error fetching details: $e");
    } finally {
      isLoading.value = false;
    }
  }
}