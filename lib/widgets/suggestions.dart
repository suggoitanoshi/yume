import 'dart:async';

import 'package:flutter/material.dart';

class TextSuggestion extends StatefulWidget{
  final FocusNode focusNode;
  final InputDecoration decoration;
  final TextEditingController controller;
  final FutureOr<List<String>> Function(String) suggestionCallback;

  TextSuggestion({this.focusNode, this.decoration, this.controller, this.suggestionCallback});

  @override
  State<StatefulWidget> createState() => TextSuggestionState(
    focusNode: focusNode,
    decoration: decoration,
    controller: controller,
    suggestionsCallback: suggestionCallback
  );
}

class TextSuggestionState extends State<TextSuggestion>{
  FocusNode focusNode;
  OverlayEntry _overlayEntry;
  InputDecoration decoration;
  TextEditingController controller;
  FutureOr<List<String>> Function(String) suggestionsCallback;
  List<String> _suggestions = [];
  final LayerLink _layerLink = LayerLink();
  Timer _debounce;

  @override
  void initState(){
    super.initState();
    focusNode.addListener((){
      if(focusNode.hasFocus){
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry);
      }
      else{
        _overlayEntry?.remove();
      }
    });
    controller.addListener((){
      if(_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(Duration(milliseconds: 500), () async {
        List<String> list = await suggestionsCallback(controller.text);
        Overlay.of(context).setState((){
          _suggestions = list;
        });
      });
    });
  }

  @override
  void dispose(){
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry(){
    RenderBox renderBox = context.findRenderObject();
    Size size = renderBox.size;
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, -(size.height*(_suggestions.length))),
          child: Material(
            elevation: 4,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, i){
                return ListTile(
                  title: Text(_suggestions[i]),
                  onTap: (){
                    controller.text = _suggestions[i];
                    focusNode.unfocus();
                  }
                );
              },
              separatorBuilder: (context, i) => Divider(height: 4),
            ),
          )
        )
      )
    );
  }

  TextSuggestionState({this.decoration, this.controller, this.focusNode, this.suggestionsCallback});
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        decoration: decoration??InputDecoration( enabled: true, ),
        controller: controller,
        focusNode: focusNode,
      ),
    );
  }
}