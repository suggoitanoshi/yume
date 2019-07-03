import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:orion/widgets/home_moneyview.dart';
import 'package:orion/widgets/home_activityview.dart';

import 'package:orion/widgets/fab_add.dart';

class Home extends StatelessWidget{
  final String name;
  final num bal;
  Home({this.name, this.bal});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text('Welcome back, '),
            Text(name),
            Text('!'),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(0),
        scrollDirection: Axis.vertical,
        children: <Widget>[
          MoneyCard(bal: bal),
          ActivityCard(),
        ],
      ),
      floatingActionButton: FloatingAdd(),
    );
  }
}