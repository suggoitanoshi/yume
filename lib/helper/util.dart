import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class GlobalVars{
  static const double padding = 16;
  static NumberFormat _currencyFormat = NumberFormat.simpleCurrency();
  static NumberFormat get currencyFormat => _currencyFormat;

  static DateFormat _dateFormat;
  static DateFormat get dateFormat{
    if(_dateFormat == null){
      initializeDateFormatting(Intl.defaultLocale);
      _dateFormat = DateFormat.yMMMMd();
    }
    return _dateFormat;
  } 
}