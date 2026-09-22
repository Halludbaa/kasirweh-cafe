import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_coffee_shop/app/routes/app_pages.dart';
import 'package:simple_coffee_shop/app/routes/app_routes.dart';
import 'package:simple_coffee_shop/app/theme/app_theme.dart';

class KasirApp extends StatelessWidget {
  const KasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kasirweh Cafe',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: Routes.pin,
      getPages: AppPages.pages,
    );
  }
}
