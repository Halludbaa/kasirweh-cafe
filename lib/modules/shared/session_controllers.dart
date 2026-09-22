import 'package:get/get.dart';
import 'package:simple_coffee_shop/core/constants/app_constants.dart';
import 'package:simple_coffee_shop/data/models/cart_item.dart';
import 'package:simple_coffee_shop/data/models/product.dart';

class CartController extends GetxController {
  final items = <CartItem>[].obs;
  final paymentMethod = 'cash'.obs;
  final cashPaid = 0.obs;

  int get total => items.fold(0, (sum, item) => sum + item.lineTotal);

  int get itemCount => items.fold(0, (sum, item) => sum + item.qty);

  int get changeAmount {
    if (paymentMethod.value != 'cash') return 0;
    final diff = cashPaid.value - total;
    return diff < 0 ? 0 : diff;
  }

  bool get canCheckout => items.isNotEmpty;

  bool get canConfirmPayment {
    if (items.isEmpty) return false;
    if (paymentMethod.value == 'qris') return true;
    return cashPaid.value >= total;
  }

  void add(Product product) {
    final index = items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      items[index].qty += 1;
      items.refresh();
    } else {
      items.add(CartItem(product: product));
    }
  }

  void increase(int productId) {
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;
    items[index].qty += 1;
    items.refresh();
  }

  void decrease(int productId) {
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;
    if (items[index].qty <= 1) {
      items.removeAt(index);
    } else {
      items[index].qty -= 1;
      items.refresh();
    }
  }

  void remove(int productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void selectCash() {
    paymentMethod.value = 'cash';
    if (cashPaid.value < total) cashPaid.value = total;
  }

  void selectQris() {
    paymentMethod.value = 'qris';
    cashPaid.value = total;
  }

  void setCashPaid(int value) {
    cashPaid.value = value;
  }

  void prepareCheckout() {
    if (paymentMethod.value == 'cash' && cashPaid.value < total) {
      cashPaid.value = total;
    }
    if (paymentMethod.value == 'qris') {
      cashPaid.value = total;
    }
  }

  void clear() {
    items.clear();
    paymentMethod.value = 'cash';
    cashPaid.value = 0;
  }
}

class ShopController extends GetxController {
  ShopController(this._loadName);

  final Future<String> Function() _loadName;
  final shopName = AppConstants.defaultShopName.obs;

  @override
  void onInit() {
    super.onInit();
    refreshName();
  }

  Future<void> refreshName() async {
    shopName.value = await _loadName();
  }

  void setName(String name) {
    shopName.value = name;
  }
}
