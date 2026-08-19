import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static NumberFormat currency({String symbol = '\$'}) =>
      NumberFormat.currency(symbol: symbol, decimalDigits: 2);

  static String money(num value, {String symbol = '\$'}) =>
      currency(symbol: symbol).format(value);

  static final DateFormat dayMonth = DateFormat('d MMM');
  static final DateFormat dayMonthYear = DateFormat('d MMM yyyy');
  static final DateFormat monthYear = DateFormat('MMMM yyyy');
}
