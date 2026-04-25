class ShoppingItem {
  ShoppingItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.estimatedPrice,
    required this.isBought,
    required this.createdAt,
  });

  final String id;
  final String? userId;
  final String name;
  final double estimatedPrice;
  final bool isBought;
  final DateTime createdAt;

  ShoppingItem copyWith({
    String? id,
    String? userId,
    String? name,
    double? estimatedPrice,
    bool? isBought,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isBought: isBought ?? this.isBought,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      name: json['name']?.toString() ?? '',
      estimatedPrice: (json['estimated_price'] as num?)?.toDouble() ?? 0,
      isBought: json['is_bought'] == true,
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
      'estimated_price': estimatedPrice,
      'is_bought': isBought,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
