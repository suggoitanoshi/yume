import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:orion/helper/InputCurrencyFormatter.dart';
import 'package:orion/helper/util.dart';
import 'package:orion/model/model_money.dart';
import 'package:orion/view/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialSetup extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => InitialSetupState();
}

class InitialSetupState extends State{
  static const Key finalizeSetupKey = Key('finalize setup');
  static const Key nameInputKey = Key('name input');
  static const Key balanceInputKey = Key('balance input');

  TextEditingController _name = TextEditingController();
  TextEditingController _bal = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome!',
              style: Theme.of(context).textTheme.display2,
            ),
            Text(
              'Please tell me your preferred name: ',
              style: Theme.of(context).textTheme.display1,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child:  TextField(
                key: nameInputKey,
                controller: _name,
                decoration: InputDecoration(
                  hintText: 'Preferred name'
                ),
                maxLength: 20,
              ),
            ),
            Text(
              'And your current balance: ',
              style: Theme.of(context).textTheme.display1.apply(fontSizeFactor: .8),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                key: balanceInputKey,
                controller: _bal,
                decoration: InputDecoration(
                  prefix: Icon(Icons.attach_money),
                  hintText: 'Current balance'
                ),
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly,
                  InputCurrencyFormatter()
                ],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
              ),
            ),
            IconButton(
              key: finalizeSetupKey,
              icon: Icon(Icons.arrow_forward, color: Theme.of(context).accentColor),
              iconSize: 48,
              tooltip: 'Finish Set Up!',
              onPressed: () async {
                if(_name.text == '') return;
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setString('name', _name.text);
                num balance = GlobalVars.currencyFormat.parse((_bal.text=='')?0:_bal.text);
                Provider.of<Money>(context).setMoney(balance);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => Home(name: _name.text, bal: balance),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}