import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:simple_coffee_shop/data/local/db_helper.dart';
import 'package:simple_coffee_shop/data/models/cart_item.dart';
import 'package:simple_coffee_shop/data/models/order.dart';
import 'package:simple_coffee_shop/data/models/order_item.dart';

class CreateOrderInput {
  const CreateOrderInput({
    required this.items,
    required this.paymentMethod,
    required this.paid,
    required this.changeAmount,
    required this.total,
  });

  final List<CartItem> items;
  final String paymentMethod;
  final int paid;
  final int changeAmount;
  final int total;
}

class DailyIncome {
  const DailyIncome({required this.day, required this.total});

  final DateTime day;
  final int total;
}

class OrderRepository {
  OrderRepository({DbHelper? dbHelper})
      : _dbHelper = dbHelper ?? Get.find<DbHelper>();

  final DbHelper _dbHelper;

  Future<Order> create(CreateOrderInput input) async {
    final db = _dbHelper.database;
    final createdAt = DateTime.now();
    late Order order;

    await db.transaction((txn) async {
      final invoiceNo = await _nextInvoiceNo(txn, createdAt);
      final orderId = await txn.insert('orders', {
        'invoice_no': invoiceNo,
        'total': input.total,
        'paid': input.paid,
        'change_amount': input.changeAmount,
        'payment_method': input.paymentMethod,
        'created_at': createdAt.toIso8601String(),
      });

      final items = <OrderItem>[];
      for (final item in input.items) {
        final id = await txn.insert('order_items', {
          'order_id': orderId,
          'product_id': item.product.id,
          'product_name': item.product.name,
          'unit_price': item.product.price,
          'qty': item.qty,
          'line_total': item.lineTotal,
        });
        items.add(
          OrderItem(
            id: id,
            orderId: orderId,
            productId: item.product.id,
            productName: item.product.name,
            unitPrice: item.product.price,
            qty: item.qty,
            lineTotal: item.lineTotal,
          ),
        );
      }

      order = Order(
        id: orderId,
        invoiceNo: invoiceNo,
        total: input.total,
        paid: input.paid,
        changeAmount: input.changeAmount,
        paymentMethod: input.paymentMethod,
        createdAt: createdAt,
        items: items,
      );
    });

    return order;
  }

  Future<String> _nextInvoiceNo(Transaction txn, DateTime createdAt) async {
    final prefix = DateFormat('yyyyMMdd').format(createdAt);
    final rows = await txn.rawQuery(
      "SELECT COUNT(*) AS c FROM orders WHERE invoice_no LIKE ?",
      ['INV-$prefix-%'],
    );
    final count = (rows.first['c'] as num?)?.toInt() ?? 0;
    return 'INV-$prefix-${(count + 1).toString().padLeft(4, '0')}';
  }

  Future<List<Order>> getAll() async {
    final rows = await _dbHelper.database.query(
      'orders',
      orderBy: 'created_at DESC',
    );
    return rows.map((row) => Order.fromMap(row)).toList();
  }

  Future<Order?> getById(int id) async {
    final rows = await _dbHelper.database.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    final items = await _dbHelper.database.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [id],
    );
    return Order.fromMap(
      rows.first,
      items: items.map(OrderItem.fromMap).toList(),
    );
  }

  Future<List<DailyIncome>> lastSevenDaysIncome() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final rows = await _dbHelper.database.query('orders');
    final totals = <String, int>{};
    for (final row in rows) {
      final created = DateTime.parse(row['created_at'] as String);
      final day = DateTime(created.year, created.month, created.day);
      if (day.isBefore(start)) continue;
      final key = day.toIso8601String();
      totals[key] = (totals[key] ?? 0) + (row['total'] as int);
    }

    return List.generate(7, (index) {
      final day = start.add(Duration(days: index));
      final key = DateTime(day.year, day.month, day.day).toIso8601String();
      return DailyIncome(day: day, total: totals[key] ?? 0);
    });
  }
}
