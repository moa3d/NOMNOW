import 'dart:async';
import 'package:delivery_app/core/constants/app_colors.dart';
import 'proof_of_delivery_screen.dart';
import 'package:delivery_app/core/widgets/custom_leading.dart';
import 'package:delivery_app/data/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryMapScreen extends StatefulWidget {
  final Map<String, dynamic>? orderData;

  const DeliveryMapScreen({super.key, this.orderData});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  LatLng customerLocation = const LatLng(0, 0);
  LatLng driverLocation = const LatLng(0, 0);
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  final SocketService _socketService = Get.find<SocketService>();

  @override
  void initState() {
    super.initState();
    _extractLocations();
    _initializeLocationLogic();
  }

  @override
  void dispose() {
    // إغلاق تيار الموقع لمنع تسريب الذاكرة عند الخروج من الشاشة
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  /// دالة تهيئة منطق الموقع الجغرافي والتحقق من الصلاحيات
  Future<void> _initializeLocationLogic() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // جلب آخر موقع معروف لتسريع ظهور السائق على الخريطة
    Position? lastPos = await Geolocator.getLastKnownPosition();
    if (lastPos != null && mounted) {
      setState(() {
        driverLocation = LatLng(lastPos.latitude, lastPos.longitude);
      });
      _fitBounds();
    }

    /* AI Insight: يتم ضبط مسافة الفلترة (5 متر) لموازنة الدقة مع الحفاظ على عمر البطارية أثناء التنقل */
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position pos) {
      if (mounted) {
        setState(() {
          driverLocation = LatLng(pos.latitude, pos.longitude);
        });
        // تحديث الموقع على السيرفر عبر السوكيت لتمكين تتبع الزبون للسائق
        _socketService.updateLocation(pos.latitude, pos.longitude);
      }
    });
  }

  /// دالة لتحديث الموقع يدوياً وإعادة تركيز الكاميرا
  Future<void> _refreshMyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          driverLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(driverLocation, 16.0);
        _socketService.updateLocation(position.latitude, position.longitude);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not get location. Ensure GPS is on.");
    }
  }

  /* AI Insight: حساب الحدود الجغرافية (Bounds) ديناميكياً لضمان رؤية السائق والزبون معاً في إطار واحد */
  void _fitBounds() {
    if (driverLocation.latitude == 0 || customerLocation.latitude == 0) return;
    final bounds = LatLngBounds.fromPoints([driverLocation, customerLocation]);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.only(
            top: 180, bottom: 100, left: 50, right: 50),
      ),
    );
  }

  /// استخراج إحداثيات الزبون من بيانات الطلب المستلمة
  void _extractLocations() {
    List? custCoords;
    final deliveryAddr = widget.orderData?['deliveryAddress'];

    if (deliveryAddr is Map) {
      if (deliveryAddr['location'] is Map) {
        custCoords = deliveryAddr['location']['coordinates'];
      } else if (deliveryAddr['location'] is List) {
        custCoords = deliveryAddr['location'];
      }
    }

    setState(() {
      if (custCoords != null && custCoords is List && custCoords.length >= 2) {
        customerLocation = LatLng(custCoords[1], custCoords[0]);
      } else {
        // إحداثيات افتراضية في حال عدم توفر موقع الزبون
        customerLocation = const LatLng(32.5542, 35.8485);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final user = widget.orderData?['userId'] ?? {};
    final userName = user['name'] ?? "Customer";
    final userPhone = user['phone'];

    String deliveryAddress = "Address N/A";
    if (widget.orderData?['deliveryAddress'] is Map) {
      deliveryAddress =
          widget.orderData?['deliveryAddress']['fullAddress'] ?? "Address N/A";
    }

    final orderNote = widget.orderData?['notes'] ?? "no_note".tr;
    final cardColor = isDark ? const Color(0xFF1D2939) : Colors.white;
    const accentOrange = Color(0xFFFF5630);
    const infoBlue = Color(0xFF2E90FA);
    final textGrey = isDark ? const Color(0xFF98A2B3) : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101828) : Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDark ? Colors.white : Colors.black87, isDark),
      body: Stack(
        children: [
          _buildRealMap(isDark),
          Positioned(
              top: 110,
              left: 20,
              right: 20,
              child: _buildStatusCard(
                  cardColor, isDark ? Colors.white : Colors.black87, isDark)),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              heroTag: "refresh_loc",
              backgroundColor: isDark ? const Color(0xFF1D2939) : Colors.white,
              onPressed: _refreshMyLocation,
              child: const Icon(Icons.my_location, color: accentOrange),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomDetailsPanel(
          isDark,
          cardColor,
          accentOrange,
          infoBlue,
          textGrey,
          userName,
          deliveryAddress,
          userPhone,
          orderNote),
    );
  }

  /// ويدجت بناء الخريطة مع دعم الوضع الليلي والخطوط المسارية
  Widget _buildRealMap(bool isDark) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
          initialCenter: driverLocation.latitude != 0
              ? driverLocation
              : customerLocation,
          initialZoom: 14.5),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.num_now_courier.delivery_app.v1',
          tileBuilder: isDark ? (context, tileWidget, tile) {
            return ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                -1, 0, 0, 0, 255,
                0, -1, 0, 0, 255,
                0, 0, -1, 0, 255,
                0, 0, 0, 1, 0
              ]),
              child: tileWidget,
            );
          } : null,
        ),
        if (driverLocation.latitude != 0)
          PolylineLayer(polylines: [
            Polyline(
              points: [driverLocation, customerLocation],
              color: const Color(0xFFFF5630).withOpacity(0.6),
              strokeWidth: 6.0,
              pattern: const StrokePattern.dotted(),
              borderColor: const Color(0xFFFF5630),
              borderStrokeWidth: 1.0,
            )
          ]),
        MarkerLayer(markers: [
          if (driverLocation.latitude != 0)
            Marker(
                point: driverLocation,
                width: 80,
                height: 80,
                child: _markerWidget("marker_you".tr, const Color(0xFFFF5630),
                    Icons.navigation)),
          Marker(
              point: customerLocation,
              width: 80,
              height: 80,
              child: _markerWidget(
                  "marker_customer".tr, const Color(0xFF2E90FA),
                  Icons.location_on)),
        ]),
      ],
    );
  }

  /// ويدجت تصميم العلامة (Marker) على الخريطة
  Widget _markerWidget(String label, Color color, IconData icon) =>
      Column(children: [
        Icon(icon, color: color, size: 30),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(10)),
            child: Text(label,
                style: const TextStyle(color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)))
      ]);

  /// بناء شريط التطبيق العلوي الشفاف
  PreferredSizeWidget _buildAppBar(Color textColor, bool isDark) =>
      AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomLeading(onPressed: () => Get.back())),
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("marker_customer".tr,
                style: TextStyle(color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text("delivering_sub".tr,
                style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 12))
          ]),
          actions: [
            _buildBadge(
                "in_transit_badge".tr, Colors.redAccent.withOpacity(0.8)),
            const SizedBox(width: 15)
          ]);

  /// اللوحة السفلية التي تحتوي على معلومات الزبون وأزرار التحكم
  Widget _buildBottomDetailsPanel(bool isDark, Color cardColor,
      Color accentOrange, Color infoBlue,
      Color textGrey, String name, String address, String? phone,
      String note) =>
      Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: isDark ? const Color(0xFF101828) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30)),
              boxShadow: isDark ? [] : [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
              ]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _buildCustomerInfo(
                isDark,
                cardColor,
                accentOrange,
                infoBlue,
                textGrey,
                name,
                address,
                phone),
            const SizedBox(height: 16),
            _buildNoteSection(isDark, note),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: _buildActionButton(
                      label: "navigate_customer_btn".tr,
                      icon: Icons.near_me_outlined,
                      color: infoBlue,
                      onTap: () {})),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildActionButton(
                      label: "arrived_customer_btn".tr,
                      icon: Icons.location_on_outlined,
                      color: accentOrange,
                      onTap: () {
                        final String orderId = widget.orderData?['_id']
                            ?.toString() ?? "";
                        if (orderId.isNotEmpty) {
                          _socketService.completeDelivery(orderId);
                          Get.to(() =>
                              ProofOfDeliveryScreen(
                                  orderData: widget.orderData));
                        }
                      }))
            ])
          ]));

  /// ويدجت عرض بيانات الزبون وأزرار الاتصال
  Widget _buildCustomerInfo(bool isDark, Color cardColor, Color accentOrange,
      Color infoBlue, Color textGrey,
      String name, String address, String? phone) =>
      Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isDark ? [] : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ]),
          child: Column(children: [
            Row(children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: infoBlue, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.location_on_outlined, color: textGrey,
                          size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(address,
                              style: TextStyle(color: textGrey, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis))
                    ])
                  ]))
            ]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: _buildContactButton(
                      isDark, "call_btn".tr, Icons.phone_outlined,
                      accentOrange, () {
                    if (phone != null) launchUrl(Uri.parse("tel:$phone"));
                  })),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildContactButton(
                      isDark, "message_btn".tr, Icons.chat_bubble_outline,
                      accentOrange, () {}))
            ])
          ]));

  /// قسم الملاحظات الخاصة بالطلب (مثل: البناية، الطابق، إلخ)
  Widget _buildNoteSection(bool isDark, String note) {
    const goldColor = Color(0xFFB88E2F);
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1D1B16) : Colors.orange.shade50
                .withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldColor.withOpacity(0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("note_title".tr,
              style: const TextStyle(
                  color: goldColor, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(note,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87,
                  fontSize: 13,
                  height: 1.4))
        ]));
  }

  Widget _buildContactButton(bool isDark, String label, IconData icon,
      Color color, VoidCallback onTap) =>
      ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18, color: color),
          label: Text(label, style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.grey.shade100,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))));

  Widget _buildActionButton(
      {required IconData icon, required String label, required Color color, required VoidCallback onTap}) =>
      ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 20),
          label:
          Text(label, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0));

  Widget _buildBadge(String text, Color color) =>
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3))),
          child: Text(text, style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)));

  /// بطاقة عائمة تعرض الوقت المقدر والمسافة المتبقية
  Widget _buildStatusCard(Color cardColor, Color textColor, bool isDark) =>
      Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: cardColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12)),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _infoItem("est_arrival_label".tr, "12 ${"min_unit".tr}", textColor),
            _infoItem("distance_label".tr, "3.2 km", textColor)
          ]));

  Widget _infoItem(String label, String value, Color textColor) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(
            color: textColor, fontWeight: FontWeight.bold, fontSize: 22))
      ]);
}