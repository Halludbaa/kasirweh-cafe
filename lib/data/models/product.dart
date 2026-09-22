class Product {
  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.isActive,
  });

  final int id;
  final int categoryId;
  final String name;
  final int price;
  final String imagePath;
  final bool isActive;

  Product copyWith({
    int? categoryId,
    String? name,
    int? price,
    String? imagePath,
    bool? isActive,
  }) {
    return Product(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      price: map['price'] as int,
      imagePath: map['image_path'] as String? ?? '',
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'category_id': categoryId,
      'name': name,
      'price': price,
      'image_path': imagePath,
      'is_active': isActive ? 1 : 0,
    };
  }
}
