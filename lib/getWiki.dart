import 'dart:core';

import 'package:dio/dio.dart';
import 'package:e305/cloudFlareDetector.dart';
import 'package:e305/wikiDefinition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'globals.dart' as globals;
import 'networking.dart';

Future<Wiki> getWiki(context, tag, {priority = 1, CancelToken token}) async {
  String search =
      'https://e621.net/wiki_pages.json?' + 'title=' + Uri.encodeComponent(tag);
  Wiki theWiki;
  var data = await networkingPriority(priority: priority)
      .get(search, cancelToken: token);
  flareDetect(context, data);
  if (data.statusCode == 200) {
    var jsonData = data.data;
    for (var w in jsonData) {
      //log(p['artist']);
      Wiki wiki = Wiki(w['id'], w['created_at'], w['updated_at'], w['title'],
          w['body'], w['updater_id'], w['is_locked'], w['version']);
      theWiki = wiki;
    }
    //log(theWiki.body);
  }
  return theWiki;
}

Widget getWikiBody(context, tag) {
  //log('Okeay');
  if (globals.tagCacheHelper[tag + ' |Wiki'] == null) {
    FutureBuilder(
      future: getWiki(context, tag),
      builder: (context, snapshot) {
        //log('Made it here');
        if (snapshot.hasData) {
          globals.tagCacheHelper[tag + ' | Wiki'] = snapshot.data.body;
          globals.saveTagCacheHelper();
          return Text(snapshot.data.body);
        } else {
          return Text('No Description');
        }
      },
    );
  } else {
    return Text(globals.tagCacheHelper[tag + ' | Wiki']);
  }
  return null;
}
