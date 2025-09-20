class Product {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String categoryName;
  final double price;
  final int quantityInStock;
  final DateTime? lastRestocked;
  final String supplierName;
  final String warehouseLocation;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.quantityInStock,
    this.lastRestocked,
    required this.supplierName,
    required this.warehouseLocation,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Product',
      description: json['description']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['categories']?['name']?.toString() ?? 'Unknown',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantityInStock: json['quantity_in_stock'] as int? ?? 0,
      lastRestocked: json['last_restocked'] != null
          ? DateTime.tryParse(json['last_restocked'].toString())
          : null,
      supplierName: json['supplier_name']?.toString() ?? '',
      warehouseLocation: json['warehouse_location']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'price': price,
      'quantity_in_stock': quantityInStock,
      'last_restocked': lastRestocked?.toIso8601String(),
      'supplier_name': supplierName,
      'warehouse_location': warehouseLocation,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Category {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}