import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:orion/model/model_money.dart';
import 'package:orion/helper/util.dart';

class MoneyCard extends StatelessWidget{
  final double padding = GlobalVars.padding;
  final num bal;
  MoneyCard({this.bal});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: padding, top: padding, right: padding),
            child: TextWithIcon(Icons.account_balance_wallet, "Your Wallet")
          ),
          Divider(height: padding*2),
          Padding(
            padding: EdgeInsets.only(bottom: padding, left: padding, right:padding),
            child: MoneyView(bal: bal),
          ),
        ],
      ),
    );
  }
}

class MoneyView extends StatefulWidget{
  final num bal;
  MoneyView({this.bal});
  @override
  State<StatefulWidget> createState() => MoneyViewState(bal: bal);
}

class MoneyViewState extends State{
  final num bal;
  MoneyViewState({this.bal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Current Balance: ',
              style: Theme.of(context).textTheme.body1
            ),
            Consumer<Money>(
              builder: (context, money, child) => Text(
                GlobalVars.currencyFormat.format(bal??money.balance??0),
                style: Theme.of(context).textTheme.subtitle.copyWith(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w400
                ),
                textAlign: TextAlign.right,
              ),
            )
          ],
        ),
      ],
    );
  }
}