import 'package:intl/intl.dart';

class MoneyUtils {
  static final _moneyFormat = NumberFormat.currency(locale: 'nl_BE', symbol: '€');

  static String format(double value) => _moneyFormat.format(value);
}
