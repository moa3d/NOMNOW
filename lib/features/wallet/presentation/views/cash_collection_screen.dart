import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/wallet_controller.dart';

class CashCollectionScreen extends StatelessWidget {
  const CashCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletController = Get.find<WalletController>();
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF101828) : Colors.grey.shade50;
    final cardColor = isDark ? const Color(0xFF1D2939) : Colors.white;
    const accentOrange = Color(0xFFFF5630);
    const warningGold = Color(0xFFF79009);
    final textGrey = isDark ? const Color(0xFF98A2B3) : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Get.back(id: 1),
        ),
        title: Column(
          children: [
            Text(
              "cash_collection_title".tr,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "financial_transactions".tr,
              style: TextStyle(color: textGrey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: textGrey),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: Obx(() {
        if (walletController.isLoading.value &&
            walletController.cashOrders.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: accentOrange));
        }

        final sum = walletController.cashSummary;

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => walletController.fetchCashOrders(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildTopStatCard(
                            isDark,
                            "total_collected".tr,
                            "\$${(sum['totalCollected'] ?? 0).toStringAsFixed(
                                2)}",
                            Icons.attach_money,
                            const Color(0xFFF04438),
                            cardColor,
                          ),
                          const SizedBox(width: 12),
                          _buildTopStatCard(
                            isDark,
                            "pending_settlement".tr,
                            "\$${(sum['pendingSettlement'] ?? 0)
                                .toStringAsFixed(2)}",
                            Icons.access_time,
                            warningGold,
                            cardColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildHighlightCard(
                        isDark,
                        warningGold,
                        sum['cashHeldForSettlement'] ?? 0.0,
                      ),
                      const SizedBox(height: 24),
                      _buildFilterTabs(walletController, cardColor, isDark),
                      const SizedBox(height: 24),
                      _buildTransactionsTable(
                        isDark,
                        cardColor,
                        walletController.filteredCashOrders,
                        textGrey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomSummary(isDark, sum, cardColor, textGrey),
          ],
        );
      }),
    );
  }

  Widget _buildTopStatCard(bool isDark, String title, String value,
      IconData icon, Color color, Color cardBg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                  color: isDark ? const Color(0xFF98A2B3) : Colors.grey
                      .shade600, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: isDark ? Colors.white : Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard(bool isDark, Color gold, dynamic amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? gold.withOpacity(0.1) : Colors.orange.shade50
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: gold.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.attach_money, color: isDark ? gold : Colors.white,
                size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "cash_held_label".tr,
                style: TextStyle(color: isDark ? gold : Colors.orange.shade900,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${(amount ?? 0).toStringAsFixed(2)}",
                style: TextStyle(color: isDark ? Colors.white : Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "not_included_earning".tr,
                style: TextStyle(
                    color: isDark ? const Color(0xFF98A2B3) : Colors.grey
                        .shade600, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(WalletController controller, Color cardBg,
      bool isDark) {
    final filters = [
      {'id': 'all', 'label': 'all_filter'.tr, 'color': const Color(0xFF2E90FA)},
      {
        'id': 'pending',
        'label': 'pending_filter'.tr,
        'color': const Color(0xFFF79009)
      },
      {
        'id': 'settled',
        'label': 'settled_filter'.tr,
        'color': const Color(0xFF12B76A)
      },
      {
        'id': 'disputed',
        'label': 'disputed_filter'.tr,
        'color': const Color(0xFFF04438)
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() =>
          Row(
            children: filters.map((f) {
              bool isSelected = controller.selectedCashFilter.value == f['id'];
              Color activeColor = f['color'] as Color;

              return GestureDetector(
                onTap: () =>
                controller.selectedCashFilter.value = f['id'] as String,
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: (isSelected || isDark) ? [] : [
                      BoxShadow(color: Colors.black.withOpacity(0.05),
                          blurRadius: 5)
                    ],
                  ),
                  child: Text(
                    "${f['label']}",
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? const Color(
                          0xFF98A2B3) : Colors.grey.shade600),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }

  Widget _buildTransactionsTable(bool isDark, Color cardBg, List orders,
      Color textGrey) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black
                .withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey
                  .shade100,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2,
                    child: Text("order_col".tr, style: TextStyle(
                        color: textGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold))),
                Expanded(flex: 2,
                    child: Text("amount_col".tr, style: TextStyle(
                        color: textGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold))),
                Expanded(flex: 2,
                    child: Text("status_col".tr, style: TextStyle(
                        color: textGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold))),
                Expanded(flex: 2,
                    child: Text("settlement_col".tr, style: TextStyle(
                        color: textGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right)),
              ],
            ),
          ),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                  "no_orders_found".tr, style: TextStyle(color: textGrey)),
            ),
          ...orders.map((o) => _buildDataRow(o, textGrey, isDark)),
        ],
      ),
    );
  }

  Widget _buildDataRow(dynamic o, Color textGrey, bool isDark) {
    Color statusColor = textGrey;
    IconData statusIcon = Icons.circle;
    String statusKey = o['driverPaymentStatus'].toString().toLowerCase();
    String statusLabel = statusKey.capitalizeFirst!;

    if (statusKey == 'settled') {
      statusColor = const Color(0xFF12B76A);
      statusIcon = Icons.check_circle_outline;
      statusLabel = "settled_filter".tr;
    } else if (statusKey == 'pending') {
      statusColor = const Color(0xFFF79009);
      statusIcon = Icons.access_time;
      statusLabel = "pending_filter".tr;
    } else if (statusKey == 'disputed') {
      statusColor = const Color(0xFFF04438);
      statusIcon = Icons.warning_amber_rounded;
      statusLabel = "disputed_filter".tr;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border(
          bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12))),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("#${o['orderNumber']}", style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
                Text(DateFormat('MMM d, yyyy').format(
                    DateTime.parse(o['createdAt'])),
                    style: TextStyle(color: textGrey, fontSize: 10)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("\$${(o['totalPrice'] ?? 0).toStringAsFixed(2)}",
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text(o['customer']?['name'] ?? "—",
                    style: TextStyle(color: textGrey, fontSize: 10),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: statusColor, size: 12),
                  const SizedBox(width: 4),
                  Flexible(child: Text(statusLabel, style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  o['settledAt'] != null ? DateFormat('MMM d').format(
                      DateTime.parse(o['settledAt'])) : "pending_filter".tr,
                  style: TextStyle(color: textGrey, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(bool isDark, dynamic sum, Color cardBg,
      Color textGrey) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cardBg,
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4))
          ]
      ),
      child: Row(
        children: [
          _buildSummaryBox(isDark, "pending_filter".tr,
              "\$${(sum['pendingSettlement'] ?? 0).toStringAsFixed(2)}",
              const Color(0xFFF79009), textGrey),
          const SizedBox(width: 12),
          _buildSummaryBox(isDark, "settled_filter".tr,
              "\$${(sum['totalSettled'] ?? 0).toStringAsFixed(2)}",
              const Color(0xFF12B76A), textGrey),
          const SizedBox(width: 12),
          _buildSummaryBox(isDark, "disputed_filter".tr,
              "\$${(sum['totalDisputed'] ?? 0).toStringAsFixed(2)}",
              const Color(0xFFF04438), textGrey),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(bool isDark, String label, String value, Color color,
      Color textGrey) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black
                  .withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: textGrey, fontSize: 10)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}