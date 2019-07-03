import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orion/view/home.dart';
import 'package:orion/view/initial_setup.dart';
import 'package:orion/model/model_money.dart';
import 'package:orion/model/model_activitylist.dart';

void main(){
  Intl.defaultLocale = 'id_ID';
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Money()),
        ChangeNotifierProvider.value(value: ActivityListModel()),
      ],
      child: MaterialApp(
        title: 'MoneyManager',
        theme: ThemeData(
          textTheme: TextTheme(
            headline: TextStyle(fontSize: 72.0),
            title: TextStyle(fontSize: 24.0),
            subtitle: TextStyle(fontSize: 20.0),
            body1: TextStyle(fontSize: 16.0),
          )
        ),
        home: FirstScreenView(),
      ),
    );
  }
}

class FirstScreenView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => FirstScreenState();
}

class FirstScreenState extends State<FirstScreenView>{
  Future checkFirstSeen() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = prefs.getBool('hasRun')??false;
    _seen = false;
    if(_seen){
      String name = prefs.getString('name');
      Provider.of<ActivityListModel>(context).getActivities();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home(name: name)));
    }
    else{
      prefs.setBool('hasRun', true);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Theme(
            data: Theme.of(context).copyWith(
              backgroundColor: Colors.blue[400],
              scaffoldBackgroundColor: Colors.blue[400],
              primaryColor: Colors.white70,
              accentColor: Colors.white70,
              textSelectionColor: Colors.white54,
              textSelectionHandleColor: Colors.white70,
              highlightColor: Colors.blueAccent[600],
              splashColor: Colors.blueAccent[600],
              cursorColor: Colors.white70,
              hintColor: Colors.white54,
              indicatorColor: Colors.blue[900],
              toggleableActiveColor: Colors.white30,
              textTheme: TextTheme(
                title: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
                body1: Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
              ),
              iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.blue[800]),
            ),
            child: InitialSetup(),
          ),
        )
      );
    }
  }
  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 500), (){
      checkFirstSeen();
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: Scaffold(
        backgroundColor: Colors.blue,
      ),
    );
  }
}