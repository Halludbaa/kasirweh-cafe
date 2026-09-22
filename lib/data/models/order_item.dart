class OrderItem {
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.qty,
    required this.lineTotal,
  });

  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final int unitPrice;
  final int qty;
  final int lineTotal;

  factory OrderItem.fromMap(Map<String, Object?> map) {
    return OrderItem(
      id: map['id'] as int,
      orderId: map['order_id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      unitPrice: map['unit_price'] as int,
      qty: map['qty'] as int,
      lineTotal: map['line_total'] as int,
    );
  }
}
