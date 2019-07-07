import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import 'package:orion/model/model_money.dart';

main(){
  group('model_money',(){
    Money money;
    SharedPreferences prefs;
    setUp(()async{
        const MethodChannel('plugins.flutter.io/shared_preferences')
          .setMockMethodCallHandler((MethodCall methodCall) async {
            if(methodCall.method == 'getAll'){
              return <String,dynamic>{
                'flutter.balance': 0,
              };
            }
            return null;
        });
        prefs = await SharedPreferences.getInstance();
        return Future.value(prefs);
    });
    group('with no initial prefs', (){
      setUp(() async{
        prefs.setDouble('balance', null);
        money = Money();
      });
      test('initial creation', (){
        expect(money.balance, 0);
      });
      test('set balance', () async {
        num balanceSet = 1;
        await money.setMoney(balanceSet);
        expect(money.balance, balanceSet);
        expect(prefs.get('balance'), balanceSet);
      });
      test('add balance', () async {
        num balanceAdd = 1;
        await money.addMoney(balanceAdd);
        expect(money.balance, balanceAdd);
        expect(prefs.get('balance'), balanceAdd);
      });
      test('subtract balance', () async {
        num balanceSub = 1;
        await money.subMoney(balanceSub);
        expect(money.balance, -balanceSub);
        expect(prefs.get('balance'), -balanceSub);
      });
    });
    group('with initial prefs', (){
      double initialBalance = 1;
      setUp(()async{
        prefs.setDouble('balance', initialBalance);
        money = Money();
      });
      test('initial creation', (){
        expect(money.balance, initialBalance);
      });
      test('set balance', () async {
        num balanceSet = 1;
        await money.setMoney(balanceSet);
        expect(money.balance, balanceSet);
        expect(prefs.get('balance'), balanceSet);
      });
      test('add balance', () async {
        num balanceAdd = 2;
        await money.addMoney(balanceAdd);
        expect(money.balance, initialBalance+balanceAdd);
        expect(prefs.get('balance'), initialBalance+balanceAdd);
      });
      test('subtract balance', () async {
        num balanceSub = 2;
        await money.subMoney(balanceSub);
        expect(money.balance, initialBalance-balanceSub);
        expect(prefs.get('balance'), initialBalance-balanceSub);
      });
    });
  });
}