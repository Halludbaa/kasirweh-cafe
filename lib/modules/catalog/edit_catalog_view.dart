import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:simple_coffee_shop/app/routes/app_routes.dart';
import 'package:simple_coffee_shop/app/theme/app_theme.dart';
import 'package:simple_coffee_shop/core/utils/formatters.dart';
import 'package:simple_coffee_shop/data/models/product.dart';
import 'package:simple_coffee_shop/data/repositories/product_repository.dart';
import 'package:simple_coffee_shop/modules/shared/product_image.dart';

class EditCatalogController extends GetxController {
  EditCatalogController(this._products);

  final ProductRepository _products;
  final products = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    products.assignAll(await _products.getAll());
  }

  Future<void> toggle(Product product) async {
    await _products.setActive(product.id, !product.isActive);
    await load();
  }

  Future<void> remove(Product product) async {
    await _products.delete(product.id);
    await load();
  }
}

class EditCatalogView extends GetView<EditCatalogController> {
  const EditCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit catalog')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brown,
        onPressed: () async {
          await Get.toNamed(Routes.productForm);
          controller.load();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.products.isEmpty) {
          return const Center(child: Text('Catalog kosong'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Slidable(
                key: ValueKey(product.id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => controller.remove(product),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Hapus',
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ],
                ),
                child: Card(
                  child: ListTile(
                    leading: ProductImage(path: product.imagePath),
                    title: Text(product.name),
                    subtitle: Text(
                      '${formatRupiah(product.price)} • ${product.isActive ? 'Aktif' : 'Nonaktif'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () async {
                            await Get.toNamed(
                              Routes.productForm,
                              arguments: product.id,
                            );
                            controller.load();
                          },
                          icon: const Icon(Icons.edit, color: AppColors.brown),
                        ),
                        Switch(
                          value: product.isActive,
                          activeThumbColor: AppColors.brown,
                          onChanged: (_) => controller.toggle(product),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
