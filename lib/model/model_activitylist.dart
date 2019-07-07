import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'package:orion/helper/database.dart';
import 'package:orion/model/money_activity.dart';

import 'package:orion/helper/service_locator.dart';

class ActivityListModel extends ChangeNotifier{
  bool _loaded = false;
  bool _loading = false;
  bool _loadingMore = false;
  bool _lastLoaded = false;
  bool _isSorting = false;
  bool get isSorting => _isSorting;
  bool get lastLoaded => _lastLoaded;
  bool get loadingMore => _loadingMore;
  bool get loading => _loading;
  bool get loaded => _loaded;
  List<MoneyActivity> _activity = [];
  UnmodifiableListView<MoneyActivity> get allActivities => UnmodifiableListView(_activity);
  DatabaseHandler dbHandler;

  ActivityListModel(){
    dbHandler = locator<DatabaseHandler>();
    getActivities();
  }

  Future<void> getActivities() async {
    if(_loaded) return;
    _loading = true;
    dbHandler.getLatestNActivity(10).then((act){
      _loaded = true;
      _activity = act;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> fetchMoreActivities() async {
    _loadingMore = true;
    dbHandler.getNActivityWithSkip(20, allActivities.length).then((List<MoneyActivity> fetched){
      _loadingMore = false;
      if(fetched.length<20){
        _lastLoaded = true;
      }
      _activity.addAll(fetched);
      notifyListeners();
    });
  }

  Future<void> addActivity(MoneyActivity act) async {
    DatabaseHandler db = locator.get<DatabaseHandler>();
    await db.addCategory(act.category);
    int id = await db.addActivity(act);
    act.id = id;
    _activity.add(act);
    _sortActivities();
  }
  Future<void> updateActivity(MoneyActivity oldAct, MoneyActivity newAct) async {
    DatabaseHandler db = locator.get<DatabaseHandler>();
    await db.updateActivity(oldAct, newAct);
    int index = _activity.indexOf(oldAct);
    newAct.key = oldAct.key;
    _activity[index] = newAct;
    _sortActivities();
  }
  Future<void> removeActivity(MoneyActivity act) async {
    DatabaseHandler db = locator.get<DatabaseHandler>();
    await db.removeActivity(act);
    _activity.remove(act);
    notifyListeners();
  }

  void _sortActivities() async {
    this._isSorting = true;
    _activity.sort((a,b)=>b.time.compareTo(a.time));
    this._isSorting = false;
    notifyListeners();
  }
}