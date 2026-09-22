import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:simple_coffee_shop/core/constants/app_constants.dart';
import 'package:simple_coffee_shop/data/local/db_helper.dart';
import 'package:simple_coffee_shop/data/models/cart_item.dart';
import 'package:simple_coffee_shop/data/repositories/order_repository.dart';
import 'package:simple_coffee_shop/data/repositories/product_repository.dart';
import 'package:simple_coffee_shop/data/repositories/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    Get.reset();
    final dbPath = await databaseFactory.getDatabasesPath();
    await deleteDatabase(p.join(dbPath, 'kasir_kafe.db'));
  });

  test('seed, settings, and checkout persist an invoice', () async {
    final db = await DbHelper().init();
    Get.put(db);
    final settings = SettingsRepository();
    final products = ProductRepository();
    final orders = OrderRepository();

    expect(await settings.getPin(), AppConstants.defaultPin);
    expect(await settings.getShopName(), AppConstants.defaultShopName);

    await settings.setShopName('Kopi Senja');
    expect(await settings.getShopName(), 'Kopi Senja');

    final catalog = await products.getAll(activeOnly: true);
    expect(catalog, isNotEmpty);

    final first = catalog.first;
    final order = await orders.create(
      CreateOrderInput(
        items: [CartItem(product: first, qty: 2)],
        paymentMethod: 'qris',
        paid: first.price * 2,
        changeAmount: 0,
        total: first.price * 2,
      ),
    );

    expect(order.invoiceNo, startsWith('INV-'));
    expect(order.items, hasLength(1));
    expect(order.items.first.qty, 2);

    await products.setActive(first.id, false);
    final active = await products.getAll(activeOnly: true);
    expect(active.any((p) => p.id == first.id), isFalse);

    await products.delete(first.id);
    final remaining = await products.getAll();
    expect(remaining.any((p) => p.id == first.id), isFalse);

    final stored = await orders.getById(order.id);
    expect(stored?.items.first.productName, first.name);
  });
}
