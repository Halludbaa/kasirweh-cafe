import 'package:flutter/material.dart';
import 'package:simple_coffee_shop/core/constants/app_constants.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.path,
    this.size = 56,
  });

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = path.isEmpty ? AppConstants.defaultProductImage : path;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          AppConstants.defaultProductImage,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
