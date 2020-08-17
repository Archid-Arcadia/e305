import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:e305/loginManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/appbar/gf_appbar.dart';

import "globals.dart" as globals;

class BlackListView extends StatefulWidget {
  @override
  _AddRemoveListViewState createState() => _AddRemoveListViewState();
}

class _AddRemoveListViewState extends State<BlackListView> {
  final TextEditingController _textController = TextEditingController();

  final List<String> _listViewData = globals.blackList;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: GFAppBar(
          title: AutoSizeText(
            "Add & Remove from Blacklist",
            style: TextStyle(fontSize: 14),
          ),
          actions: <Widget>[
            loggedIn()
                ? IconButton(
                    icon: Icon(FontAwesomeIcons.download),
                    onPressed: () async {
                      await getUsersBlacklist();
                      setState(() {});
                    },
                  )
                : Container()
          ],
        ),
        body: Column(children: <Widget>[
          const SizedBox(height: 15),
          TextField(
            onSubmitted: (value) {
              _onSubmit(text: value);
            },
            controller: _textController,
            decoration: InputDecoration(
              hintText: "enter tag to block",
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: RaisedButton(
              onPressed: _onSubmit,
              color: Colors.blue,
              child: Text("Black List"),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.all(10),
                children: (_listViewData != null)
                    ? (_listViewData.reversed
                        .map((data) => Dismissible(
                              key: Key(data),
                              child: ListTile(
                                title: Text(data),
                              ),
                              onDismissed: (dismissed) {
                                _listViewData.remove(data);
                                globals.blackList.remove(data);
                                globals.saveBlackList();
                              },
                            ))
                        .toList())
                    : [Center(child: Text("Empty"))]),
          ),
        ]),
      );

  void _onSubmit({String text}) {
    if (text == null) {
      text = _textController.text;
    }
    setState(() {
      //_listViewData.add(_textController.text);
      if (text.isNotEmpty) {
        globals.blackList.add(text);
        globals.saveBlackList();
        _textController.clear();
      }
    });
  }
}
