import 'package:simple_coffee_shop/data/models/product.dart';

class CartItem {
  CartItem({
    required this.product,
    this.qty = 1,
  });

  final Product product;
  int qty;

  int get lineTotal => product.price * qty;
}
