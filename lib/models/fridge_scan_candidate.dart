class FridgeScanCandidate {
  const FridgeScanCandidate({
    required this.name,
    required this.category,
    required this.quantity,
    required this.storageLocation,
    required this.suggestedExpirationDate,
    required this.isOpened,
    required this.couldBeExpired,
    required this.confidence,
    required this.notes,
  });

  final String name;
  final String category;
  final String quantity;
  final String storageLocation;
  final DateTime? suggestedExpirationDate;
  final bool isOpened;
  final bool couldBeExpired;
  final double confidence;
  final String notes;

  factory FridgeScanCandidate.fromJson(Map<String, dynamic> json) {
    final dateText = json['suggested_expiration_date']?.toString();

    return FridgeScanCandidate(
      name: json['name']?.toString().trim() ?? '',
      category: json['category']?.toString().trim() ?? 'Overig',
      quantity: json['quantity']?.toString().trim() ?? '1 stuk',
      storageLocation: json['storage_location']?.toString().trim() ?? 'fridge',
      suggestedExpirationDate: dateText == null || dateText.isEmpty
          ? null
          : DateTime.tryParse(dateText),
      isOpened: json['is_opened'] == true,
      couldBeExpired: json['could_be_expired'] == true,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      notes: json['notes']?.toString().trim() ?? '',
    );
  }

  static List<FridgeScanCandidate> listFromJson(Object? value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) =>
            FridgeScanCandidate.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.name.isNotEmpty)
        .toList();
  }
}
