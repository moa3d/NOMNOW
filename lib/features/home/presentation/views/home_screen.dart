import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:get_storage/get_storage.dart';

import 'package:delivery_app/core/constants/app_colors.dart';
import 'package:delivery_app/data/services/socket_service.dart';
import 'package:delivery_app/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:delivery_app/features/auth/presentation/controllers/auth_controller.dart';

import '../../../../core/widgets/custom_leading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SocketService _socketService = Get.find<SocketService>();
  final WalletController _walletController = Get.put(WalletController());
  final AuthController _authController = Get.find<AuthController>();
  final _storage = GetStorage();
  final MapController _mapController = MapController();

  final LatLng driverLocation = const LatLng(32.5410, 35.8655);
  LatLng _currentLocation = const LatLng(32.5410, 35.8655);
  StreamSubscription<Position>? _positionStream;
  final RxBool _isLocalOnline = false.obs;

  @override
  void initState() {
    super.initState();
    _initializeHomeData();
  }

  void _initializeHomeData() {
    _isLocalOnline.value = _storage.read('isOnline') ?? false;
    _startLocationTracking();
    _walletController.fetchWalletSummary();

    _authController.fetchDriverData().then((_) {
      String status = _authController.driverData['availability'] ?? 'offline';
      bool isOnline = (status == 'online' || status == 'busy');
      if (_isLocalOnline.value != isOnline) {
        _isLocalOnline.value = isOnline;
        _storage.write('isOnline', isOnline);
      }
    });
  }

  void _toggleStatus(bool val) {
    _isLocalOnline.value = val;
    _storage.write('isOnline', val);
    if (val) {
      _socketService.goOnline();
      _socketService.updateLocation(
          _currentLocation.latitude, _currentLocation.longitude);
      _mapController.move(_currentLocation, 15.0);
    } else {
      _socketService.goOffline();
    }
  }

  Future<void> _startLocationTracking() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((pos) {
      if (mounted) {
        setState(() => _currentLocation = LatLng(pos.latitude, pos.longitude));
        if (_isLocalOnline.value) _socketService.updateLocation(
            pos.latitude, pos.longitude);
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey.shade100,
      appBar: _buildAppBar(isDark),
      body: Stack(
        children: [
          _buildMapLayer(isDark),
          _buildOverlayUI(isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                isDark ? const Color(0xFF3D2621) : Colors.orange.shade100,
                isDark ? AppColors.darkBackground : Colors.white,
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark ? [] : [
            const BoxShadow(color: Colors.black12, blurRadius: 4)
          ],
        ),
        child: CustomLeading(
            icon: Icons.menu, onPressed: () => Get.toNamed('/settings')),
      ),
      title: Obx(() =>
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 4,
                  backgroundColor: _isLocalOnline.value ? Colors.green : Colors
                      .grey),
              const SizedBox(width: 8),
              Text(_isLocalOnline.value ? "online".tr : "offline".tr,
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          )),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomLeading(icon: Icons.notifications,
              onPressed: () => Get.toNamed('/notifications')),
        ),
      ],
    );
  }

  Widget _buildMapLayer(bool isDark) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: driverLocation, initialZoom: 15.0),
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
        MarkerLayer(
          markers: [
            Marker(
              point: _currentLocation, width: 60, height: 60,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 5)
                      ],
                    ),
                    child: const Icon(
                        Icons.directions_car, color: Colors.white, size: 25),
                  ),
                  const Icon(
                      Icons.arrow_drop_down, color: AppColors.primaryOrange,
                      size: 20),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverlayUI(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildStatusCard(isDark),
          const Spacer(),
          _buildQuickStats(isDark),
          const SizedBox(height: 20),
          Obx(() =>
          _isLocalOnline.value
              ? _buildWaitingOrdersButton()
              : _buildBottomGuidance(isDark)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Obx(() {
        bool online = _isLocalOnline.value;
        return Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: !online ? (isDark ? const Color(0xFF2D323F) : Colors
                        .grey.shade200) : AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.power_settings_new,
                      color: online ? Colors.white : (isDark
                          ? Colors.white70
                          : Colors.grey)),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("status_label".tr, style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 12)),
                    Text(online ? "online_msg".tr : "go_online_msg".tr,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: online,
                    trackOutlineColor: const WidgetStatePropertyAll(
                        Colors.transparent),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade400,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primaryOrange,
                    onChanged: _toggleStatus,
                  ),
                ),
              ],
            ),
            if (online) ...[
              const SizedBox(height: 10),
              Divider(thickness: 0.3,
                  color: isDark ? Colors.grey : Colors.grey.shade300),
              Align(alignment: AlignmentDirectional.centerStart,
                  child: Text("ready_accept_msg".tr, style: const TextStyle(
                      color: AppColors.primaryOrange, fontSize: 14))),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Obx(() {
      final summary = _walletController.walletSummary;
      return Row(
        children: [
          _buildStatCard(
              "earnings_today".tr, "${summary['totalEarningsToday'] ?? '0.00'}",
              Icons.attach_money, Colors.orange, Icons.trending_up, isDark),
          const SizedBox(width: 15),
          _buildStatCard(
              "orders_today".tr, (summary['todayOrdersCount'] ?? 0).toString(),
              Icons.inventory_2_outlined, Colors.blue, Icons.access_time,
              isDark),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      Color iconColor, IconData trendIcon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          border: Border.all(color: AppColors.primaryOrange.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: iconColor, size: 20)),
                Icon(trendIcon, color: iconColor.withOpacity(0.6), size: 16),
              ],
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(
                color: AppColors.textGrey, fontSize: 12)),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingOrdersButton() {
    return Container(
      width: double.infinity, height: 50,
      decoration: BoxDecoration(
        color: AppColors.primaryOrange, borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Text("waiting_orders".tr, style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomGuidance(bool isDark) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        children: [
          Icon(Icons.info_outline,
              color: AppColors.primaryOrange.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text("offline_guidance_msg".tr, textAlign: TextAlign.center,
              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}