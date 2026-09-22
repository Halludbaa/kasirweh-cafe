import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:simple_coffee_shop/core/constants/app_constants.dart';
import 'package:simple_coffee_shop/data/local/db_helper.dart';

class SettingsRepository {
  SettingsRepository({DbHelper? dbHelper})
      : _dbHelper = dbHelper ?? Get.find<DbHelper>();

  final DbHelper _dbHelper;

  Future<String> getShopName() async {
    final rows = await _dbHelper.database.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['shop_name'],
    );
    if (rows.isEmpty) return AppConstants.defaultShopName;
    return rows.first['value'] as String;
  }

  Future<void> setShopName(String name) async {
    await _dbHelper.database.insert(
      'settings',
      {'key': 'shop_name', 'value': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getPin() async {
    final rows = await _dbHelper.database.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['pin'],
    );
    if (rows.isEmpty) return AppConstants.defaultPin;
    return rows.first['value'] as String;
  }
}
