import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dio/dio.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/loginManager.dart';
import 'package:e305/mediaManager.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:e305/themeData.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pedantic/pedantic.dart';
import 'package:synchronized/synchronized.dart' as sync;

import 'followScreen.dart';
import 'globals.dart' as globals;
import 'postDefinition.dart';

List<int> addedToAccount = [];
GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

populateLastResults() {
  List<Post2> favorites = [];
  for (var key in globals.favoritesCache.keys.toList().reversed.toList()) {
    Post2 tempPost = jsonToPost2(globals.favoritesCache[key]);
    //print('made it here too');
    if (theGreatFilter2(tempPost)) {
      favorites.add(tempPost);
    }
    //print('made it here aswell');
  }
  globals.lastResults = favorites;
}

backupOffline(BuildContext context, List<String> keys) async {
  for (String key in keys) {
    Post2 post = jsonToPost2(globals.favoritesCache[key]);
    if (post.fileExt != null &&
        (post.fileExt != 'webm' && post.fileExt != 'swf')) {
      log('Archiving: ' + post.id.toString());
      try {
        await precacheImage(
          AdvancedNetworkImage(
            post.sampleUrl,
            useDiskCache: true,
            cacheRule: CacheRule(
                maxAge: const Duration(days: 30),
                storeDirectory: StoreDirectoryType.document),
          ),
          context,
        );
      } catch (e) {
        print(e);
      }
      try {
        await precacheImage(
          AdvancedNetworkImage(
            post.fileUrl,
            useDiskCache: true,
            cacheRule: CacheRule(
                maxAge: const Duration(days: 30),
                storeDirectory: StoreDirectoryType.document),
          ),
          context,
        );
      } catch (e) {
        print(e);
      }
    } else {
      log('Skipped: ' + post.id.toString() + ' FileType:' + post.fileExt);
    }
  }
}

bool containsTags(Post2 post, List<String> tags) {
  bool missedTag = false;
  List<String> dupTags = List<String>.from(tags);
  while (dupTags.isNotEmpty && !missedTag) {
    String tag = dupTags.removeLast().toLowerCase();
    bool exists = false;
    for (String key in post.tags.keys) {
      if (!exists) {
        if ((post.tags[key] as List).contains(tag)) {
          exists = true;
        }
      }
    }
    if (!exists) {
      missedTag = true;
    }
  }
  return !missedTag;
}

sync.Lock favGet = sync.Lock();

getMissingFav(String id, {bool force = false, CancelToken token}) async {
  await favGet.synchronized(() async {
    print('Requesting Updated Post: ' + id);
    if ((globals.favoritesCache[id] == null || force) &&
        !addedToAccount.contains(int.parse(id))) {
      Post2 post =
          await getPostByID2(BuildContext, int.parse(id), token: token);
      globals.favoritesCache[post.id.toString()] = post.toJson();
      globals.saveFavoritesCache();
      print('Received Post: ' + id);
    }
  });
}

