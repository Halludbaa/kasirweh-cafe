import 'package:get/get.dart';
import 'package:simple_coffee_shop/app/routes/app_routes.dart';
import 'package:simple_coffee_shop/data/repositories/category_repository.dart';
import 'package:simple_coffee_shop/data/repositories/order_repository.dart';
import 'package:simple_coffee_shop/data/repositories/product_repository.dart';
import 'package:simple_coffee_shop/data/repositories/settings_repository.dart';
import 'package:simple_coffee_shop/data/services/print_service.dart';
import 'package:simple_coffee_shop/modules/catalog/catalog_view.dart';
import 'package:simple_coffee_shop/modules/catalog/edit_catalog_view.dart';
import 'package:simple_coffee_shop/modules/catalog/product_form_view.dart';
import 'package:simple_coffee_shop/modules/checkout/checkout_view.dart';
import 'package:simple_coffee_shop/modules/home/home_view.dart';
import 'package:simple_coffee_shop/modules/invoices/invoice_views.dart';
import 'package:simple_coffee_shop/modules/payment/payment_confirm_view.dart';
import 'package:simple_coffee_shop/modules/pin/pin_view.dart';
import 'package:simple_coffee_shop/modules/settings/settings_view.dart';
import 'package:simple_coffee_shop/modules/shared/session_controllers.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: Routes.pin,
      page: () => const PinView(),
      binding: BindingsBuilder(() {
        Get.put(PinController(Get.find<SettingsRepository>()));
      }),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(Get.find<OrderRepository>()));
      }),
    ),
    GetPage(
      name: Routes.catalog,
      page: () => const CatalogView(),
      binding: BindingsBuilder(() {
        Get.put(
          CatalogController(
            Get.find<ProductRepository>(),
            Get.find<CategoryRepository>(),
          ),
        );
      }),
    ),
    GetPage(
      name: Routes.checkout,
      page: () => const CheckoutView(),
      binding: BindingsBuilder(() {
        Get.put(CheckoutController(Get.find<CartController>()));
      }),
    ),
    GetPage(
      name: Routes.paymentConfirm,
      page: () => const PaymentConfirmView(),
      binding: BindingsBuilder(() {
        Get.put(
          PaymentConfirmController(
            Get.find<OrderRepository>(),
            Get.find<PrintService>(),
            Get.find<CartController>(),
            Get.find<ShopController>(),
          ),
        );
      }),
    ),
    GetPage(
      name: Routes.invoices,
      page: () => const InvoiceListView(),
      binding: BindingsBuilder(() {
        Get.put(InvoiceListController(Get.find<OrderRepository>()));
      }),
    ),
    GetPage(
      name: Routes.invoiceDetail,
      page: () => const InvoiceDetailView(),
      binding: BindingsBuilder(() {
        Get.put(
          InvoiceDetailController(
            Get.find<OrderRepository>(),
            Get.find<PrintService>(),
            Get.find<ShopController>(),
          ),
        );
      }),
    ),
    GetPage(
      name: Routes.editCatalog,
      page: () => const EditCatalogView(),
      binding: BindingsBuilder(() {
        Get.put(EditCatalogController(Get.find<ProductRepository>()));
      }),
    ),
    GetPage(
      name: Routes.productForm,
      page: () => const ProductFormView(),
      binding: BindingsBuilder(() {
        Get.put(
          ProductFormController(
            Get.find<ProductRepository>(),
            Get.find<CategoryRepository>(),
          ),
        );
      }),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.put(
          SettingsPageController(
            Get.find<SettingsRepository>(),
            Get.find<ShopController>(),
          ),
        );
      }),
    ),
  ];
}
