import 'dart:collection';
import 'dart:core';

import 'package:async/async.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/postDefinition.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:getflutter/getflutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preferences/preference_service.dart';

import 'globals.dart' as globals;
import 'searchPage.dart';
import 'ui-Toolkit.dart';

AsyncMemoizer saveCompute = AsyncMemoizer();
var sortedKeys;

LinkedHashMap sortedMap;

Future<Map<String, dynamic>> getStatIsolate(List<Post2> favorites) async {
  globals.rebuildingReccomenderFlag = true;
  var result = await compute(getStats, favorites);
  globals.rebuildingReccomenderFlag = false;
  return result;
}

Future<Map<String, dynamic>> getStats(List<Post2> favorites) async {
  try {
    //print(favorites);
    var sortedKeys;
    LinkedHashMap sortedMap;
    int sanityBreak = (favorites.length / 10).truncate();
    Map<String, int> metrics = {'': 0};
    List<String> tagList;
    for (Post2 favorite in favorites) {
      for (String key in favorite.tags.keys) {
        tagList.addAll(favorite.tags[key]);
      }
      for (String tag in tagList) {
        if (metrics.keys.toList().contains(tag)) {
          metrics[tag] += 1;
        } else {
          metrics[tag] = 1;
        }
//      if (globals.tagPairings.keys.toList().contains(tag)) {
//        globals.tagPairings[tag].addAll(tagList);
//        //log(pairings[tag]);
//        //pairings[tag] = pairings[tag].toSet().toList();
//      } else {
//        //List<String> modTagList = tagList;
//        //modTagList.remove(tag);
//        globals.tagPairings[tag] = tagList;
//      }
        if (sanityBreak < 1) {
          globals.favStats = LinkedHashMap.fromIterable(sortedKeys,
              key: (k) => k, value: (k) => metrics[k]).cast();
          sanityBreak = (favorites.length / 10).truncate();
        }
      }
    }
    sortedKeys = metrics.keys.toList(growable: false)
      ..sort((k1, k2) => metrics[k1].compareTo(metrics[k2]));
    sortedMap = LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => metrics[k]);
    Map<String, dynamic> normMap = normalizeMap(sortedMap.cast());
    //sortedMap = normalize(sortedMap.cast()).cast();
    //print((normalize(sortedMap)).runtimeType);
    log('Length of Sorted Keys: ' +
        sortedKeys.length.toString() +
        ' total known tags');
    return {'sortedMap': normMap, 'sortedKeys': sortedKeys};
  } catch (e) {
    log('getStats: ' + e.toString());
  }
  return {};
}

class FavoritesStatsPage extends StatefulWidget {
  final List<Post2> fav;

  FavoritesStatsPage(this.fav);

  @override
  _FavoritesStatsPageState createState() => _FavoritesStatsPageState(fav);
}

class _FavoritesStatsPageState extends State<FavoritesStatsPage> {
  final List<Post2> favorites;

  _FavoritesStatsPageState(this.favorites);

  @override
  Widget build(BuildContext context) {
    bool safe = (PrefService.getString('safe_choice') == 'SFW' ||
        PrefService.getString('safe_choice') == null);
    return (Scaffold(
        appBar: GFAppBar(
          title: Text(
            "Tag Frequency",
            style: TextStyle(fontSize: 14),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(FontAwesomeIcons.diceD20),
                onPressed: () {
                  goToSuggestion();
                }),
            IconButton(
                icon: Icon(FontAwesomeIcons.syncAlt),
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      saveCompute = AsyncMemoizer();
                    });
                  }
                  ;
                })
          ],
        ),
        body: FutureBuilder(future: saveCompute.runOnce(() {
          return compute(getStatIsolate, favorites);
        }), builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            sortedKeys = snapshot.data['sortedKeys'];
            sortedMap = snapshot.data['sortedMap'];
            if (sortedMap != null) {
              globals.favStats = sortedMap.cast();
              return ListView.builder(
                itemCount: sortedMap.length,
                itemBuilder: (BuildContext context, int index) {
                  String key = (sortedMap.keys.toList().reversed.toList())
                      .elementAt(index);
                  return InkWell(
                    child: Column(
                      children: <Widget>[
                        GFListTile(
                          title: Text("$key"),
                          avatar: FutureBuilder<String>(
                              future: getTopImage2(context, key, 0,
                                  safe: safe,
                                  safeLock: safe,
                                  pageOwner: globals.pageNumber,
                                  animations: false),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  //print(snapshot.data);
                                  if (snapshot.data == null) {
                                    return Container();
                                  }
                                  return GFAvatar(
                                      size: GFSize.LARGE,
                                      shape: GFAvatarShape.circle,
                                      backgroundImage: AdvancedNetworkImage(
                                          snapshot.data,
                                          cacheRule: CacheRule(
                                              maxAge:
                                                  const Duration(days: 7))));
                                } else if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Icon(FontAwesomeIcons.ban);
                                } else {
                                  return GFLoader();
                                }
                              }),
                          description: Text(
                              "${((sortedMap[key]) * 100).toStringAsFixed(2)}%"),
                        ),
                        Divider(
                          height: 2.0,
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.to(
                        SearchPage(
                          "$key order:score",
                          globals.postPageKey,
                          popToHome: false,
                        ),
                      );
                    },
                  );
                },
              );
            }
          }
          if ((snapshot.connectionState == ConnectionState.done)) {
            return (AnimatedContainer(
                duration: Duration(milliseconds: 250),
                child: Center(
                    child: AutoSizeText(
                        'Not enough favorites, At least 10 are needed for analysis.'))));
          }
          return Column(children: <Widget>[
            AnimatedContainer(
              duration: Duration(milliseconds: 250),
              child: Center(
                  child: AutoSizeText(
                'LOADING',
                minFontSize: 12,
                maxLines: 1,
                maxFontSize: 100,
                style: GoogleFonts.lexendDeca(fontSize: 100),
              )),
            ),
            Center(child: GFLoader())
          ]);
        })));
  }

  void goToSuggestion() {
    String val1 = '';
    if (sortedKeys.length > 1) {
      val1 = (sortedKeys.getRange(0, sortedKeys.length ~/ 8).toList()
            ..shuffle())
          .first;
    }
    Get.to(SearchPage(
      '' + val1 + ' order:score',
      globals.postPageKey,
      popToHome: false,
    ));
  }
}
