import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:simple_coffee_shop/core/constants/app_constants.dart';

class DbHelper {
  Database? _db;

  Database get database {
    final db = _db;
    if (db == null) {
      throw StateError('Database belum diinisialisasi');
    }
    return db;
  }

  Future<DbHelper> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'kasir_kafe.db'),
      version: 1,
      onCreate: _onCreate,
    );
    return this;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        image_path TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_no TEXT UNIQUE NOT NULL,
        total INTEGER NOT NULL,
        paid INTEGER NOT NULL,
        change_amount INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        unit_price INTEGER NOT NULL,
        qty INTEGER NOT NULL,
        line_total INTEGER NOT NULL
      )
    ''');

    final now = DateTime.now().toIso8601String();
    await db.insert('settings', {
      'key': 'shop_name',
      'value': AppConstants.defaultShopName,
    });
    await db.insert('settings', {
      'key': 'pin',
      'value': AppConstants.defaultPin,
    });

    await db.insert('categories', {
      'name': 'Kopi',
      'sort_order': 1,
      'created_at': now,
    });
    await db.insert('categories', {
      'name': 'Non-Kopi',
      'sort_order': 2,
      'created_at': now,
    });
    await db.insert('categories', {
      'name': 'Makanan',
      'sort_order': 3,
      'created_at': now,
    });

    Future<void> product({
      required int categoryId,
      required String name,
      required int price,
      required String image,
    }) {
      return db.insert('products', {
        'category_id': categoryId,
        'name': name,
        'price': price,
        'image_path': image,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });
    }

    await product(
      categoryId: 1,
      name: 'Espresso',
      price: 18000,
      image: 'assets/images/products/espresso.png',
    );
    await product(
      categoryId: 1,
      name: 'Americano',
      price: 20000,
      image: 'assets/images/products/americano.png',
    );
    await product(
      categoryId: 1,
      name: 'Cafe Latte',
      price: 25000,
      image: 'assets/images/products/latte.png',
    );
    await product(
      categoryId: 1,
      name: 'Cappuccino',
      price: 25000,
      image: 'assets/images/products/cappuccino.png',
    );
    await product(
      categoryId: 2,
      name: 'Matcha Latte',
      price: 28000,
      image: 'assets/images/products/matcha.png',
    );
    await product(
      categoryId: 3,
      name: 'Croissant',
      price: 18000,
      image: 'assets/images/products/croissant.png',
    );
    await product(
      categoryId: 3,
      name: 'Chicken Sandwich',
      price: 22000,
      image: 'assets/images/products/sandwich.png',
    );
  }
}
