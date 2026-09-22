import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_coffee_shop/app/routes/app_routes.dart';
import 'package:simple_coffee_shop/core/utils/formatters.dart';
import 'package:simple_coffee_shop/data/models/order.dart';
import 'package:simple_coffee_shop/data/repositories/order_repository.dart';
import 'package:simple_coffee_shop/data/services/print_service.dart';
import 'package:simple_coffee_shop/modules/shared/session_controllers.dart';

class InvoiceListController extends GetxController {
  InvoiceListController(this._orders);

  final OrderRepository _orders;
  final orders = <Order>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    orders.assignAll(await _orders.getAll());
  }
}

class InvoiceListView extends GetView<InvoiceListController> {
  const InvoiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice list')),
      body: Obx(() {
        if (controller.orders.isEmpty) {
          return const Center(child: Text('Belum ada invoice'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return Card(
              child: ListTile(
                title: Text(order.invoiceNo),
                subtitle: Text(
                  '${order.paymentLabel} • ${formatDateTime(order.createdAt)}',
                ),
                trailing: Text(
                  formatRupiah(order.total),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () => Get.toNamed(
                  Routes.invoiceDetail,
                  arguments: order.id,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class InvoiceDetailController extends GetxController {
  InvoiceDetailController(this._orders, this._print, this._shop);

  final OrderRepository _orders;
  final PrintService _print;
  final ShopController _shop;
  final order = Rxn<Order>();

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments as int;
    _load(id);
  }

  Future<void> _load(int id) async {
    order.value = await _orders.getById(id);
  }

  Future<void> reprint() async {
    final current = order.value;
    if (current == null) return;
    await _print.printInvoice(
      shopName: _shop.shopName.value,
      order: current,
    );
    Get.snackbar(
      'Print',
      'Jika printer terhubung, struk akan tercetak. Jika tidak, diabaikan.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class InvoiceDetailView extends GetView<InvoiceDetailController> {
  const InvoiceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail invoice')),
      body: Obx(() {
        final order = controller.order.value;
        if (order == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              order.invoiceNo,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(formatDateTime(order.createdAt)),
            Text('Metode: ${order.paymentLabel}'),
            const Divider(height: 28),
            ...order.items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.productName),
                subtitle: Text('${item.qty} x ${formatRupiah(item.unitPrice)}'),
                trailing: Text(formatRupiah(item.lineTotal)),
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Total'),
              trailing: Text(
                formatRupiah(order.total),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (order.isCash) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tunai'),
                trailing: Text(formatRupiah(order.paid)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Kembalian'),
                trailing: Text(formatRupiah(order.changeAmount)),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: controller.reprint,
              icon: const Icon(Icons.print),
              label: const Text('Print invoice'),
            ),
          ],
        );
      }),
    );
  }
}
