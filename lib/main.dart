import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simple_coffee_shop/app/app.dart';
import 'package:simple_coffee_shop/data/local/db_helper.dart';
import 'package:simple_coffee_shop/data/repositories/category_repository.dart';
import 'package:simple_coffee_shop/data/repositories/order_repository.dart';
import 'package:simple_coffee_shop/data/repositories/product_repository.dart';
import 'package:simple_coffee_shop/data/repositories/settings_repository.dart';
import 'package:simple_coffee_shop/data/services/print_service.dart';
import 'package:simple_coffee_shop/modules/shared/session_controllers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  final db = await DbHelper().init();
  Get.put(db, permanent: true);
  Get.put(SettingsRepository(), permanent: true);
  Get.put(CategoryRepository(), permanent: true);
  Get.put(ProductRepository(), permanent: true);
  Get.put(OrderRepository(), permanent: true);
  Get.put(PrintService(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(
    ShopController(() => Get.find<SettingsRepository>().getShopName()),
    permanent: true,
  );

  runApp(const KasirApp());
}
