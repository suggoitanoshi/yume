import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'package:orion/helper/database.dart';
import 'package:orion/helper/money_activity.dart';

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

  ActivityListModel(){
    getActivities();
  }

  void getActivities() async {
    if(_loaded) return;
    _loading = true;
    DatabaseHandler.dbHandler.getLatestNActivity(10).then((act){
      _loaded = true;
      _activity = act;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> fetchMoreActivities() async {
    _loadingMore = true;
    DatabaseHandler.dbHandler.getNActivityWithSkip(20, allActivities.length).then((List<MoneyActivity> fetched){
      _loadingMore = false;
      if(fetched.length<20){
        _lastLoaded = true;
      }
      _activity.addAll(fetched);
      notifyListeners();
    });
  }

  void addActivity(MoneyActivity act){
    _activity.add(act);
    _sortActivities();
  }
  void updateActivity(MoneyActivity oldAct, MoneyActivity newAct){
    int index = _activity.indexOf(oldAct);
    _activity[index].update(newAct);
    _sortActivities();
  }
  void removeActivity(MoneyActivity act){
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