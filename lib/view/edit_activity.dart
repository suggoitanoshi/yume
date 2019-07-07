import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:orion/model/money_activity.dart';

import 'package:orion/widgets/activityedit_widget.dart';

class EditActivityScreen extends StatelessWidget{
  final MoneyActivity _act;
  EditActivityScreen(this._act);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Activity'),
      ),
      body: CreateActivityView(act: _act),
    );
  }
}