import 'package:test/test.dart';

import 'package:orion/model/money_activity.dart';

main(){
  group('money_activity', (){
    test('create money_activity instance', (){
      MoneyActivity act = MoneyActivity(
        amount: 0,
        title: 'title',
        desc: 'desc',
        category: 'category',
        time: DateTime(2019, 1, 1),
        income: false
      );
      expect(act.id, null);
      expect(act.title, 'title');
      expect(act.desc, 'desc');
      expect(act.category, 'category');
      expect(act.time, DateTime(2019, 1, 1));
      expect(act.amount, 0);
      expect(act.income, false);
    });
    test('create instance from map', (){
      MoneyActivity act = MoneyActivity.fromMap(<String, dynamic>{
        'id': 0,
        'title': 'title',
        'desc': 'desc',
        'category': 'category',
        'time': DateTime(2019, 1, 1).toIso8601String(),
        'amount': 0,
        'isIncome': false
      });
      expect(act.id, 0);
      expect('title', 'title');
      expect(act.desc, 'desc');
      expect(act.category, 'category');
      expect(act.time, DateTime(2019, 1, 1));
      expect(act.amount, 0);
      expect(act.income, false);
    });
    test('transform an instance to map', (){
      MoneyActivity act = MoneyActivity(
        amount: 0,
        title: 'title',
        desc: 'desc',
        category: 'category',
        time:  DateTime(2019, 1, 1),
        income: false,
      );
      Map<String, dynamic> actMap = act.toMap();
      expect(actMap, {
        'title': 'title',
        'desc': 'desc',
        'category': 'category',
        'time': DateTime(2019, 1, 1).toIso8601String(),
        'amount': 0,
        'isIncome': false,
      });
    });
  });
  group('money_activity_list', (){
    MoneyActivity act;
    setUp((){
      act = MoneyActivity(
        amount: 0,
        title: 'title',
        desc: 'desc',
        category: 'category',
        time: DateTime(2019, 1, 1),
        income: false,
      );
    });
  });
}