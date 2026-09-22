import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_coffee_shop/core/constants/app_constants.dart';
import 'package:simple_coffee_shop/data/repositories/settings_repository.dart';
import 'package:simple_coffee_shop/modules/shared/session_controllers.dart';

class SettingsPageController extends GetxController {
  SettingsPageController(this._settings, this._shop);

  final SettingsRepository _settings;
  final ShopController _shop;
  late final TextEditingController nameController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(text: _shop.shopName.value);
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Nama toko', 'Tidak boleh kosong');
      return;
    }
    await _settings.setShopName(name);
    _shop.setName(name);
    Get.back();
    Get.snackbar('Tersimpan', 'Nama toko diperbarui');
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

class SettingsView extends GetView<SettingsPageController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: 'Nama toko',
                hintText: AppConstants.defaultShopName,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: controller.save,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
