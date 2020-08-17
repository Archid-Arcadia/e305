import 'dart:convert';
import 'dart:core';

import 'package:e305/postDefinition.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

import 'ui-Toolkit.dart';

final tagThrottle = Lock();
//final tagThrottle = Lock();
List<String> blackList = [];
Map<String, dynamic> favoritesCache = {};
Map<String, dynamic> favStats;
List<String> follows = [];
GlobalKey globalBarKey = GlobalKey(debugLabel: 'btm_app_bar');
Map<String, Object> homeRecent = {};
Map<String, Object> homeTrend = {};
DateTime lastHomeRecentLoad;
DateTime lastHomeTrendLoad;
Route<Path> lastMajorPage;
String lastMinTrend;
List<Post2> lastResults = [];

double lastRun = 0;
String lastSafe;
String lastSearch = '';
List<String> lastSearchTagResults = [];
String lastTrendSafe;
int onTime = 0;
int pageNumber = 0;
bool postLock = false;
Key postPageKey = Key('PostPage');
List<Post2> preLoadedFavs = [];
bool rebuildingReccomenderFlag = false;
Map<String, String> tagCacheHelper = {};
Map<String, List<String>> tagPairings = {};
List<String> tags = [];

refreshTags() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('tags', tags);
  String animSpliter = ' -type:swf ';
  tags = [];
  for (String url in tagCacheHelper.keys.toList()) {
    url = Uri.decodeComponent(url.split('tags=')[1]);
    if (!url.contains('-type:swf')) {
      animSpliter = '-animation';
    } else {
      animSpliter = ' -type:swf ';
    }
    url = url.split(animSpliter)[0].trim();
    tags.add(url);
  }
  tags = tags.toSet().toList();
  //log(tags);
}

saveBlackList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('blackList', blackList);
}

saveFavoritesCache() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('favoritesCache', jsonEncode(favoritesCache));
}

saveFollowList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  log('Saved Follow List');
  await prefs.setStringList('Follows', follows);
}

saveTagCacheHelper() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('tagCacheHelper', jsonEncode(tagCacheHelper));
}

saveTagPairings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('tagPairing', jsonEncode(tagPairings));
}

startBlackList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> temp = prefs.getStringList('blackList');
  if (temp != null) {
    blackList = temp;
  }
}

startFavoritesCache() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String favoritesCacheJson = prefs.getString('favoritesCache');
  if (favoritesCacheJson != null) {
    favoritesCache = Map<String, dynamic>.from(json.decode(favoritesCacheJson));
    log('Loaded Favorites: ' +
        favoritesCache.length.toString() +
        ' favorites.');
  }
}

startFollowList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> temp = prefs.getStringList('Follows');
  if (temp != null) {
    //log('Started Follow List');
    follows = temp;
  }
}

startTagCacheHelper() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String tagCacheJson = prefs.getString('tagCacheHelper');
  if (tagCacheJson != null) {
    tagCacheHelper = Map<String, String>.from(json.decode(tagCacheJson));
  }
}

startTagPairings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String temp = prefs.getString('tagPairing');
  if (temp != null) {
    tagPairings = Map<String, List<String>>.from(json.decode(temp));
  }
}

startTags() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> temp;
  temp = prefs.getStringList('tags');
  if (temp != null) {
    tags = temp;
  }
}
