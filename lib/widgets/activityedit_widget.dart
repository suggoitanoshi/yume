import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:orion/helper/database.dart';
import 'package:orion/helper/service_locator.dart';
import 'package:provider/provider.dart';

import 'package:orion/helper/InputCurrencyFormatter.dart';
import 'package:orion/model/model_money.dart';
import 'package:orion/model/model_activitylist.dart';
import 'package:orion/model/money_activity.dart';
import 'package:orion/helper/util.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CreateActivityView extends StatefulWidget{
  final MoneyActivity act;
  CreateActivityView({this.act});
  @override
  State<StatefulWidget> createState() => CreateActivityState(act);
}

class CreateActivityState extends State{
  static const Key doneKey = Key('done key');
  static const Key balanceKey = Key('balance key');

  static const Key incomeKey = Key('income key');
  static const Key outcomeKey = Key('outcome key');

  MoneyActivity _act;

  TextEditingController _amount = TextEditingController();
  TextEditingController _title = TextEditingController();
  TextEditingController _desc = TextEditingController();
  TextEditingController _category = TextEditingController();

  DateTime _pickedDate = DateTime.now();

  TextEditingController _dateYear;
  TextEditingController _dateMonth;
  TextEditingController _dateDay;

  FocusNode _yearNode = FocusNode();
  FocusNode _monthNode = FocusNode();
  FocusNode _dayNode = FocusNode();

  FocusNode _titleNode = FocusNode();
  FocusNode _descNode = FocusNode();
  FocusNode _categoryNode=  FocusNode();

  bool _isIncome = true;
  int _dirValue = 0;

  bool _canPressDone = true;

  final _formKey = GlobalKey<FormState>();

  CreateActivityState(this._act);

  @override
  void initState(){
    super.initState();
    if(this._act != null){
      _amount = TextEditingController(text: GlobalVars.currencyFormat.format(_act.amount));
      _title = TextEditingController(text: _act.title);
      _desc = TextEditingController(text: _act.desc);
      _category = TextEditingController(text: _act.category);
      _pickedDate = _act.time;
      _isIncome = _act.income;
      _dirValue = (_isIncome)?0:1;
    }
    _dateYear = TextEditingController(text: _pickedDate.year.toString());
    _dateMonth = TextEditingController(text: _pickedDate.month.toString());
    _dateDay = TextEditingController(text: _pickedDate.day.toString());
  }

  @override
  void dispose(){
    _amount.dispose();
    _title.dispose();
    _desc.dispose();
    _category.dispose();
    super.dispose();
  }

  void _handleDirChange(int value){
    setState((){
      _dirValue = value;
      switch(value){
        case 0:
          _isIncome = true;
          break;
        case 1:
          _isIncome = false;
          break;
      }
    });
  }

