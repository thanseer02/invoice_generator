import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String locale = 'en_US', String symbol = '\$'}) {
    final format = NumberFormat.currency(locale: locale, symbol: symbol);
    return format.format(amount);
  }
}
