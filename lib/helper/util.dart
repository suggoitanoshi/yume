import 'package:flutter/material.dart';
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

class TextWithIcon extends StatelessWidget{
  final String _text;
  final IconData _icon;
  final double size;

  TextWithIcon(this._icon, this._text, {this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(
            _icon,
            size: size??Theme.of(context).textTheme.title.fontSize,
            color: Theme.of(context).accentColor,
          ),
        ),
        Text(
          _text,
          style: Theme.of(context).textTheme.title.copyWith(fontSize: size),
        ),
      ],
    );
  }
}