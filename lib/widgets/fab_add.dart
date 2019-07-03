import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:orion/widgets/fullactivity_widget.dart';

class FloatingAdd extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: (){
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => Scaffold(
            appBar: AppBar(
              title: Text('Add Activity'),
            ),
            body: CreateActivityView(),
          ),
        ));
      },
    );
  }
}