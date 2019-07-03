import 'package:flutter/services.dart';

import 'package:orion/helper/util.dart';

class InputCurrencyFormatter extends TextInputFormatter{
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    int _oldSelectionEnd = oldValue.selection.end;
    int _oldLen = oldValue.text.length;
    int _newLen;
    int _diff;
    int _offset;

    String formatted;

    if(newValue.text == ''){
      formatted = GlobalVars.currencyFormat.format(0);
    }
    else if(oldValue.text == '' || GlobalVars.currencyFormat.parse(oldValue.text)  == 0){
      formatted = GlobalVars.currencyFormat.format(
        GlobalVars.currencyFormat.parse(newValue.text)
      );
      _offset = formatted.length - (
        (GlobalVars.currencyFormat.decimalDigits == 0) ?
          0 : GlobalVars.currencyFormat.decimalDigits + 1);
    }
    else{
      formatted = GlobalVars.currencyFormat.format(GlobalVars.currencyFormat.parse(newValue.text));
    }
    if(_offset == null){
      _newLen = formatted.length;
      _diff = _newLen - _oldLen;
      _offset = _oldSelectionEnd + _diff;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: _offset),
    );
  }
}