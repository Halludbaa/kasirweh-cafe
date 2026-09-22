import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:simple_coffee_shop/app/theme/app_theme.dart';
import 'package:simple_coffee_shop/core/constants/app_constants.dart';
import 'package:simple_coffee_shop/data/models/category.dart';
import 'package:simple_coffee_shop/data/models/product.dart';
import 'package:simple_coffee_shop/data/repositories/category_repository.dart';
import 'package:simple_coffee_shop/data/repositories/product_repository.dart';
import 'package:simple_coffee_shop/modules/shared/product_image.dart';

class ProductFormController extends GetxController {
  ProductFormController(this._products, this._categories);

  final ProductRepository _products;
  final CategoryRepository _categories;

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final categories = <Category>[].obs;
  final categoryId = 0.obs;
  final imagePath = AppConstants.defaultProductImage.obs;
  final isActive = true.obs;
  final loading = true.obs;
  int? editingId;

  bool get isEditing => editingId != null;

  @override
  void onInit() {
    super.onInit();
    editingId = Get.arguments as int?;
    _load();
  }

  Future<void> _load() async {
    categories.assignAll(await _categories.getAll());
    if (categories.isNotEmpty && categoryId.value == 0) {
      categoryId.value = categories.first.id;
    }
    if (editingId != null) {
      final product = await _products.getById(editingId!);
      if (product != null) {
        nameController.text = product.name;
        priceController.text = '${product.price}';
        categoryId.value = product.categoryId;
        imagePath.value = product.imagePath;
        isActive.value = product.isActive;
      }
    }
    loading.value = false;
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    final price = int.tryParse(priceController.text) ?? 0;
    if (name.isEmpty || price <= 0 || categoryId.value == 0) {
      Get.snackbar('Lengkapi data', 'Nama, kategori, dan harga wajib diisi');
      return;
    }
    final product = Product(
      id: editingId ?? 0,
      categoryId: categoryId.value,
      name: name,
      price: price,
      imagePath: imagePath.value,
      isActive: isActive.value,
    );
    if (isEditing) {
      await _products.update(product);
    } else {
      await _products.insert(product);
    }
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    super.onClose();
  }
}

class ProductFormView extends GetView<ProductFormController> {
  const ProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(controller.isEditing ? 'Ubah produk' : 'Tambah produk'),
        ),
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: 'Nama produk',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Harga (rupiah)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: controller.categoryId.value,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: controller.categories
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) controller.categoryId.value = value;
              },
            ),
            const SizedBox(height: 16),
            const Text('Gambar dummy'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.dummyImages.map((path) {
                final selected = controller.imagePath.value == path;
                return GestureDetector(
                  onTap: () => controller.imagePath.value = path,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selected ? AppColors.brown : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ProductImage(path: path, size: 56),
                  ),
                );
              }).toList(),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Aktif di catalog'),
              value: controller.isActive.value,
              onChanged: (value) => controller.isActive.value = value,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: controller.save,
              child: const Text('Simpan'),
            ),
          ],
        );
      }),
    );
  }
}
