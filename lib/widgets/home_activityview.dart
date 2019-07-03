import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:orion/view/activity_full.dart';
import 'package:orion/model/model_activitylist.dart';
import 'package:orion/helper/util.dart';

class ActivitiesWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => ActivitiesState();
}

class ActivitiesState extends State{
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityListModel>(
      builder: (context, value, child){
        if(value.loading) return CircularProgressIndicator();
        if(!value.loaded) return FlatButton(
          child: Text('reload'),
          onPressed: (){ Provider.of<ActivityListModel>(context).getActivities();},
        );
        if(value.allActivities.length == 0) return Padding(
          padding: EdgeInsets.only(bottom: GlobalVars.padding),
          child: Text('You have no activity yet!'),
        );
        List<Widget> actList = [];
        value.allActivities.take(10).forEach((act){
          actList.add(Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        act.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        textScaleFactor: 1.2,
                      ),
                      Text(GlobalVars.dateFormat.format(act.time)),
                    ],
                  )
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (act.income?'+':'-')+' '+
                      GlobalVars.currencyFormat.format(act.amount),
                      style: TextStyle(
                        color: act.income?Colors.green:Colors.red
                      ),
                    ),
                    Text(
                      act.category,
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ));
        });
        actList.add(
          SizedBox(
            width: double.infinity,
            child: FlatButton(
              child: Text('More'),
              onPressed: (){
                Provider.of<ActivityListModel>(context).fetchMoreActivities();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => FullActivityView()
                ));
              },
            ),
          )
        );
        return Column(
          children: actList,
        );
      },
    );
  }
}

class ActivityCard extends StatelessWidget{
  final double padding = GlobalVars.padding;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: padding, top: padding, right: padding),
            child: TextWithIcon(Icons.assessment, 'Recent Activity')
          ),
          Divider(height: padding*2),
          Padding(
            child: ActivitiesWidget(),
            padding: EdgeInsets.only(left: padding, right: padding),
          )
        ],
      ),
    );
  }
}