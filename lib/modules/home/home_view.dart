import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_coffee_shop/app/routes/app_routes.dart';
import 'package:simple_coffee_shop/app/theme/app_theme.dart';
import 'package:simple_coffee_shop/core/utils/formatters.dart';
import 'package:simple_coffee_shop/data/repositories/order_repository.dart';
import 'package:simple_coffee_shop/modules/shared/session_controllers.dart';

class HomeController extends GetxController {
  HomeController(this._orders);

  final OrderRepository _orders;
  final days = <DailyIncome>[].obs;
  final loading = true.obs;

  int get weekTotal => days.fold(0, (sum, item) => sum + item.total);

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  @override
  void onReady() {
    super.onReady();
    refreshData();
  }

  Future<void> refreshData() async {
    loading.value = true;
    days.assignAll(await _orders.lastSevenDaysIncome());
    loading.value = false;
  }
}

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = Get.find<ShopController>();
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Obx(
                () => Text(
                  shop.shopName.value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brownDark,
                  ),
                ),
              ),
              const Text(
                'Ringkasan kasir',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pemasukan 7 hari',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Obx(() {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatRupiah(controller.weekTotal),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brown,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: _IncomeChart(days: controller.days.toList()),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              const Text(
                'Quick Access',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  _QuickCard(
                    icon: Icons.grid_view_rounded,
                    label: 'Catalog',
                    onTap: () => Get.toNamed(Routes.catalog),
                  ),
                  _QuickCard(
                    icon: Icons.receipt_long,
                    label: 'Invoice list',
                    onTap: () => Get.toNamed(Routes.invoices),
                  ),
                  _QuickCard(
                    icon: Icons.edit_note,
                    label: 'Edit catalog',
                    onTap: () => Get.toNamed(Routes.editCatalog),
                  ),
                  _QuickCard(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () => Get.toNamed(Routes.settings),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.brown.withValues(alpha: 0.12),
                child: Icon(icon, color: AppColors.brown),
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomeChart extends StatelessWidget {
  const _IncomeChart({required this.days});

  final List<DailyIncome> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const Center(child: Text('Belum ada data'));
    }
    final maxY = days.fold<int>(0, (m, e) => e.total > m ? e.total : m);
    final chartMax = maxY == 0 ? 10000 : maxY * 1.2;

    return BarChart(
      BarChartData(
        maxY: chartMax.toDouble(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= days.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  formatDayLabel(days[index].day),
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: days[i].total.toDouble(),
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.accent,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