class FavoritesPage extends StatefulWidget {
  FavoritesPage();

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<FavoritesPage> {
  final GlobalKey pageKey = GlobalKey();
  final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  List<String> presentTags;
  int page = 0;
  bool holdLoad = false;
  int previousPostCount = 0;
  ScrollController _scrollController = ScrollController();
  double previousPos = 0.0;
  List<Post2> posts = [];
  bool topdown = true;
  List<String> filterList;
  TextEditingController filterCont = TextEditingController();
  String sort = 'order:added';
  bool highres = highRes();
  CancelToken token;

  syncLocalFav(key) async {
    unawaited(addFavToAccount(int.parse(key), token: token));
    addedToAccount.add(int.parse(key));
  }

  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool rebuild() {
      posts = [];
      setState(() {});
      return true;
    }

    List<String> sortChoice(List<String> options) {
      if (sort == 'order:added') {
        return options;
      } else if (sort == 'order:score') {
        Map<double, String> scores = {};
        for (String key in options) {
          double increment = 0;
          int score = jsonToPost2(globals.favoritesCache[key]).scoreTotal;
          while (scores.containsKey(score + increment)) {
            increment += 0.000000001;
          }
          scores[score + increment] = key;
        }
        List<double> sortedKeys = (scores.keys.toList())..sort();
        List<String> sortPattern = [];
        for (double key in sortedKeys.reversed) {
          sortPattern.add(scores[key]);
        }
        return sortPattern;
      } else if (sort == 'order:favcount') {
        Map<double, String> favCounts = {};
        for (String key in options) {
          double increment = 0;
          int fav_count = jsonToPost2(globals.favoritesCache[key]).fav_count;
          while (favCounts.containsKey(fav_count + increment)) {
            increment += 0.000000001;
          }
          favCounts[fav_count + increment] = key;
        }
        List<double> sortedKeys = (favCounts.keys.toList())..sort();
        List<String> sortPattern = [];
        for (double key in sortedKeys.reversed) {
          sortPattern.add(favCounts[key]);
        }
        return sortPattern;
      } else if (sort == 'order:tagcount') {
        Map<double, String> tagcounts = {};
        for (String key in options) {
          double increment = 0;
          int totalTags(Post2 post) {
            int counter = 0;
            for (String key in post.tags.keys) {
              counter += (post.tags[key] as List).length;
            }
            return counter;
          }

          int tagcount = totalTags(jsonToPost2(globals.favoritesCache[key]));
          while (tagcounts.containsKey(tagcount + increment)) {
            increment += 0.000000001;
          }
          tagcounts[tagcount + increment] = key;
        }
        List<double> sortedKeys = (tagcounts.keys.toList())..sort();
        List<String> sortPattern = [];
        for (double key in sortedKeys.reversed) {
          sortPattern.add(tagcounts[key]);
        }
        return sortPattern;
      } else if (sort == 'order:comments') {
        Map<double, String> comment_counts = {};
        for (String key in options) {
          double increment = 0;
          int comment_count =
              jsonToPost2(globals.favoritesCache[key]).comment_count;
          while (comment_counts.containsKey(comment_count + increment)) {
            increment += 0.000000001;
          }
          comment_counts[comment_count + increment] = key;
        }
        List<double> sortedKeys = (comment_counts.keys.toList())..sort();
        List<String> sortPattern = [];
        for (double key in sortedKeys.reversed) {
          sortPattern.add(comment_counts[key]);
        }
        return sortPattern;
      } else if (sort == 'order:id') {
        Map<int, String> comment_counts = {};
        for (String key in options) {
          int id = jsonToPost2(globals.favoritesCache[key]).id;
          comment_counts[id] = key;
        }
        List<int> sortedKeys = (comment_counts.keys.toList())..sort();
        List<String> sortPattern = [];
        for (int key in sortedKeys.reversed) {
          sortPattern.add(comment_counts[key]);
        }
        return sortPattern;
      } else if (sort == 'order:random') {
        return options..shuffle();
      } else {
        print('unsorted');
        return options;
      }
    }

    List<String> dumpTags(Post2 post) {
      List<String> tags = [];
      for (String key in post.tags.keys) {
        tags.addAll((post.tags[key] as List).cast<String>().toList());
      }
      return tags;
    }

    List<String> tempPresentTags = [];
    List<Post2> favoritesPosts = [];
    List<String> sortedKeys = [];
    List<String> sortedIdsRaw = [];
    //scaffoldKey = GlobalKey<ScaffoldState>();
    if (loggedIn() && accountTable['idSort'] != null) {
      sortedIdsRaw = List<String>.from(accountTable['idSort']);
    } else {
      print('idSort is null');
    }
    List<String> toGrave = [];
    for (String key in globals.favoritesCache.keys) {
      if (!sortedIdsRaw.contains(key)) {
        if (globals.favoritesCache[key] != null) {
          bool flagPresent = false;
          if (!addedToAccount.contains(int.parse(key))) {
            if (!jsonToPost2(globals.favoritesCache[key]).flags['deleted'] &&
                !jsonToPost2(globals.favoritesCache[key]).flags['flagged']) {
              unawaited(syncLocalFav(key));
            } else {
              flagPresent = true;
              print('Graveyarded: ' + key);
              toGrave.add(key);
            }
          }
          if (!flagPresent) {
            if (globals.favoritesCache[key] == null) {
              getMissingFav(key, force: true, token: token);
            }
            sortedKeys.add(key);
          }
        }
      }
    }
    for (String key in toGrave) {
      globals.favoritesCache.remove(key);
    }
    sortedKeys = sortedKeys.reversed.toList();
    sortedKeys.addAll(sortedIdsRaw);
    sortedKeys = sortChoice(sortedKeys);
    for (var key in sortedKeys) {
      Post2 tempPost = jsonToPost2(globals.favoritesCache[key]);
      if (tempPost != null) {
        if (globals.favoritesCache[key]['time'] == null) {
          if (theGreatFilter2(tempPost)) {
            if (presentTags == null) {
              tempPresentTags.addAll(dumpTags(tempPost));
            }
            if (filterList == null) {
              favoritesPosts.add(tempPost);
            } else {
              if (filterList.contains(key)) {
                favoritesPosts.add(tempPost);
              }
            }
          }
        }
      } else {
        log(globals.favoritesCache[key]);
        if (globals.favoritesCache[key] == null) {
          if (sortedIdsRaw.contains(key)) {
            log('They came from above!');
            getMissingFav(key);
          } else {
            globals.favoritesCache.remove(key);
            log('Shredded false fav: ' + key);
            globals.saveFavoritesCache();
          }
        }
        log('Fav: ' + key + ' Is missing!');
      }
    }
    if (presentTags == null) {
      presentTags = tempPresentTags.toSet().toList();
    }
    try {
      return Scaffold(
        key: key,
        body: gradientBackground(context,
            child: OrientationBuilder(builder: (ocontext, orientation) {
          int crossAxisCountVar = orientation == Orientation.portrait ? 6 : 12;
          int crossAxisCountVarFit =
              orientation == Orientation.portrait ? 3 : 3;
          return (CustomScrollView(controller: _scrollController, slivers: <
              Widget>[
            SliverAppBar(
              pinned: false,
              snap: false,
              floating: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(FontAwesomeIcons.searchengin),
                  onPressed: () {
                    showModalBottomSheet<void>(
                        context: ocontext,
                        isScrollControlled: true,
                        builder: (BuildContext mContext) {
                          submitFunction(String input) {
                            List<String> tags = [];
                            if (input.contains(' ')) {
                              tags = input.split(' ');
                            } else {
                              tags.add(input);
                            }
                            List<String> matches = globals.favoritesCache.keys
                                .toList()
                                .where((element) {
                              return containsTags(
                                  jsonToPost2(globals.favoritesCache[element]),
                                  tags);
                            }).toList();
                            filterList = matches;
                            Navigator.of(context).pop();
                            rebuild();
                          }

                          AutoCompleteTextField form = AutoCompleteTextField(
                            controller: filterCont,
                            suggestionsAmount: 3,
                            itemBuilder: (context, item) {
                              return Container(
                                color: getPanacheTheme().bottomAppBarColor,
                                padding: const EdgeInsets.all(8),
                                child: (item != null)
                                    ? AutoSizeText(
                                        item,
                                        style: getPanacheTheme()
                                            .primaryTextTheme
                                            .subtitle2,
                                      )
                                    : Container(),
                              );
                            },
                            suggestions: presentTags,
                            itemFilter: (item, query) {
                              if (query.contains(' ')) {
                                String last = query.split(' ').last;
                                return item
                                    .toLowerCase()
                                    .startsWith(last.toLowerCase());
                              }
                              return item
                                  .toLowerCase()
                                  .startsWith(query.toLowerCase());
                            },
                            textSubmitted: (input) {
                              print('Search: ' + input);
                              submitFunction(input);
                            },
                            decoration: InputDecoration(
                              hintText: 'Filter by tag',
                              prefixIcon: Icon(
                                FontAwesomeIcons.tags,
                                size: 28.0,
                              ),
                            ),
                          );
                          return Container(
                              child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Wrap(children: [
                              Container(
                                child: Container(child: form),
                                width: MediaQuery.of(context).size.width,
                              ),
                              Container(
                                child: RaisedButton(
                                  child: Text('Search'),
                                  onPressed: () {
                                    submitFunction(filterCont.text);
                                  },
                                ),
                                alignment: Alignment.center,
                              ),
                              Container(
                                child: DropdownButton<String>(
                                  items: <String>[
                                    'order:added',
                                    'order:id',
                                    'order:score',
                                    'order:favcount',
                                    'order:tagcount',
                                    'order:comments',
                                    'order:random'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  value: sort,
                                  onChanged: (selection) {
                                    sort = selection;
                                    Navigator.of(context).pop();
                                    rebuild();
                                  },
                                ),
                                alignment: Alignment.center,
                              ),
                              Container(height: kBottomNavigationBarHeight * 2)
                            ]),
                          ));
                        });
                  },
                ),
                PopupMenuButton(
                  icon: Icon(FontAwesomeIcons.ellipsisV),
                  //isExpanded: true,
                  onSelected: (choice) {},
                  itemBuilder: (BuildContext context) {
                    List popUpItems = <PopupMenuItem<Widget>>[
                      loggedIn()
                          ? PopupMenuItem(
                              child: ListTile(
                              title: Text('Sync Favorites'),
                              leading: Icon(FontAwesomeIcons.download),
                              onTap: () async {
                                try {
                                  Get.snackbar(
                                      "Synchronizer", "Beginning Fav Sync",
                                      icon: Icon(FontAwesomeIcons.download));
                                } on NoSuchMethodError {
                                  log('Snackbar Error');
                                }
                                Navigator.of(context).pop();
                                await getUsersFavoritesSort(context);
                                try {
                                  Get.snackbar(
                                      "Synchronizer", "Fav Sync Complete",
                                      icon: Icon(FontAwesomeIcons.download));
                                } on NoSuchMethodError {
                                  log('Snackbar Error');
                                }
                                setState(() {});
                              },
                            ))
                          : null,
                      PopupMenuItem(
                          child: ListTile(
                        leading: Icon(FontAwesomeIcons.solidSave),
                        onTap: () async {
                          Navigator.pop(context);
                          await Get.to(
                            FollowScreen(globals.follows),
                          );
                        },
                        title: Text('View Saved Searches'),
                      )),
                      PopupMenuItem(
                          child: ListTile(
                        leading: Icon(FontAwesomeIcons.archive),
                        onTap: () async {
                          Navigator.of(context).pop();
                          try {
                            Get.snackbar(
                              "Archivist",
                              "Freshening up offline storage, Might take a while...",
                              icon: Icon(FontAwesomeIcons.book),
                              animationDuration: Duration(milliseconds: 100),
                              duration: Duration(seconds: 10),
                            );
                          } on NoSuchMethodError {
                            log('Snackbar Error');
                          }
                          await backupOffline(context, sortedKeys);
                          try {
                            Get.snackbar(
                              "Archivist",
                              "Complete! Offline storage is fresh as a daisy.",
                              icon: Icon(FontAwesomeIcons.book),
                              animationDuration: Duration(milliseconds: 100),
                              duration: Duration(seconds: 2),
                            );
                          } on NoSuchMethodError {
                            log('Snackbar Error');
                          }
                        },
                        title: Text('Rebuild Offline Storage'),
                      )),
                      PopupMenuItem(
                          child: ListTile(
                        leading: Icon(FontAwesomeIcons.skull),
                        onTap: () async {
                          print('Purging');
                          Navigator.of(context).pop();
                          try {
                            Get.snackbar(
                              "Head Hunter",
                              "Removing dead posts",
                              icon: Icon(FontAwesomeIcons.crosshairs),
                              animationDuration: Duration(milliseconds: 100),
                              duration: Duration(seconds: 2),
                            );
                          } on NoSuchMethodError {
                            log('Snackbar Error');
                          }
                          if (loggedIn()) {
                            globals.favoritesCache.removeWhere((key, value) {
                              Post2 post = jsonToPost2(value);
                              bool flags = (post.flags['deleted'] ||
                                  post.flags['flagged']);
                              if (flags) {
                                print('Removing: ' + key);
                                remFavToAccount(post.id);
                                //addedToAccount.add(post.id);
                                (accountTable['idSort'] as List)
                                    .remove(post.id.toString());
                              }
                              return flags;
                            });

                            //await getUsersFavoritesSort(context);
                          } else {
                            globals.favoritesCache.removeWhere((key, value) {
                              Post2 post = jsonToPost2(value);
                              return (post.flags['deleted'] ||
                                  post.flags['flagged']);
                            });
                          }
                          globals.saveFavoritesCache();
                          try {
                            Get.snackbar("Head Hunter", "Job Done",
                                icon: Icon(FontAwesomeIcons.crosshairs));
                          } on NoSuchMethodError {
                            log('Snackbar Error');
                          }

                          print('Purging Complete');
                          setState(() {});
                        },
                        title: Text('Remove Deleted Posts'),
                      )),
                    ];
                    return popUpItems;
                  },
                )
//                  IconButton(
//                    icon: Icon(FontAwesomeIcons.atom),
//                    onPressed: () {
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                          builder: (context) =>
//                              FavoritesStatsPage(favoritesPosts),
//                        ),
//                      );
//                    },
//                  )
              ],
              title: Text("Favorites"),
            ),
            ((globals.favoritesCache.keys.isNotEmpty)
                ? (SliverStaggeredGrid.countBuilder(
                    key: PageStorageKey(0),
                    itemCount: favoritesPosts.length,
                    crossAxisCount: crossAxisCountVar,
                    itemBuilder: (BuildContext context, int index) {
                      return GridPostCardWidget(
                          context, favoritesPosts, index, false,
                          icon: FontAwesomeIcons.heart);
                    },
                    staggeredTileBuilder: (int index) =>
                        StaggeredTile.fit(crossAxisCountVarFit),
                  ))
                : (SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "Nothing to see here (You haven't favorited yet)",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  ))),
            SliverToBoxAdapter(
                child: Container(
              height: kBottomNavigationBarHeight,
            ))
          ]));
        })),
      );
    } catch (e) {
      print(e);
    }
    return Container();
  }

  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    globals.pageNumber += 1;
    super.initState();
    page = 0;
    holdLoad = false;
    previousPostCount = 0;
    token = CancelToken();
    _scrollController = ScrollController();
    previousPos = 0.0;
    posts = [];
    try {
      populateLastResults();
    } catch (e) {
      print(e);
    }

    // getUsersFavoritePosts(context, 'RMTP3');
  }

//  @override
//  bool get wantKeepAlive => true;
}
