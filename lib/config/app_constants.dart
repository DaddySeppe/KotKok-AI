import 'package:flutter/material.dart';

class AppConstants {
  static const appName = 'KotKok AI';
  static const slogan = 'Kook slim. Verspil minder. Bespaar geld.';

  static const storageLocations = ['fridge', 'freezer', 'pantry'];
  static const categories = [
    'Groenten',
    'Fruit',
    'Zuivel',
    'Vlees',
    'Vis',
    'Brood',
    'Granen',
    'Snacks',
    'Saus',
    'Overig',
  ];

  static const dietaryPreferences = [
    'none',
    'vegetarian',
    'vegan',
    'halal',
    'gluten free',
    'lactose free',
  ];

  static const allergies = [
    'nuts',
    'peanuts',
    'milk',
    'eggs',
    'gluten',
    'fish',
    'shellfish',
    'soy',
  ];

  static const moods = [
    'Ik heb honger',
    'Ik wil gezond',
    'Ik wil comfort food',
    'Ik heb geen energie',
    'Ik wil goedkoop',
  ];

  static const effortLevels = ['bijna niks', 'oké vooruit', 'ik kan koken'];
  static const dishLevels = ['geen afwas', 'één pan', 'maakt niet uit'];
  static const budgetLabels = ['€0 extra', 'onder €3', 'maakt niet uit'];
  static const timeOptions = [5, 10, 15, 20, 30];

  static const statusExpired = 'Vervallen';
  static const statusToday = 'Vandaag gebruiken';
  static const statusSoon = 'Bijna vervallen';
  static const statusOkay = 'Nog oké';
  static const statusLong = 'Lang houdbaar';

  static const quickActions = [
    'Gebruik wat vandaag vervalt',
    'Geen zin om te koken',
    'AI recept maken',
    'Boodschappenlijst',
  ];

  static const dangerColor = Color(0xFFE76F51);
  static const successColor = Color(0xFF2A9D8F);
  static const warningColor = Color(0xFFF4A261);
  static const creamColor = Color(0xFFFFF8EF);
  static const warmGreenColor = Color(0xFF5B8E7D);
  static const warmOrangeColor = Color(0xFFF4A261);
}
