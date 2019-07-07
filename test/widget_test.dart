import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:orion/helper/util.dart';
import 'package:orion/model/model_activitylist.dart';
import 'package:orion/model/model_money.dart';
import 'package:orion/view/home.dart';
import 'package:orion/view/initial_setup.dart';

import 'package:orion/main.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver{}

class MockMoneyModel extends Mock implements Money{}
class MockActivityListModel extends Mock implements ActivityListModel{}

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
    when(mockActivityListModel.loading).thenReturn(false);
    when(mockActivityListModel.loaded).thenReturn(true);
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
      await _finalizeSetup(tester);
      tester.binding.addTime(Duration(seconds: 1));
      verify(mockObserver.didReplace(oldRoute: anyNamed('oldRoute'), newRoute: anyNamed('newRoute')));
      expect(find.byType(Home), findsOneWidget);
      expect(find.text(username), findsOneWidget);
      expect(find.text(GlobalVars.currencyFormat.format(bal)), findsOneWidget);
    });
  });
}

void mockPrefs({Map<String,dynamic> map}){
  //every key in SharedPreferences have to have 'flutter.' prefix
  Map<String, dynamic> newMap = map.map((k,v)=>MapEntry('flutter.'+k, v));
  const MethodChannel('plugins.flutter.io/shared_preferences')
    .setMockMethodCallHandler((MethodCall methodCall) async {
      if(methodCall.method == 'getAll'){
        return newMap;
      }
      return null;
  });
}