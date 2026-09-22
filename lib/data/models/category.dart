class Category {
  const Category({
    required this.id,
    required this.name,
    this.sortOrder = 0,
  });

  final int id;
  final String name;
  final int sortOrder;

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }
}
