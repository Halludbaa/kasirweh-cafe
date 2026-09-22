import 'package:simple_coffee_shop/data/models/order_item.dart';

class Order {
  const Order({
    required this.id,
    required this.invoiceNo,
    required this.total,
    required this.paid,
    required this.changeAmount,
    required this.paymentMethod,
    required this.createdAt,
    this.items = const [],
  });

  final int id;
  final String invoiceNo;
  final int total;
  final int paid;
  final int changeAmount;
  final String paymentMethod;
  final DateTime createdAt;
  final List<OrderItem> items;

  bool get isCash => paymentMethod == 'cash';

  String get paymentLabel => isCash ? 'Tunai' : 'QRIS';

  factory Order.fromMap(Map<String, Object?> map, {List<OrderItem> items = const []}) {
    return Order(
      id: map['id'] as int,
      invoiceNo: map['invoice_no'] as String,
      total: map['total'] as int,
      paid: map['paid'] as int,
      changeAmount: map['change_amount'] as int,
      paymentMethod: map['payment_method'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      items: items,
    );
  }
}
