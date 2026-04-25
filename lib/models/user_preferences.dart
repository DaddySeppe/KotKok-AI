class UserPreferences {
  UserPreferences({
    required this.id,
    required this.userId,
    required this.maxBudgetPerMeal,
    required this.dietaryPreferences,
    required this.allergies,
    required this.defaultCookingTime,
    required this.darkMode,
    required this.notificationsEnabled,
    required this.createdAt,
  });

  final String id;
  final String? userId;
  final double maxBudgetPerMeal;
  final List<String> dietaryPreferences;
  final List<String> allergies;
  final int defaultCookingTime;
  final bool darkMode;
  final bool notificationsEnabled;
  final DateTime createdAt;

  UserPreferences copyWith({
    String? id,
    String? userId,
    double? maxBudgetPerMeal,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    int? defaultCookingTime,
    bool? darkMode,
    bool? notificationsEnabled,
    DateTime? createdAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      maxBudgetPerMeal: maxBudgetPerMeal ?? this.maxBudgetPerMeal,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      allergies: allergies ?? this.allergies,
      defaultCookingTime: defaultCookingTime ?? this.defaultCookingTime,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    List<String> toList(dynamic value) =>
        (value as List<dynamic>? ?? []).map((item) => item.toString()).toList();

    return UserPreferences(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      maxBudgetPerMeal: (json['max_budget_per_meal'] as num?)?.toDouble() ?? 5,
      dietaryPreferences: toList(json['dietary_preferences']),
      allergies: toList(json['allergies']),
      defaultCookingTime: (json['default_cooking_time'] as num?)?.toInt() ?? 15,
      darkMode: json['dark_mode'] == true,
      notificationsEnabled: json['notifications_enabled'] != false,
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'max_budget_per_meal': maxBudgetPerMeal,
      'dietary_preferences': dietaryPreferences,
      'allergies': allergies,
      'default_cooking_time': defaultCookingTime,
      'dark_mode': darkMode,
      'notifications_enabled': notificationsEnabled,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
