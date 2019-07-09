import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:orion/model/money_activity.dart';
import 'package:orion/view/activity_full.dart';
import 'package:orion/view/edit_activity.dart';
import 'package:orion/widgets/activityedit_widget.dart';
import 'package:provider/provider.dart';
import 'package:orion/helper/util.dart';
import 'package:orion/model/model_activitylist.dart';
import 'package:orion/model/model_money.dart';
import 'package:orion/view/home.dart';
import 'package:orion/view/initial_setup.dart';
import 'package:orion/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orion/widgets/home_activityview.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver{}
class MockMoneyModel extends Mock implements Money{}
class MockActivityListModel extends Mock implements ActivityListModel{}
class MockMoneyActivity extends Mock implements MoneyActivity{}

void main() {
  NavigatorObserver mockObserver;
  Money mockMoneyModel;
  ActivityListModel mockActivityListModel;

  Future<void> _buildMainPage(WidgetTester tester, Widget initial) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<Money>.value(value: mockMoneyModel),
          ChangeNotifierProvider<ActivityListModel>.value(value: mockActivityListModel),
        ],
        child: MaterialApp(
          home: initial,
          navigatorObservers: [mockObserver],
        ),
      )
    );
    verify(mockObserver.didPush(any, any));
  }

  setUp((){
    mockObserver = MockNavigatorObserver();
    mockMoneyModel = MockMoneyModel();
    mockActivityListModel = MockActivityListModel();
    when(mockActivityListModel.loaded).thenReturn(true);
    when(mockActivityListModel.loading).thenReturn(false);
    when(mockActivityListModel.loadingMore).thenReturn(false);
    when(mockActivityListModel.lastLoaded).thenReturn(true);
    when(mockActivityListModel.isSorting).thenReturn(false);
    when(mockActivityListModel.allActivities).thenReturn(UnmodifiableListView([]));
  });
  group('Initial Screen, read prefs', (){
    setUp((){
      mockObserver = MockNavigatorObserver();
    });
    testWidgets('first time run', (WidgetTester tester) async {
      mockPrefs(map: {
        'hasRun': false,
      });
      await _buildMainPage(tester, FirstScreenView());
      await tester.pumpAndSettle();
      verify(mockObserver.didReplace(oldRoute: anyNamed('oldRoute'), newRoute: anyNamed('newRoute')));
      expect(find.byType(InitialSetup), findsOneWidget);
      expect(find.text('Welcome!'), findsOneWidget);
    });
    testWidgets('subsequent run', (WidgetTester tester) async {
      String name = 'username';
      mockPrefs(map: {
        'hasRun': true,
        'name': name,
        'balance': 0
      });
      await _buildMainPage(tester, FirstScreenView());
      await tester.pumpAndSettle();
      verify(mockObserver.didReplace(oldRoute: anyNamed('oldRoute'), newRoute: anyNamed('newRoute')));
      expect(find.byType(Home), findsOneWidget);
      expect(find.text(name), findsOneWidget);
      expect(find.text(GlobalVars.currencyFormat.format(0)), findsOneWidget);
    });
  });
  group('Initial Setup Interactions', (){
    setUp((){
      mockPrefs();
    });
    Future<void> _fillForms(WidgetTester tester, {String name='', num bal}) async {
      await tester.enterText(find.byKey(InitialSetupState.nameInputKey), name);
      await tester.enterText(find.byKey(InitialSetupState.balanceInputKey), bal.toString());
    }
    Future<void> _finalizeSetup(WidgetTester tester) async {
      await tester.tap(find.byKey(InitialSetupState.finalizeSetupKey));
      await tester.pumpAndSettle();
    }
    testWidgets('Initial setup display', (WidgetTester tester) async {
      await _buildMainPage(tester, InitialSetup());
      expect(find.text('Welcome!'), findsOneWidget);
    });
    testWidgets('Finalize initial setups without filling anything, should not navigate', (WidgetTester tester) async {
      await _buildMainPage(tester, InitialSetup());
      await _finalizeSetup(tester);
      verifyNever(mockObserver.didReplace());
      expect(find.byType(InitialSetup), findsOneWidget);
      expect(find.text('Welcome!'), findsOneWidget);
      expect(find.byType(Home), findsNothing);
    });
    testWidgets('Finalize initial setups by only filling balance, should not navigate', (WidgetTester tester) async {
      final num bal = 10000;
      await _buildMainPage(tester, InitialSetup());
      await _fillForms(tester, bal: bal);
      expect(find.text(GlobalVars.currencyFormat.format(bal)), findsOneWidget);
      await _finalizeSetup(tester);
      verifyNever(mockObserver.didReplace());
      expect(find.byType(InitialSetup), findsOneWidget);
      expect(find.byType(Home), findsNothing);
    });
    testWidgets('Finalize initial setup by only filling name, should navigate with expected name and 0 balance', (WidgetTester tester) async {
      final String username = 'user';
      await _buildMainPage(tester, InitialSetup());
      await _fillForms(tester, name: username);
      await _finalizeSetup(tester);
      tester.binding.addTime(Duration(seconds: 1));
      verify(mockObserver.didReplace(newRoute: anyNamed('newRoute'), oldRoute: anyNamed('oldRoute')));
      expect(find.byType(Home), findsOneWidget);
      expect(find.text(username), findsOneWidget);
      expect(find.text(GlobalVars.currencyFormat.format(0)), findsOneWidget);
    });
    testWidgets('Finalize initial setup by filling name and balance, should navigate with expected name and balance', (WidgetTester tester) async {
      final String username = 'user';
      final num bal = 10000;
      await _buildMainPage(tester, InitialSetup());
      await _fillForms(tester, name: username, bal: bal);
      expect(find.text(GlobalVars.currencyFormat.format(bal)), findsOneWidget);
      await _finalizeSetup(tester);
      tester.binding.addTime(Duration(seconds: 1));
      verify(mockObserver.didReplace(oldRoute: anyNamed('oldRoute'), newRoute: anyNamed('newRoute')));
      expect(find.byType(Home), findsOneWidget);
      expect(find.text(username), findsOneWidget);
      expect(find.text(GlobalVars.currencyFormat.format(bal)), findsOneWidget);
    });
  });
  List<MoneyActivity> _generateMockActivity(int n){
    return List.generate(n, (_)=>MoneyActivity(title: '', time: DateTime(2019)));
  }
  group('home page', (){
    group('with activity data', (){
      setUp((){
        mockPrefs();
        when(mockActivityListModel.allActivities).thenReturn(UnmodifiableListView(_generateMockActivity(20)));
      });
      testWidgets('display 10 topmost activity data', (WidgetTester tester) async {
        await _buildMainPage(tester, Home(name: 'username'));
        expect(find.byType(ActivityItem), findsNWidgets(10));
      });
      testWidgets('pressing on more button redirect to fullactivityview', (WidgetTester tester) async {
        await _buildMainPage(tester, Home(name: 'username'));
        await tester.ensureVisible(find.byKey(ActivitiesState.moreButtonKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ActivitiesState.moreButtonKey));
        await tester.pumpAndSettle();
        verify(mockObserver.didPush(any, any));
        expect(find.byType(FullActivityView), findsOneWidget);
      });
    });
    testWidgets('home with no activity data', (WidgetTester tester) async {
      await _buildMainPage(tester, Home(name: 'username'));
      expect(find.byType(ActivityItem), findsNothing);
    });
  });
  group('activity manipulation', (){
    Future<void> _finalizeForm(WidgetTester tester) async {
      Finder f = find.byKey(CreateActivityState.doneKey);
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }
    group('create new activity',(){
      testWidgets('press done without filling anything, should error', (WidgetTester tester) async {
        await _buildMainPage(tester, EditActivityScreen());
        await _finalizeForm(tester);
        expect(find.text('Amount cannot be zero'), findsOneWidget);
        verifyNever(mockObserver.didPop(any, any));
      });
      testWidgets('press done after filling balance', (WidgetTester tester) async {
        await _buildMainPage(tester, EditActivityScreen());
        await tester.enterText(find.byKey(CreateActivityState.balanceKey), 10.toString());
        await tester.pumpAndSettle();
        expect(find.text(GlobalVars.currencyFormat.format(10)), findsOneWidget);
        await _finalizeForm(tester);
        expect(find.text('Amount cannot be zero'), findsNothing);
      });
      testWidgets('create income activity', (WidgetTester tester) async {
        await _buildMainPage(tester, EditActivityScreen());
        await tester.enterText(find.byKey(CreateActivityState.balanceKey), 10.toString());
        await tester.tap(find.byKey(CreateActivityState.incomeKey));
        await _finalizeForm(tester);
        verify(mockMoneyModel.addMoney(10));
      });
      testWidgets('create outcome activity', (WidgetTester tester) async {
        await _buildMainPage(tester, EditActivityScreen());
        await tester.enterText(find.byKey(CreateActivityState.balanceKey), 10.toString());
        await tester.tap(find.byKey(CreateActivityState.outcomeKey));
        await _finalizeForm(tester);
        verify(mockMoneyModel.subMoney(10));
      });
    });
    group('edit activity', (){
      MoneyActivity act;
      setUp((){
        act = MockMoneyActivity();
        when(act.amount).thenReturn(10);
        when(act.time).thenReturn(DateTime(2019));
      });
      testWidgets('edit income to outcome', (WidgetTester tester) async {
        when(act.income).thenReturn(true);
        await _buildMainPage(tester, EditActivityScreen(act: act));
        await tester.tap(find.byKey(CreateActivityState.outcomeKey));
        await _finalizeForm(tester);
        verify(mockMoneyModel.subMoney(any));
        verify(mockActivityListModel.updateActivity(act, any));
      });
      testWidgets('edit outcome to income', (WidgetTester tester) async {
        when(act.income).thenReturn(false);
        await _buildMainPage(tester, EditActivityScreen(act: act));
        await tester.tap(find.byKey(CreateActivityState.outcomeKey));
        await _finalizeForm(tester);
        verify(mockMoneyModel.subMoney(any));
        verify(mockActivityListModel.updateActivity(act, any));
      });
    });
  });
  group('activity list', (){
    setUp((){
      List<MoneyActivity> actList = _generateMockActivity(20);
      when(mockActivityListModel.allActivities).thenReturn(UnmodifiableListView(actList));
    });
    testWidgets('show top activities', (WidgetTester tester) async {
      await _buildMainPage(tester, FullActivityView());
      expect(find.byType(IndividualActivityView), findsWidgets);
    });
  });
}

Future mockPrefs({Map<String,dynamic> map}) async {
  const MethodChannel('plugins.flutter.io/shared_preferences')
    .setMockMethodCallHandler((MethodCall methodCall) async {
      if(methodCall.method == 'getAll'){
        return <String, dynamic>{};
      }
      return null;
  });
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  if(map == null) return;
  map.forEach((k,v){
    if(v is bool) prefs.setBool(k, v);
    if(v is String) prefs.setString(k, v);
    if(v is double) prefs.setDouble(k, v);
    if(v is int) prefs.setInt(k, v);
  });
}