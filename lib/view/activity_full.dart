
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:orion/helper/database.dart';
import 'package:orion/model/model_activitylist.dart';
import 'package:orion/model/model_money.dart';
import 'package:orion/helper/money_activity.dart';
import 'package:orion/helper/util.dart';

import 'package:orion/widgets/fab_add.dart';
import 'edit_activity.dart';

class FullActivityView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => FullActivityState();
}

class FullActivityState extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity History'),
      ),
      body: Consumer<ActivityListModel>(
        builder: (context, value, child){
          if(value.loading || value.isSorting){
            return CircularProgressIndicator();
          }
          if(value.loaded){
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo){
                if(scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent+10){
                  Provider.of<ActivityListModel>(context).fetchMoreActivities();
                }
              },
              child: ListView.separated(
                itemCount: value.allActivities.length+1,
                itemBuilder: (BuildContext context, int i){
                  if(i < value.allActivities.length){
                    MoneyActivity currentItem = value.allActivities[i];
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: IndividualActivityView(currentItem, key: Key(currentItem.time.toString())),
                    );
                  }
                  else{
                    if(value.loadingMore){
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    else if(value.lastLoaded){
                      return Center(
                        child: Icon(Icons.check, color: Colors.black12),
                      );
                    }
                  }
                },
                separatorBuilder: (BuildContext context, int i) => Divider(height: 10),
              ),
            );
          }
          else return Container(
            width: double.infinity,
            child: FlatButton(
              child: Text('reload'),
              onPressed: Provider.of<ActivityListModel>(context).getActivities,
            )
          );
        },
      ),
      floatingActionButton: FloatingAdd(),
    );
  }
}

class IndividualActivityView extends StatefulWidget{
  final MoneyActivity _activity;
  IndividualActivityView(this._activity, {Key key}): super(key: key);
  @override
  State<StatefulWidget> createState() => IndividualActivityState(_activity);
}

class IndividualActivityState extends State{
  MoneyActivity _activity;
  IndividualActivityState(this._activity);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _activity.title,
                style: Theme.of(context).textTheme.title,
              ),
              Text(
                _activity.desc,
                style: Theme.of(context).textTheme.subhead,
              ),
              Text(
                GlobalVars.dateFormat.format(_activity.time),
                style: Theme.of(context).textTheme.body1
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              (_activity.income?'+':'-')+' '+
                GlobalVars.currencyFormat.format(_activity.amount),
              style: Theme.of(context).textTheme.subtitle.copyWith(
                fontWeight: FontWeight.w400,
                color: _activity.income?Colors.green:Colors.red,
              )
            ),
            Text(
              _activity.category,
              style: Theme.of(context).textTheme.body1.apply(color: Colors.grey),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: PopupMenuButton(
            child: Icon(Icons.more_vert),
            onSelected: (Choice choice){
              if(choice.val == 0){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext contetx) => EditActivityScreen(_activity)
                ));
              }
              else if(choice.val == 1){
                num amount = _activity.amount;
                bool income = _activity.income;
                DatabaseHandler.dbHandler.removeActivity(_activity).then((v){
                  if(income){
                    Provider.of<Money>(context).subMoney(amount);
                  }
                  else{
                    Provider.of<Money>(context).addMoney(amount);
                  }
                  Provider.of<ActivityListModel>(context).removeActivity(_activity);
                });
              }
            },
            itemBuilder: (BuildContext context){
              return choices.map((Choice choice){
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Row(
                    children: <Widget>[
                      Icon(choice.icon),
                      Text(choice.title),
                    ]
                  ),
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }
}

class Choice{
  const Choice({this.title, this.icon, this.val});

  final String title;
  final IconData icon;
  final int val;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Edit', icon: Icons.edit, val: 0),
  const Choice(title: 'Delete', icon: Icons.delete, val: 1),
];