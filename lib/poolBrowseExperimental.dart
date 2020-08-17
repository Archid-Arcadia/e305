import 'dart:async';
import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:e305/getPool.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/mediaManager.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:e305/themeData.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:getflutter/components/button/gf_button.dart';
import 'package:getflutter/components/button/gf_icon_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedantic/pedantic.dart';
import 'package:url_launcher/url_launcher.dart';

import 'globals.dart' as globals;
import 'poolDefenition.dart';
import 'postDefinition.dart';

class PoolBrowseExp extends StatefulWidget {
  final Pool2 pool;

  PoolBrowseExp(this.pool);

  @override
  _PoolBrowserState createState() => _PoolBrowserState(pool);
}

class _PoolBrowserState extends State<PoolBrowseExp> {
  int page = 0;
  Pool2 pool;
  bool load;
  bool holdLoad = false;
  int previousPostCount = 0;
  ScrollController _scrollController = ScrollController();
  double previousPos = 0.0;
  List<Post2> posts = [];
  List<int> postIds = [];
  Future blocked;
  Future descriptGet;
  Future popPool;
  final key = GlobalKey<ScaffoldState>();
  String descriptor = 'Fetching description';
  String blocks = [].toString();
  bool useBlackList = true;

  Future<Pool2> fakePagination(Pool2 pool, int page,
      {int totalPerPage = 5}) async {
    int max = pool.post_count;
    int suggestedRangeMin = posts.length;
    if (posts.length - 1 < 0) {
      suggestedRangeMin = 0;
    }
    log(posts.length, analytics: false);
    int suggestedRangeMax = suggestedRangeMin + totalPerPage;
    if (suggestedRangeMax > max) {
      suggestedRangeMax = max;
    }
    log(
        'Pool Range: ' +
            suggestedRangeMin.toString() +
            '/' +
            suggestedRangeMax.toString() +
            ' | ' +
            max.toString(),
        type: 'Pool Comic Preloader');
    if (suggestedRangeMin > suggestedRangeMax ||
        suggestedRangeMin == suggestedRangeMax) {
      pool.posts = [];
    } else {
      List<dynamic> targets = (pool.post_ids)
          .getRange(suggestedRangeMin, suggestedRangeMax)
          .toList();
      List<Post2> postsOfRange = [];
      for (int target in targets) {
        postsOfRange.add(await getPostByID2(context, target));
      }
      pool.posts = (postsOfRange);
    }
    previousPostCount += pool.posts.length;
    return pool;
  }

  Future<bool> descriptionUpdater() async {
    String startdescriptor = 'Fetching description';
    while (descriptor == startdescriptor) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    return true;
  }

  Future<bool> blockedUpdater() async {
    String startdescriptor = [].toString();
    while (faults.toString() == startdescriptor) {
      if (postIds.isNotEmpty) {
        return false;
      }
      await Future.delayed(Duration(seconds: 1));
    }
    blocks = (faults).length.toString() +
        ' posts blocked due to blacklist, offence(s): ' +
        faults.toSet().toString().replaceAll('{', '').replaceAll('}', '');
    return true;
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
    popPool = populatePoolExperiment(pool.id, filter: false);
    _scrollController = ScrollController();
    previousPos = 0.0;
    blocked = blockedUpdater();
    descriptGet = descriptionUpdater();
    posts = [];
    postIds = [];
    _scrollController.addListener(() {});
  }

  _PoolBrowserState(this.pool);

