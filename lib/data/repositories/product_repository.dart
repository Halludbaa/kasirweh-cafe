import 'package:get/get.dart';
import 'package:simple_coffee_shop/data/local/db_helper.dart';
import 'package:simple_coffee_shop/data/models/product.dart';

class ProductRepository {
  ProductRepository({DbHelper? dbHelper})
      : _dbHelper = dbHelper ?? Get.find<DbHelper>();

  final DbHelper _dbHelper;

  Future<List<Product>> getAll({bool activeOnly = false}) async {
    final rows = await _dbHelper.database.query(
      'products',
      where: activeOnly ? 'is_active = 1' : null,
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> getById(int id) async {
    final rows = await _dbHelper.database.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<int> insert(Product product) async {
    final now = DateTime.now().toIso8601String();
    return _dbHelper.database.insert('products', {
      ...product.toMap(),
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> update(Product product) async {
    await _dbHelper.database.update(
      'products',
      {
        ...product.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> setActive(int id, bool isActive) async {
    await _dbHelper.database.update(
      'products',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    await _dbHelper.database.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
