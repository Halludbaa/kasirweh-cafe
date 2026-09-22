import 'package:get/get.dart';
import 'package:simple_coffee_shop/data/local/db_helper.dart';
import 'package:simple_coffee_shop/data/models/category.dart';

class CategoryRepository {
  CategoryRepository({DbHelper? dbHelper})
      : _dbHelper = dbHelper ?? Get.find<DbHelper>();

  final DbHelper _dbHelper;

  Future<List<Category>> getAll() async {
    final rows = await _dbHelper.database.query(
      'categories',
      orderBy: 'sort_order ASC, id ASC',
    );
    return rows.map(Category.fromMap).toList();
  }
}
