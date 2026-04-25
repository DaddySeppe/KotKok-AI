import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_constants.dart';
import '../config/supabase_config.dart';
import '../models/user_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  UserPreferences _preferences = UserPreferences(
    id: const Uuid().v4(),
    userId: null,
    maxBudgetPerMeal: 4.50,
    dietaryPreferences: const ['none'],
    allergies: const [],
    defaultCookingTime: 15,
    darkMode: false,
    notificationsEnabled: true,
    createdAt: DateTime.now(),
  );

  UserPreferences get preferences => _preferences;

  Future<void> bootstrap() async {
    if (SupabaseConfig.isConfigured) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          final rows = await Supabase.instance.client.from('user_preferences').select().eq('user_id', user.id).limit(1);
          if (rows.isNotEmpty) {
            _preferences = UserPreferences.fromJson(Map<String, dynamic>.from(rows.first));
          }
        } catch (_) {
          // Keep local defaults.
        }
      }
    }
    notifyListeners();
  }

  void updatePreferences(UserPreferences value) {
    _preferences = value;
    unawaited(_persistPreferences());
    notifyListeners();
  }

  void setBudget(double value) {
    _preferences = _preferences.copyWith(maxBudgetPerMeal: value);
    unawaited(_persistPreferences());
    notifyListeners();
  }

  void setDietaryPreferences(List<String> values) {
    _preferences = _preferences.copyWith(dietaryPreferences: values.isEmpty ? const ['none'] : values);
    unawaited(_persistPreferences());
    notifyListeners();
  }

  void setAllergies(List<String> values) {
    _preferences = _preferences.copyWith(allergies: values);
    unawaited(_persistPreferences());
    notifyListeners();
  }

  void setCookingTime(int value) {
    _preferences = _preferences.copyWith(defaultCookingTime: value);
    unawaited(_persistPreferences());
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _preferences = _preferences.copyWith(darkMode: value);
    unawaited(_persistPreferences());
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _preferences = _preferences.copyWith(notificationsEnabled: value);
    unawaited(_persistPreferences());
    notifyListeners();
  }

  List<String> get dietaryOptions => AppConstants.dietaryPreferences;
  List<String> get allergyOptions => AppConstants.allergies;

  Future<void> _persistPreferences() async {
    if (!SupabaseConfig.isConfigured) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('user_preferences').upsert({
        ..._preferences.toJson(),
        'user_id': user.id,
      });
    } catch (_) {
      // Local state already reflects the change.
    }
  }
}
