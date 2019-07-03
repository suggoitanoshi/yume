// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

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

class MockNavigatorObserver extends Mock implements NavigatorObserver{}

class MockMoneyModel extends Mock implements Money{}
class MockActivityListModel extends Mock implements ActivityListModel{}

void main() {
  group('Initial Setup Interactions', (){
    NavigatorObserver mockObserver;
    Money mockMoneyModel;
    ActivityListModel mockActivityListModel;
    setUp((){
      mockObserver = MockNavigatorObserver();
      mockMoneyModel = MockMoneyModel();
      mockActivityListModel = MockActivityListModel();
      when(mockActivityListModel.loading).thenReturn(false);
      when(mockActivityListModel.isSorting).thenReturn(false);
      when(mockActivityListModel.loaded).thenReturn(true);
      when(mockActivityListModel.allActivities).thenReturn(UnmodifiableListView([]));
    });

    Future<void> _buildMainPage(WidgetTester tester) async {
      const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler((MethodCall methodCall) async {
          if(methodCall.method == 'getAll'){
            return <String, dynamic>{};
          }
          return null;
      });
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<Money>.value(value: mockMoneyModel),
            ChangeNotifierProvider<ActivityListModel>.value(value: mockActivityListModel),
          ],
          child: MaterialApp(
            home: InitialSetup(),
            navigatorObservers: [mockObserver],
          ),
        )
      );
      verify(mockObserver.didPush(any, any));
    }
    Future<void> _fillForms(WidgetTester tester, {String name='', num bal}) async {
      await tester.enterText(find.byKey(InitialSetupState.nameInputKey), name);
      await tester.enterText(find.byKey(InitialSetupState.balanceInputKey), bal.toString());
    }
    Future<void> _finalizeSetup(WidgetTester tester) async {
      await tester.tap(find.byKey(InitialSetupState.finalizeSetupKey));
      await tester.pumpAndSettle();
    }
    testWidgets('Initial setup display', (WidgetTester tester) async {
      await _buildMainPage(tester);
      expect(find.text('Welcome!'), findsOneWidget);
    });
    testWidgets('Finalize initial setups without filling anything', (WidgetTester tester) async {
      await _buildMainPage(tester);
      await _finalizeSetup(tester);
      verifyNever(mockObserver.didReplace());
      expect(find.byType(InitialSetup), findsOneWidget);
      expect(find.text('Welcome!'), findsOneWidget);
      expect(find.byType(Home), findsNothing);
    });
    testWidgets('Finalize initial setups by only filling balance', (WidgetTester tester) async {
      final num bal = 10000;
      await _buildMainPage(tester);
      await _fillForms(tester, bal: bal);
      await _finalizeSetup(tester);
      verifyNever(mockObserver.didReplace());
      expect(find.byType(InitialSetup), findsOneWidget);
      expect(find.byType(Home), findsNothing);
    });
    testWidgets('Finalize initial setup by only filling name', (WidgetTester tester) async {
      final String username = 'user';
      await _buildMainPage(tester);
      await _fillForms(tester, name: username);
      await _finalizeSetup(tester);
      tester.binding.addTime(Duration(seconds: 1));
      verify(mockObserver.didReplace(newRoute: anyNamed('newRoute'), oldRoute: anyNamed('oldRoute')));
      expect(find.byType(Home), findsOneWidget);
      expect(find.text(username), findsOneWidget);
      expect(find.text(GlobalVars.currencyFormat.format(0)), findsOneWidget);
    });
    testWidgets('Finalize initial setup by filling name and balance', (WidgetTester tester) async {
      final String username = 'user';
      final num bal = 10000;
      await _buildMainPage(tester);
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
