import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MoneyActivity{
  int id;
  num amount;
  DateTime time;
  String title;
  String desc;
  String category;
  bool income;

  Key key = UniqueKey();

  MoneyActivity({this.amount, this.title, this.desc, this.category, this.time, this.income});
  MoneyActivity.fromMap(Map<String, dynamic> map){
    this.id = map['id'];
    this.time = DateTime.parse(map['time']);
    this.income = (map['isIncome'] == 1);
    this.category = map['category'].toString();
    this.title = map['title'].toString();
    this.desc = map['desc'].toString();
    this.amount = map['amount'];
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