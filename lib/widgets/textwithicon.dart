import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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