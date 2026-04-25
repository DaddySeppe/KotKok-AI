class Ingredient {
  Ingredient({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.expirationDate,
    required this.estimatedPrice,
    required this.isOpened,
    required this.storageLocation,
    required this.createdAt,
  });

  final String id;
  final String? userId;
  final String name;
  final String category;
  final String quantity;
  final DateTime? expirationDate;
  final double estimatedPrice;
  final bool isOpened;
  final String storageLocation;
  final DateTime createdAt;

  Ingredient copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? quantity,
    DateTime? expirationDate,
    double? estimatedPrice,
    bool? isOpened,
    String? storageLocation,
    DateTime? createdAt,
  }) {
    return Ingredient(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      expirationDate: expirationDate ?? this.expirationDate,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isOpened: isOpened ?? this.isOpened,
      storageLocation: storageLocation ?? this.storageLocation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      expirationDate: json['expiration_date'] == null
          ? null
          : DateTime.parse(json['expiration_date'].toString()),
      estimatedPrice: (json['estimated_price'] as num?)?.toDouble() ?? 0,
      isOpened: json['is_opened'] == true,
      storageLocation: json['storage_location']?.toString() ?? 'fridge',
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'expiration_date': expirationDate?.toIso8601String().split('T').first,
      'estimated_price': estimatedPrice,
      'is_opened': isOpened,
      'storage_location': storageLocation,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
