import 'package:mockito/mockito.dart';
import 'package:orion/model/money_activity.dart';
import 'package:test/test.dart';

import 'package:orion/helper/database.dart';

import 'package:orion/model/model_activitylist.dart';

import 'package:orion/helper/service_locator.dart';

class MockDatabaseHandler extends Mock implements DatabaseHandler{}
class MockMoneyActivity extends Mock implements MoneyActivity{}

void main(){
  group('model_activitylist', (){
    ActivityListModel model;
    MockDatabaseHandler handler;
    setUp((){
      handler = MockDatabaseHandler();
      locator.reset();
      locator.registerLazySingleton<DatabaseHandler>(()=>handler);
      when(handler.getNActivityWithSkip(any, any)).thenAnswer((_) => Future.value(
        List.generate(_.positionalArguments[0], (_)=>MockMoneyActivity())
      ));
    });
    group('no initial values', (){
      setUp((){
        when(handler.getLatestNActivity(any)).thenAnswer((_) => Future.value(<MoneyActivity>[]));
        model = ActivityListModel();
        verify(handler.getLatestNActivity(10));
      });
      test('add activity',() async {
        MoneyActivity act = MockMoneyActivity();
        await model.addActivity(act);
        verify(handler.addActivity(act));
        expect(model.allActivities.length, 1);
        expect(model.allActivities[0], act);
      });
      test('remove activity',(){
        MoneyActivity act = MockMoneyActivity();
        model.removeActivity(act);
        verify(handler.removeActivity(act));
        expect(model.allActivities.length, 0);
      });
      test('fetch more activity', ()async{
        await model.fetchMoreActivities();
        verify(handler.getNActivityWithSkip(20, any));
        expect(model.allActivities.length, 20);
      });
    });
    group('with initial values', (){
      setUp((){
        when(handler.getLatestNActivity(any)).thenAnswer((_)=>Future.value(
          List.generate(_.positionalArguments[0], (_) => MockMoneyActivity())
        ));
        model = ActivityListModel();
      });
      test('fetch more activity', ()async{
        await model.fetchMoreActivities();
        verify(handler.getNActivityWithSkip(20, 10));
        expect(model.allActivities.length, 30);
      });
    });
  });
}