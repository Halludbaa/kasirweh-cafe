import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:simple_coffee_shop/app/routes/app_routes.dart';
import 'package:simple_coffee_shop/app/theme/app_theme.dart';
import 'package:simple_coffee_shop/core/utils/formatters.dart';
import 'package:simple_coffee_shop/modules/shared/session_controllers.dart';

class CheckoutController extends GetxController {
  CheckoutController(this.cart);

  final CartController cart;
  late final TextEditingController paidController;

  @override
  void onInit() {
    super.onInit();
    cart.prepareCheckout();
    paidController = TextEditingController(text: '${cart.cashPaid.value}');
  }

  void chooseCash() {
    cart.selectCash();
    paidController.text = '${cart.cashPaid.value}';
  }

  @override
  void onClose() {
    paidController.dispose();
    super.onClose();
  }
}

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = controller.cart;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Text(
              'Barang dipesan',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...cart.items.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.product.name),
                  subtitle: Text(
                    '${formatRupiah(item.product.price)} x ${item.qty}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => cart.decrease(item.product.id),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${item.qty}'),
                      IconButton(
                        onPressed: () => cart.increase(item.product.id),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total ${formatRupiah(cart.total)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Metode pembayaran',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PayChip(
                    label: 'Tunai',
                    selected: cart.paymentMethod.value == 'cash',
                    onTap: controller.chooseCash,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PayChip(
                    label: 'QRIS',
                    selected: cart.paymentMethod.value == 'qris',
                    onTap: cart.selectQris,
                  ),
                ),
              ],
            ),
            if (cart.paymentMethod.value == 'cash') ...[
              const SizedBox(height: 16),
              TextField(
                controller: controller.paidController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Uang diterima',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  cart.setCashPaid(int.tryParse(value) ?? 0);
                },
              ),
              const SizedBox(height: 8),
              Text(
                cart.cashPaid.value < cart.total
                    ? 'Uang tunai masih kurang'
                    : 'Kembalian ${formatRupiah(cart.changeAmount)}',
                style: TextStyle(
                  color: cart.cashPaid.value < cart.total
                      ? Colors.red
                      : AppColors.brown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Center(
                child: QrImageView(
                  data: 'QRIS|${cart.total}',
                  size: 180,
                ),
              ),
              const Center(
                child: Text(
                  'Minta pelanggan scan QRIS dummy ini',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton(
              onPressed: cart.canConfirmPayment && cart.items.isNotEmpty
                  ? () => Get.toNamed(Routes.paymentConfirm)
                  : null,
              child: const Text('Lanjut konfirmasi'),
            ),
          ),
        );
      }),
    );
  }
}

class _PayChip extends StatelessWidget {
  const _PayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Center(child: Text(label)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.brown,
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.brown),
    );
  }
}
