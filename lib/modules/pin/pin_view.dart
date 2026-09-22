import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:simple_coffee_shop/app/routes/app_routes.dart';
import 'package:simple_coffee_shop/app/theme/app_theme.dart';
import 'package:simple_coffee_shop/data/repositories/settings_repository.dart';

class PinController extends GetxController {
  PinController(this._settings);

  final SettingsRepository _settings;
  final pin = ''.obs;
  final error = ''.obs;

  void tap(String digit) {
    error.value = '';
    if (pin.value.length >= 6) return;
    pin.value += digit;
    if (pin.value.length == 6) {
      _verify();
    }
  }

  void backspace() {
    error.value = '';
    if (pin.value.isEmpty) return;
    pin.value = pin.value.substring(0, pin.value.length - 1);
  }

  Future<void> _verify() async {
    final saved = await _settings.getPin();
    if (pin.value == saved) {
      Get.offAllNamed(Routes.home);
      return;
    }
    error.value = 'PIN salah';
    pin.value = '';
    HapticFeedback.heavyImpact();
  }
}

class PinView extends GetView<PinController> {
  const PinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.lock_outline, color: Colors.white, size: 42),
              const SizedBox(height: 16),
              const Text(
                'Masukkan PIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'PIN default: 000000',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 28),
              Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    final filled = index < controller.pin.value.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? Colors.white : Colors.white24,
                      ),
                    );
                  }),
                );
              }),
              const SizedBox(height: 12),
              Obx(() => Text(
                    controller.error.value,
                    style: const TextStyle(color: Color(0xFFFFAB91)),
                  )),
              const Spacer(),
              _Pad(onDigit: controller.tap, onBackspace: controller.backspace),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad({required this.onDigit, required this.onBackspace});

  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Column(
      children: keys
          .map(
            (row) => Row(
              children: row.map((key) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: key.isEmpty
                        ? const SizedBox(height: 64)
                        : InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () {
                              if (key == 'del') {
                                onBackspace();
                              } else {
                                onDigit(key);
                              }
                            },
                            child: SizedBox(
                              height: 64,
                              child: Center(
                                child: key == 'del'
                                    ? const Icon(
                                        Icons.backspace_outlined,
                                        color: Colors.white,
                                      )
                                    : Text(
                                        key,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                  ),
                );
              }).toList(),
            ),
          )
          .toList(),
    );
  }
}
