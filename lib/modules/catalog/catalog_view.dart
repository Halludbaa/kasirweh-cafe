import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_coffee_shop/app/routes/app_routes.dart';
import 'package:simple_coffee_shop/app/theme/app_theme.dart';
import 'package:simple_coffee_shop/core/utils/formatters.dart';
import 'package:simple_coffee_shop/data/models/category.dart';
import 'package:simple_coffee_shop/data/models/product.dart';
import 'package:simple_coffee_shop/data/repositories/category_repository.dart';
import 'package:simple_coffee_shop/data/repositories/product_repository.dart';
import 'package:simple_coffee_shop/modules/shared/product_image.dart';
import 'package:simple_coffee_shop/modules/shared/session_controllers.dart';

class CatalogController extends GetxController {
  CatalogController(this._products, this._categories);

  final ProductRepository _products;
  final CategoryRepository _categories;

  final products = <Product>[].obs;
  final categories = <Category>[].obs;
  final selectedCategoryId = 0.obs;

  List<Product> get visible {
    if (selectedCategoryId.value == 0) return products;
    return products
        .where((p) => p.categoryId == selectedCategoryId.value)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    categories.assignAll(await _categories.getAll());
    products.assignAll(await _products.getAll(activeOnly: true));
  }
}

class CatalogView extends GetView<CatalogController> {
  const CatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Catalog')),
      body: Column(
        children: [
          Obx(() {
            return SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _Chip(
                    label: 'Semua',
                    selected: controller.selectedCategoryId.value == 0,
                    onTap: () => controller.selectedCategoryId.value = 0,
                  ),
                  ...controller.categories.map(
                    (c) => _Chip(
                      label: c.name,
                      selected: controller.selectedCategoryId.value == c.id,
                      onTap: () => controller.selectedCategoryId.value = c.id,
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              final items = controller.visible;
              if (items.isEmpty) {
                return const Center(child: Text('Tidak ada produk aktif'));
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  return _ProductCard(
                    product: product,
                    onTap: () => cart.add(product),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        return Material(
          elevation: 8,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: FilledButton(
                onPressed: cart.canCheckout
                    ? () {
                        cart.prepareCheckout();
                        Get.toNamed(Routes.checkout);
                      }
                    : null,
                child: Text(
                  cart.canCheckout
                      ? 'Checkout • ${formatRupiah(cart.total)} (${cart.itemCount})'
                      : 'Pilih produk',
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.brown,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.brown),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: ProductImage(path: product.imagePath, size: 92),
                ),
              ),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                formatRupiah(product.price),
                style: const TextStyle(color: AppColors.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
