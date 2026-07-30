class Product {
  final String id;
  final String? companyId;
  final String name;
  final String? description;
  final double price;
  final double taxRate;
  final String? sku;
  final String? barcode;
  final double discount;
  final String? unit;
  final String? imagePath;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    this.companyId,
    required this.name,
    this.description,
    required this.price,
    this.taxRate = 0.0,
    this.sku,
    this.barcode,
    this.discount = 0.0,
    this.unit,
    this.imagePath,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      companyId: json['companyId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String?,
      imagePath: json['imagePath'] as String?,
      category: json['category'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'name': name,
      'description': description,
      'price': price,
      'taxRate': taxRate,
      'sku': sku,
      'barcode': barcode,
      'discount': discount,
      'unit': unit,
      'imagePath': imagePath,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? companyId,
    String? name,
    String? description,
    double? price,
    double? taxRate,
    String? sku,
    String? barcode,
    double? discount,
    String? unit,
    String? imagePath,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      taxRate: taxRate ?? this.taxRate,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      discount: discount ?? this.discount,
      unit: unit ?? this.unit,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