  void _setDateByText({int year, int month, int day}){
    _pickedDate = DateTime(year??_pickedDate.year, month??_pickedDate.month, day??_pickedDate.day);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child:ListView(
        padding: EdgeInsets.all(GlobalVars.padding),
        children: <Widget>[
          TextFormField(
            key: balanceKey,
            controller: _amount,
            autofocus: true,
            validator: (value){
              return value.isEmpty?'Amount cannot be zero':null;
            },
            decoration: InputDecoration(
              labelText: 'Amount',
              icon: Icon(Icons.attach_money),
              prefix: Text(NumberFormat.simpleCurrency().currencySymbol)
            ),
            inputFormatters: <TextInputFormatter>[
              InputCurrencyFormatter(),
            ],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onEditingComplete: (){
              FocusScope.of(context).requestFocus(_yearNode);
            },
            style: TextStyle(
              fontSize: 28,
            ),
            textAlign: TextAlign.right,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Radio(
                key: incomeKey,
                value: 0,
                groupValue: _dirValue,
                onChanged: _handleDirChange,
              ),
              GestureDetector(
                onTap: (){_handleDirChange(0);},
                child:  Text('Income'),
              ),
              Radio(
                key: outcomeKey,
                value: 1,
                groupValue: _dirValue,
                onChanged: _handleDirChange,
              ),
              GestureDetector(
                onTap: (){_handleDirChange(1);},
                child:  Text('Outcome'),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _dateYear,
                  focusNode: _yearNode,
                  decoration: InputDecoration(
                    hintText: 'yyyy',
                  ),
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(4),
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  onEditingComplete: () => FocusScope.of(context).requestFocus(_monthNode),
                  onChanged: (String text){
                    int value = int.parse(text);
                    if(value < DateTime.now().subtract(Duration(days: 5*365)).year) return;
                    _setDateByText(year: value);
                  }
                )
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Text('-'),
              ),
              Expanded(
                child: TextField(
                  controller: _dateMonth,
                  focusNode: _monthNode,
                  decoration: InputDecoration(
                    hintText: 'mm',
                  ),
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onEditingComplete: () => FocusScope.of(context).requestFocus(_dayNode),
                  onChanged: (String text){
                    int value = int.parse(text);
                    if(value < 1 || value > 12) return;
                    _setDateByText(month: value);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Text('-'),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: TextField(
                    controller: _dateDay,
                    focusNode: _dayNode,
                    decoration: InputDecoration(
                      hintText: 'dd',
                    ),
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_titleNode),
                    onChanged: (String text){
                      int value = int.parse(text);
                      if(value < 1 || value > 31) return;
                      _setDateByText(day: value);
                    },
                  )
                ),
              ),
              RaisedButton(
                child: Text('Set Date'),
                onPressed: ()async{
                  DateTime picked = await showDatePicker(
                    context: context,
                    initialDate: _pickedDate,
                    firstDate: new DateTime.now().subtract(Duration(days: 365*5)),
                    lastDate: new DateTime.now()
                  );
                  if(picked != null){ setState((){
                    _pickedDate = picked.toLocal();
                    _dateYear.text = _pickedDate.year.toString();
                    _dateMonth.text = _pickedDate.month.toString();
                    _dateDay.text  = _pickedDate.day.toString();
                  }); }
                },
              )
            ],
          ),
          TextField(
            controller: _title,
            focusNode: _titleNode,
            decoration: InputDecoration(
              labelText: 'Title',
            ),
            maxLength: 50,
            textInputAction: TextInputAction.next,
            onEditingComplete: (){
              FocusScope.of(context).requestFocus(_descNode);
            },
          ),
          TextField(
            controller: _desc,
            focusNode: _descNode,
            decoration: InputDecoration(
              labelText: 'Description',
            ),
            maxLines: null,
          ),
          TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _category,
              focusNode: _categoryNode,
              decoration: InputDecoration(
                labelText: 'Category'
              ),
            ),
            suggestionsCallback: (pattern) async {
              return await locator.get<DatabaseHandler>().getCategoryByPattern(pattern);
            },
            itemBuilder: (context, suggestion){
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion){
              _category.text = suggestion;
            },
          ),
          RaisedButton(
            key: doneKey,
            child: Text('Done'),
            onPressed: _canPressDone?_handleSubmit:null,
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    setState((){
      _canPressDone = false;
    });
    if(_formKey.currentState.validate()){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Saving data')));
      num amount  = GlobalVars.currencyFormat.parse(_amount.text);
      MoneyActivity newAct = MoneyActivity(
        amount: amount,
        title: _title.text,
        desc: _desc.text,
        category: _category.text,
        time: _pickedDate,
        income: _isIncome
      );
      if(_act != null){
        bool isInvert = (_act.income != newAct.income);
        num delta = (_act.amount - (isInvert?-amount:amount)).abs();
        if(_isIncome) await Provider.of<Money>(context).addMoney(delta);
        else await Provider.of<Money>(context).subMoney(delta);
        newAct.id = _act.id;
        await Provider.of<ActivityListModel>(context).updateActivity(_act, newAct);
        _canPressDone = true;
        Navigator.of(context).pop();
      }
      else{
        if(_isIncome) await Provider.of<Money>(context).addMoney(amount);
        else await Provider.of<Money>(context).subMoney(amount);
        await Provider.of<ActivityListModel>(context).addActivity(newAct);
        Navigator.of(context).pop();
      }
    }
    else{
      _canPressDone = true;
    }
  }
}