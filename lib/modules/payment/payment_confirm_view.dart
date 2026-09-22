import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_coffee_shop/app/routes/app_routes.dart';
import 'package:simple_coffee_shop/app/theme/app_theme.dart';
import 'package:simple_coffee_shop/core/utils/formatters.dart';
import 'package:simple_coffee_shop/data/repositories/order_repository.dart';
import 'package:simple_coffee_shop/data/services/print_service.dart';
import 'package:simple_coffee_shop/modules/shared/session_controllers.dart';

class PaymentConfirmController extends GetxController {
  PaymentConfirmController(this._orders, this._print, this._cart, this._shop);

  final OrderRepository _orders;
  final PrintService _print;
  final CartController _cart;
  final ShopController _shop;

  final submitting = false.obs;

  String get methodLabel =>
      _cart.paymentMethod.value == 'cash' ? 'Tunai' : 'QRIS';

  Future<void> complete() async {
    if (submitting.value || !_cart.canConfirmPayment) return;
    submitting.value = true;
    try {
      final paid = _cart.paymentMethod.value == 'qris'
          ? _cart.total
          : _cart.cashPaid.value;
      final order = await _orders.create(
        CreateOrderInput(
          items: _cart.items.toList(),
          paymentMethod: _cart.paymentMethod.value,
          paid: paid,
          changeAmount: _cart.paymentMethod.value == 'cash'
              ? _cart.changeAmount
              : 0,
          total: _cart.total,
        ),
      );
      // await _print.printInvoice(
      //   shopName: _shop.shopName.value,
      //   order: order,
      // );
      final invoiceNo = order.invoiceNo;
      _cart.clear();
      Get.offAllNamed(Routes.home);
      Future.delayed(const Duration(milliseconds: 250), () {
        Get.snackbar(
          'Pembayaran selesai',
          'Invoice $invoiceNo tersimpan',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      Get.snackbar('Gagal', 'Transaksi tidak tersimpan');
    } finally {
      submitting.value = false;
    }
  }
}

class PaymentConfirmView extends GetView<PaymentConfirmController> {
  const PaymentConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Metode pembayaran'),
                      const SizedBox(height: 8),
                      Text(
                        controller.methodLabel,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brown,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatRupiah(cart.total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (cart.paymentMethod.value == 'cash') ...[
                        const SizedBox(height: 8),
                        Text('Diterima ${formatRupiah(cart.cashPaid.value)}'),
                        Text('Kembalian ${formatRupiah(cart.changeAmount)}'),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: controller.submitting.value
                    ? null
                    : () => Get.back(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Batal'),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: controller.submitting.value
                    ? null
                    : controller.complete,
                child: controller.submitting.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Selesaikan pembayaran'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
