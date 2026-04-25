import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_constants.dart';
import '../models/ingredient.dart';

class DateUtils {
  static final _dateFormat = DateFormat('d MMM');
  static final _moneyFormat = NumberFormat.currency(locale: 'nl_BE', symbol: '€');

  static DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  static String formatDate(DateTime? value) {
    if (value == null) return '-';
    return _dateFormat.format(value);
  }

  static String formatMoney(num value) => _moneyFormat.format(value);

  static int daysUntil(DateTime? value) {
    if (value == null) return 9999;
    return dateOnly(value).difference(dateOnly(DateTime.now())).inDays;
  }

  static bool isExpired(Ingredient ingredient) => daysUntil(ingredient.expirationDate) < 0;
  static bool isToday(Ingredient ingredient) => daysUntil(ingredient.expirationDate) == 0;
  static bool isSoon(Ingredient ingredient) {
    final days = daysUntil(ingredient.expirationDate);
    return days > 0 && days <= 3;
  }

  static bool isLongShelfLife(Ingredient ingredient) {
    final days = daysUntil(ingredient.expirationDate);
    return ingredient.storageLocation == 'pantry' && days >= 30;
  }

  static String ingredientStatusLabel(Ingredient ingredient) {
    if (isExpired(ingredient)) return AppConstants.statusExpired;
    if (isToday(ingredient)) return AppConstants.statusToday;
    if (isSoon(ingredient)) return AppConstants.statusSoon;
    if (isLongShelfLife(ingredient)) return AppConstants.statusLong;
    return AppConstants.statusOkay;
  }

  static Color ingredientStatusColor(Ingredient ingredient) {
    if (isExpired(ingredient) || isToday(ingredient)) return AppConstants.dangerColor;
    if (isSoon(ingredient)) return AppConstants.warningColor;
    if (isLongShelfLife(ingredient)) return Colors.blueGrey;
    return AppConstants.successColor;
  }
}
