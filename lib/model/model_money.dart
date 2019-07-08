import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Money extends ChangeNotifier{
  num _balance;
  num get balance => _balance;
  Money(){
    if(_balance == null){
      SharedPreferences.getInstance().then((SharedPreferences prefs){
        _balance = prefs.get('balance')??0;
        notifyListeners();
      });
    }
  }
  Future<void> addMoney(num amount) async {
    _balance += amount;
    await _setInPrefs();
    notifyListeners();
  }
  Future<void> subMoney(num amount) async {
    _balance -= amount;
    await _setInPrefs();
    notifyListeners();
  }
  Future<void> setMoney(num balance) async {
    _balance = balance;
    await _setInPrefs();
    notifyListeners();
  }

  Future<void> _setInPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('balance', balance.toDouble());
  }
}