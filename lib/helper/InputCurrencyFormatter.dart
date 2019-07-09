import 'package:flutter/services.dart';

import 'package:orion/helper/util.dart';

class InputCurrencyFormatter extends TextInputFormatter{
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final int oldEnd = oldValue.selection.end;
    final int oldLen = oldValue.text.length;
    int offset;

    String formatted;

    if(newValue.text == ''){
      formatted = GlobalVars.currencyFormat.format(0);
    }
    else if(oldValue.text == '' || GlobalVars.currencyFormat.parse(oldValue.text)  == 0){
      formatted = GlobalVars.currencyFormat.format(
        GlobalVars.currencyFormat.parse(newValue.text)
      );
      offset = GlobalVars.currencyFormat.currencySymbol.length+1;
    }
    else{
      formatted = GlobalVars.currencyFormat.format(GlobalVars.currencyFormat.parse(newValue.text));
    }
    offset ??= oldEnd + formatted.length - oldLen;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}