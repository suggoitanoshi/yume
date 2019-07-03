import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Money extends ChangeNotifier{
  num _balance;
  num get balance => _balance;
  Money(){
    if(_balance == null){
      SharedPreferences.getInstance().then((SharedPreferences prefs){
        _balance = prefs.get('balance');
        notifyListeners();
      });
    }
  }
  void addMoney(num amount){
    _balance += amount;
    _setInPrefs();
    notifyListeners();
  }
  void subMoney(num amount){
    _balance -= amount;
    _setInPrefs();
    notifyListeners();
  }
  void setMoney(num balance){
    _balance = balance;
    _setInPrefs();
  }

  void _setInPrefs(){
    SharedPreferences.getInstance().then((SharedPreferences prefs){
      prefs.setDouble('balance', balance);
    });
  }
}