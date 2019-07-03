import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MoneyActivity{
  int _id;
  num _amount;
  DateTime _time;
  String _title;
  String _desc;
  String _category;
  bool _income;

  Key _key = UniqueKey();

  int get id => _id;
  num get amount => _amount;
  DateTime get time => _time;
  String get title => _title;
  String get desc => _desc;

  Key get key => _key;

  set title(String newTitle){
    this._title = newTitle;
  }
  set desc(String newDesc){
    this._desc = newDesc;
  }
  bool get income => _income;
  String get category => _category;

  set id(int newid){
    this._id = newid;
  }

  MoneyActivity(this._amount, this._title, this._desc, this._category, this._time, this._income);
  MoneyActivity.fromMap(Map<String, dynamic> map){
    this._id = map['id'];
    this._time = DateTime.parse(map['time']);
    this._income = (map['isIncome'] == 1);
    this._category = map['category'].toString();
    this._title = map['title'].toString();
    this._desc = map['desc'].toString();
    this._amount = map['amount'];
  }

  void update(MoneyActivity newAct){
    this._id = newAct.id??_id;
    this._title = newAct.title??_title;
    this._income = newAct.income??_income;
    this._category = newAct.category??_category;
    this._desc = newAct.desc??_desc;
    this._amount = newAct.amount??_amount;
    this._time = newAct.time??_time;
  }

  Map<String, dynamic> toMap(){
    return {
      if(id != null)
        'id': id,
      'amount': amount,
      'time': time.toIso8601String(),
      'title': title,
      'desc': desc,
      'isIncome': income,
      'category': category,
    };
  }
}