  @override
  Widget build(BuildContext context) {
    globals.pageNumber += 1;
    log('Pool ID: ' + pool.id.toString(), type: 'Opened_Pool');
    return OrientationBuilder(builder: (context, orientation) {
      int crossAxisCountVar = orientation == Orientation.portrait ? 6 : 12;
      int crossAxisCountVarFit = orientation == Orientation.portrait ? 3 : 3;
      return LayoutBuilder(builder: (context, constraint) {
        return mindTheTop(
            context,
            mindTheBottom(
              context,
              (Scaffold(
                key: key,
                body: gradientBackground(
                  context,
                  child:
                      CustomScrollView(controller: _scrollController, slivers: <
                          Widget>[
                    SliverAppBar(
                      pinned: false,
                      snap: false,
                      floating: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: AutoSizeText(
                          pool.name,
                          maxLines: 1,
                          maxFontSize: 20,
                          minFontSize: 9,
                          style: GoogleFonts.lexendDeca(fontSize: 12),
                        ),
                      ),
                      actions: <Widget>[
                        Padding(
                          child: GFIconButton(
                              icon: Icon(FontAwesomeIcons.book),
                              onPressed: () async {
                                Pool2 tempPool;
                                if (holdLoad != true) {
                                  if ((pool.post_count - posts.length) > 65) {
                                    try {
                                      Get.snackbar(
                                        'Pool Loader',
                                        "[Large Pool Warning]: This will take a moment...",
                                        icon: Icon(
                                          FontAwesomeIcons.swimmingPool,
                                          color: Colors.blueAccent,
                                        ),
                                        duration: Duration(seconds: 5),
                                      );
                                    } on NoSuchMethodError {
                                      log('Snackbar Error');
                                    }
                                  } else {
                                    try {
                                      Get.snackbar(
                                        'Pool Loader',
                                        "Loading...",
                                        icon: Icon(
                                          FontAwesomeIcons.swimmingPool,
                                          color: Colors.blueAccent,
                                        ),
                                        duration: Duration(seconds: 1),
                                      );
                                    } on NoSuchMethodError {
                                      log('Snackbar Error');
                                    }
                                  }
                                  pool.posts = posts;
                                  while (!holdLoad &&
                                      previousPostCount < pool.post_count) {
                                    tempPool =
                                        await populatePoolExperiment(pool.id);
                                    if (tempPool.posts.isNotEmpty) {
                                      pool = tempPool;
                                      page += 1;
                                      holdLoad = true;
                                    } else {
                                      log('Empty pool at: ' + page.toString(),
                                          type: 'Empty Pool');
                                      holdLoad = true;
                                    }
                                    for (Post2 post in pool.posts) {
                                      if (!postIds.contains(post.id)) {
                                        postIds.add(post.id);
                                        if (theGreatFilter2(post,
                                            reason: true,
                                            blacklist: useBlackList)) {
                                          posts.add(post);
                                        }
                                        log(post.id.toString() + ' : Approved',
                                            analytics: false);
                                      } else {
                                        log(post.id.toString() + ' : Rejected',
                                            analytics: false);
                                      }
                                    }
                                  }
                                }
                                galleryLRScroll(context, posts,
                                    currentIndex: 0,
                                    loop: false,
                                    replace: false);
                              }),
                          padding: EdgeInsets.only(right: 5),
                        )
                      ],
                    ),
                    SliverToBoxAdapter(
                        child: Container(
                            child: Center(
                                child: FutureBuilder(
                                    future: descriptionUpdater(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      Future<void> _onOpen(
                                          LinkableElement link) async {
                                        if (await canLaunch(link.url)) {
                                          // set up the button
                                          Widget okButton = FlatButton(
                                            child: Text("Go for it"),
                                            onPressed: () async {
                                              Get.back();
                                              await launch(link.url);
                                            },
                                          );
                                          Widget cancelButton = FlatButton(
                                            child: Text("Abort"),
                                            onPressed: () {
                                              Get.back();
                                            },
                                          );
                                          // set up the AlertDialog
                                          AlertDialog alert = AlertDialog(
                                            title: Text("Links are scary!"),
                                            content: Text(
                                                "Are you sure you want to open: " +
                                                    link.url +
                                                    " ?"),
                                            actions: [
                                              cancelButton,
                                              okButton,
                                            ],
                                          );
                                          // show the dialog
                                          unawaited(showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return alert;
                                            },
                                          ));
                                        } else {
                                          throw 'Could not launch $link';
                                        }
                                      }

                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return Linkify(
                                          text: descriptor,
                                          style: GoogleFonts.lexendDeca(
                                              fontSize: 15),
                                          onOpen: _onOpen,
                                        );
                                      } else {
                                        return Text(descriptor,
                                            style: GoogleFonts.lexendDeca(
                                                fontSize: 15));
                                      }
                                    })))),
                    SliverToBoxAdapter(
                        child: Container(
                            child: Center(
                                child: FutureBuilder(
                                    future: blocked,
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      if ((snapshot.connectionState ==
                                              ConnectionState.done) &&
                                          snapshot.data) {
                                        return Column(children: [
                                          AutoSizeText(
                                            blocks,
                                            style: GoogleFonts.lexendDeca(
                                                fontSize: 15,
                                                color: Colors.red),
                                          ),
                                          GFButton(
                                            text:
                                                'Temporarily Disable Blacklist?',
                                            onPressed: () {
                                              useBlackList = false;
                                              setState(() {
                                                blocked = Future(() => false);
                                                blocks = [].toString();
                                                page = 0;
                                                holdLoad = false;
                                                previousPostCount = 0;
                                                previousPos = 0.0;
                                                posts = [];
                                                postIds = [];
                                              });
                                            },
                                          )
                                        ]);
                                      } else {
                                        return Container();
                                      }
                                    })))),
                    FutureBuilder(
                      future: popPool,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data.posts.isNotEmpty) {
                            pool = snapshot.data;
                            holdLoad = true;
                            page += 1;
                          } else {
                            log('Empty pool at: ' + page.toString(),
                                type: 'Empty Pool Alert');
                            holdLoad = true;
                          }
                          if (descriptor != pool.description.toString()) {
                            descriptor = pool.description.toString();
                            log(descriptor, type: 'Pool_Description');
                          }
                          for (Post2 post in (snapshot.data as Pool2).posts) {
                            if (!postIds.contains(post.id)) {
                              postIds.add(post.id);
                              if (theGreatFilter2(post,
                                  reason: true, blacklist: useBlackList)) {
                                posts.add(post);
                              }
                              log(post.id.toString() + ' : Approved',
                                  analytics: false);
                            } else {
                              log(post.id.toString() + ' : Rejected',
                                  analytics: false);
                            }
                          }
                          return Container(
                              child: (posts.isNotEmpty)
                                  ? (SliverStaggeredGrid.countBuilder(
                                      key: PageStorageKey(0),
                                      itemCount: posts.length,
                                      crossAxisCount: crossAxisCountVar,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GridPostCardWidget(
                                            context, posts, index, false,
                                            ignoreFav: false);
                                      },
                                      staggeredTileBuilder: (int index) =>
                                          StaggeredTile.fit(
                                              crossAxisCountVarFit),
                                    ))
                                  : (SliverFillRemaining(
                                      child: Center(
                                        child: ListView(
                                            shrinkWrap: true,
                                            children: [
                                              Center(
                                                child: Text(
                                                  "This is an empty pool?? (Try Checking your Rating Settings or Blacklist Policy)",
                                                  style: GoogleFonts.lexendDeca(
                                                    color: Colors.blueGrey,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Center(
                                                  child: RaisedButton(
                                                color: getPanacheTheme()
                                                    .accentColor,
                                                onPressed: () {
                                                  launch(
                                                      'https://e621.net/pool/show/' +
                                                          pool.id.toString());
                                                },
                                                child: Text(
                                                    'Investigate on Site?'),
                                              ))
                                            ]),
                                      ),
                                    )));
                        } else if (posts.isNotEmpty) {
                          return Container(
                              child: (pool.posts.isNotEmpty)
                                  ? (SliverStaggeredGrid.countBuilder(
                                      key: PageStorageKey(0),
                                      itemCount: posts.length,
                                      crossAxisCount: crossAxisCountVar,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GridPostCardWidget(
                                            context, posts, index, false,
                                            ignoreFav: false);
                                      },
                                      staggeredTileBuilder: (int index) =>
                                          StaggeredTile.fit(
                                              crossAxisCountVarFit),
                                    ))
                                  : (SliverFillRemaining(
                                      child: Center(
                                        child: ListView(
                                            shrinkWrap: true,
                                            children: [
                                              Center(
                                                child: Text(
                                                  "This is an empty pool?? (Try Checking your Rating Settings or Blacklist Policy)",
                                                  style: GoogleFonts.lexendDeca(
                                                    color: Colors.blueGrey,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Center(
                                                  child: RaisedButton(
                                                color: getPanacheTheme()
                                                    .accentColor,
                                                onPressed: () {
                                                  launch(
                                                      'https://e621.net/pool/show/' +
                                                          pool.id.toString());
                                                },
                                                child: Text(
                                                    'Investigate on Site?'),
                                              ))
                                            ]),
                                      ),
                                    )));
                        } else {
                          return SliverToBoxAdapter(
                            child: Container(
                              child: Center(
                                child: AutoSizeText(
                                  (pool.post_count > 100)
                                      ? "Loading... (This is a big Pool, might be a bit)"
                                      : "Loading... ",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lexendDeca(fontSize: 30),
                                  minFontSize: 1,
                                  maxFontSize: 40,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SliverToBoxAdapter(
                        child: Container(
                      height: kBottomNavigationBarHeight,
                    ))
                  ]),
                ),
              )),
            ));
      });
    });
  }
}
