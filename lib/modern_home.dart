import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:e305/getComments.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/loginManager.dart';
import 'package:e305/mediaManager.dart';
import 'package:e305/postDefinition.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_point_tab_bar/pointTabBar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:getflutter/getflutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preferences/preference_service.dart';

import 'globals.dart' as globals;

class ModernHome extends StatefulWidget {
  @override
  _ModernHomeState createState() => _ModernHomeState();
}

class _ModernHomeState extends State<ModernHome>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController _controller;
  SliverChildDelegate sdelegate;
  Map<int, Future> futures = {};
  List<String> targetTags = [];
  List genTags = [];
  Future recents;
  Future trendings;
  int initialIndex = 0;
  final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final CancelToken token = CancelToken();
  bool animateCarousels = (PrefService.getBool('animateCarousel') != null)
      ? PrefService.getBool('animateCarousel')
      : false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    recents = getPosts2(context, token: token);
    trendings = getTrendingIfChanged2(context, fallback: true, token: token);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    token.cancel('page disposed');
    super.dispose();
  }

  Widget TrendingCarousel(BuildContext context) {
    return FutureBuilder(
        future: trendings,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done || snap.hasData) {
            if (snap.hasData) {
              List<Post2> posts = ((snap.data as Map<String, dynamic>)['posts']
                      as List)
                  .where((element) => !((element as Post2).flags['deleted']))
                  .toList();
              CarouselController controller = CarouselController();
              return CarouselSlider.builder(
                carouselController: controller,
                options: CarouselOptions(
                    enableInfiniteScroll: animateCarousels,
                    autoPlay: animateCarousels,
                    height: (400)),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    child: carouselCard(context, (posts[index]),
                        index: index, posts: posts),
                    padding: EdgeInsets.only(right: (25)),
                  );
                },
              );
            } else {
              return Icon(FontAwesomeIcons.ban);
            }
          } else {
            return GFLoader();
          }
        });
  }

  Widget RecentCarousel(BuildContext context) {
    return FutureBuilder(
        future: recents,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done || snap.hasData) {
            if (snap.hasData) {
              List<Post2> posts = ((snap.data as Map<String, dynamic>)['posts']
                      as List)
                  .where((element) => !((element as Post2).flags['deleted']))
                  .toList();
              CarouselController controller = CarouselController();
              return CarouselSlider.builder(
                carouselController: controller,
                options: CarouselOptions(
                    enableInfiniteScroll: animateCarousels,
                    autoPlay: animateCarousels,
                    height: (400)),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    child: carouselCard(context, (posts[index]),
                        index: index, posts: posts),
                    padding: EdgeInsets.only(right: (25)),
                  );
                },
              );
            } else {
              return Icon(FontAwesomeIcons.ban);
            }
          } else {
            return GFLoader();
          }
        });
  }

  Widget RankCarousel(BuildContext context) {
    return FutureBuilder(
        future: getPosts2(context, tag: 'order:rank', token: token),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done || snap.hasData) {
            if (snap.hasData) {
              List<Post2> posts = ((snap.data as Map<String, dynamic>)['posts']
                      as List)
                  .where((element) => !((element as Post2).flags['deleted']))
                  .toList();
              CarouselController controller = CarouselController();
              return CarouselSlider.builder(
                carouselController: controller,
                options: CarouselOptions(
                    enableInfiniteScroll: animateCarousels,
                    autoPlay: animateCarousels,
                    height: (400)),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    child: carouselCard(context, (posts[index]),
                        index: index, posts: posts),
                    padding: EdgeInsets.only(right: 25),
                  );
                },
              );
            } else {
              return Icon(FontAwesomeIcons.ban);
            }
          } else {
            return GFLoader();
          }
        });
  }

  Widget DiscussedCarousel(BuildContext context) {
    return FutureBuilder(
        future: getPosts2(context,
            tag: 'order:comment',
            token: token,
            auth:
                Options(headers: {'authorization': accountTable['basicAuth']})),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done || snap.hasData) {
            if (snap.hasData) {
              List<Post2> posts = ((snap.data as Map<String, dynamic>)['posts']
                      as List)
                  .where((element) => !((element as Post2).flags['deleted']))
                  .toList();
              CarouselController controller = CarouselController();
              return CarouselSlider.builder(
                carouselController: controller,
                options: CarouselOptions(
                    enableInfiniteScroll: animateCarousels,
                    autoPlay: animateCarousels,
                    height: 400),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    child: carouselCard(context, (posts[index]),
                        index: index, posts: posts),
                    padding: EdgeInsets.only(right: 25),
                  );
                },
              );
            } else {
              return Icon(FontAwesomeIcons.ban);
            }
          } else {
            return GFLoader();
          }
        });
  }

  Widget carouselHopper(BuildContext context, TickerProvider sync) {
    List<Tab> tabs = [
      Tab(text: 'Trending'),
      Tab(
        text: 'Top Ranked',
      ),
      Tab(
        text: 'New in',
      )
    ];
    List<Widget> tabViews = [
      TrendingCarousel(context),
      RankCarousel(context),
      RecentCarousel(context)
    ];
    if (loggedIn()) {
      tabs.add(Tab(
        text: 'Most Discussed',
      ));
      tabViews.add(DiscussedCarousel(context));
    }
    TabController tcont =
        TabController(length: tabViews.length, vsync: sync, initialIndex: 0);
    return Container(
      child: Column(
        children: [
          TabBar(
              controller: tcont,
              labelColor: Colors.amber,
              isScrollable: true,
              indicator: PointTabIndicator(
                position: PointTabIndicatorPosition.bottom,
                color: Colors.amber,
                insets: EdgeInsets.only(bottom: 8),
              ),
              onTap: (index) {
                initialIndex = index;
              },
              tabs: tabs),
          Container(
            child: TabBarView(
              controller: tcont,
              children: tabViews,
            ),
            height: 400,
          )
        ],
      ),
    );
  }

  Widget leadIcon() {
    return (loggedIn())
        ? FutureBuilder(
            future:
                getCommentProfilePic(accountTable['user'], accountTable['id']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return (snapshot.hasData)
                    ? GestureDetector(
                        child: Padding(
                            child: GFAvatar(
                              backgroundImage: AdvancedNetworkImage(
                                  (snapshot.data as Post2).sampleUrl),
//                              radius: 25,
//                              size: 30,
                              shape: GFAvatarShape.circle,
                            ),
                            padding: EdgeInsets.only(
                              right: 20,
                            )),
                        onTap: () {
                          Get.to(
                            accountManager(),
                          );
                        },
                      )
                    : GFAvatar(
                        child: Text((accountTable['user'] as String)
                            .substring(0, 1)
                            .toUpperCase()),
                      );
              } else {
                return Padding(
                  child: GFLoader(),
                  padding: EdgeInsets.only(right: 10),
                );
              }
            })
        : Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber,
            ),
            child: IconButton(
              icon: Icon(
                FontAwesomeIcons.user,
                color: Colors.black,
              ),
              onPressed: () {
                Get.to(
                  accountManager(),
                );
              },
            ));
  }

  Widget ReccomendedScroller(BuildContext context) {
    targetTags = [];
    genTags = [];
    List<T> intersection<T>(Iterable<T> a, Iterable<T> b) {
      final s = b.toSet();
      return a.toSet().where((x) => s.contains(x)).toList();
    }

    List<String> viableFavs = globals.favoritesCache.keys
        .where((element) =>
            theGreatFilter2(jsonToPost2(globals.favoritesCache[element])))
        .toList()
        .toList();
    if (viableFavs.length >= 3) {
      List<Post2> recentFavs = [];
      List<String> keyPool;
      if (viableFavs.length >= 50) {
        keyPool =
            (viableFavs.getRange(viableFavs.length - 50, viableFavs.length))
                .toList();
      } else {
        keyPool = viableFavs;
      }
      for (String key in keyPool) {
        recentFavs.add(jsonToPost2(globals.favoritesCache[key]));
      }
      for (Post2 fav in recentFavs) {
        if ((fav.tags['artist'] as List).isNotEmpty) {
          targetTags.add(((fav.tags['artist'] as List)..shuffle()).first);
        }
        if ((fav.tags['species'] as List).isNotEmpty) {
          targetTags.add(((fav.tags['species'] as List)..shuffle()).first);
        }
        if ((fav.tags['character'] as List).isNotEmpty) {
          targetTags.add(((fav.tags['character'] as List)..shuffle()).first);
        }
        if ((fav.tags['copyright'] as List).isNotEmpty) {
          targetTags.add(((fav.tags['copyright'] as List)..shuffle()).first);
        }
        if ((fav.tags['general'] as List).isNotEmpty) {
          if (genTags.isEmpty) {
            genTags = intersection(genTags, (fav.tags['general'] as List));
          } else {
            genTags.addAll((fav.tags['general'] as List));
          }
          genTags.remove('anthro');
          genTags.remove('fur');
        }
      }
      if (genTags.isNotEmpty) {
        var map = Map();

        for (var x in genTags) {
          map[x] = (map[x] ?? 0) + 1;
        }

        var sortedKeys = map.keys.toList(growable: false)
          ..sort((k1, k2) => map[k1].compareTo(map[k2]));

        List<String> genTagShort = [];
        if (sortedKeys.length >= 5) {
          genTagShort
              .addAll(sortedKeys.reversed.toList().getRange(0, 5).cast());
        } else {
          genTagShort.addAll(sortedKeys.reversed
              .toList()
              .getRange(0, sortedKeys.length - 1)
              .cast());
        }

        log('GEN: ' + genTagShort.toString());
        genTags = genTagShort;
      }
    } else {
      return GFCard(
        content: Text(
          'Once you have at least 3 favorites, Your recomendations will be displayed here!',
          textAlign: TextAlign.justify,
        ),
        title: GFListTile(
          titleText: 'Nothing to show you just yet',
          avatar: Icon(
            FontAwesomeIcons.atom,
            color: Colors.amber,
          ),
          color: Colors.white,
        ),
      );
    }
    if (targetTags.length > 10) {
      List<String> chosen = ((targetTags.toSet().toList())..shuffle()).toList();
      targetTags = chosen;
    }
    if (genTags.isNotEmpty) {
      targetTags.addAll(genTags.cast());
    }
    targetTags = targetTags..shuffle();
    Map<int, int> currentlyOwnedPosts = {};
    Map<int, Post2> idToPost = {};
    bool postOwned(int index, Post2 post) {
      if (currentlyOwnedPosts[post.id] != null) {
        return (currentlyOwnedPosts[post.id] != index);
      }
      return false;
    }

    ownSet(int index, Post2 post) {
      currentlyOwnedPosts[post.id] = index;
      idToPost[index] = post;
    }

    CarouselController controller = CarouselController();

    return CarouselSlider.builder(
        carouselController: controller,
        options: CarouselOptions(
            enableInfiniteScroll: animateCarousels,
            autoPlay: animateCarousels,
            height: 200),
        itemCount: (targetTags.length > 25) ? 25 : targetTags.length,
        itemBuilder: (context, index) {
          String tag = targetTags[index];
          if (futures.length - 1 < index) {
            futures[index] = getPosts2(context, tag: tag, token: token);
          }
          return FutureBuilder(
              future: futures[index],
              builder: (fcontext, snap) {
                if (snap.connectionState != ConnectionState.done ||
                    !snap.hasData) {
                  return Padding(
                    child: GFCard(
                      content: Wrap(
                        children: [
                          Text(
                            'Ranking...',
                            textAlign: TextAlign.center,
                          ),
                          GFLoader(
                            type: GFLoaderType.square,
                            loaderColorOne: Colors.amber,
                            loaderColorTwo: Colors.blue,
                            loaderColorThree: Colors.deepOrange,
                          ),
                        ],
                        direction: Axis.vertical,
                      ),
                      title: GFListTile(
                        titleText: 'Recomended Tag: ' + tag.toString(),
                        avatar: Icon(
                          FontAwesomeIcons.atom,
                          color: Colors.blue,
                        ),
                        color: Colors.white,
                      ),
                    ),
                    padding: EdgeInsets.only(right: 0),
                  );
                } else {
                  bool anyPosts = (snap.data['posts'] as List).isNotEmpty;
                  Post2 post = Post2();
                  if (idToPost[index] == null) {
                    if (anyPosts) {
                      List<Post2> targets =
                          (snap.data['posts'] as List).where((element) {
                        return ((!globals.favoritesCache.containsKey(
                                        (element as Post2).id.toString())) &&
                                    !(element as Post2).flags['deleted'] ||
                                (element as Post2).flags['flagged']) &&
                            !postOwned(index, element as Post2);
                      }).toList();
                      if (targets.isEmpty) {
                        targets = (snap.data['posts'] as List).where((element) {
                          return ((!(element as Post2).flags['deleted'] ||
                                  (element as Post2).flags['flagged']) &&
                              !postOwned(index, element as Post2));
                        }).toList();
                      }
                      if (targets.isNotEmpty) {
                        post = (targets).first;
                      } else {
                        post = jsonToPost2(globals.favoritesCache[(globals
                                .favoritesCache.keys
                                .toList()
                                  ..shuffle())
                            .toList()
                            .firstWhere((element) =>
                                theGreatFilter2(jsonToPost2(
                                    globals.favoritesCache[element])) &&
                                !postOwned(
                                    index,
                                    jsonToPost2(
                                        globals.favoritesCache[element])))]);
                      }
                      ownSet(index, post);
                    }
                  } else {
                    post = idToPost[index];

                    ownSet(index, post);
                  }
                  return (post.fileMd5 != null)
                      ? Padding(
                          child: carouselCard(context, post, index: index),
                          padding: EdgeInsets.only(right: 25),
                        )
                      : Container();
                }
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: key,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Padding(
              child: Text(
                'Home',
                style: GoogleFonts.roboto(fontSize: 30, color: Colors.white),
              ),
              padding: EdgeInsets.only(top: 20, bottom: 20, right: 5, left: 18),
            ),
            actions: <Widget>[leadIcon()],
            backgroundColor: Colors.transparent,
          ),
          SliverToBoxAdapter(
            child: carouselHopper(context, this),
          ),
          SliverToBoxAdapter(
            child: Padding(
              child: Row(
                children: [
                  AutoSizeText('Your Recomendations',
                      style: GoogleFonts.lexendDeca(
                        fontSize: 20,
                      )),
                  Container(
                    child: IconButton(
                      icon: Icon(FontAwesomeIcons.infoCircle),
                      onPressed: () {
                        void _showDialog(
                            {bool info = true,
                            String title = "How Recomendations Work",
                            String content =
                                "Your recommendations are based on your most recent 10 favorites. The tags in those posts are compared to the most recent 320 posts. The top 10 with the highest correlation to your recent 10 favorites are then displayed here. All Processing is handled on your device and is secure."}) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String tags = '';
                              int count = 1;
                              for (String tag in targetTags) {
                                tags += count.toString() + ': ' + tag + '\n';
                                count += 1;
                              }
                              return AlertDialog(
                                scrollable: true,
                                title: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  content,
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.justify,
                                ),
                                actions: <Widget>[
                                  (info)
                                      ? FlatButton(
                                          child: Text("Tags Considered"),
                                          onPressed: () {
                                            _showDialog(
                                                info: false,
                                                title: 'Tags Considered',
                                                content: tags);
                                          },
                                        )
                                      : null,
                                  FlatButton(
                                    child: Text("Close"),
                                    onPressed: () {
                                      Get.back();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }

                        _showDialog();
                      },
                    ),
                    alignment: Alignment.centerRight,
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              padding: EdgeInsets.only(left: 20, top: 15, bottom: 10),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: ReccomendedScroller(context),
              padding: EdgeInsets.only(bottom: 50),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => false;
}
