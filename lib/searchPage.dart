//import 'package:ads/ads.dart';
//import 'package:autocomplete_textfield/autocomplete_textfield.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dio/dio.dart';
import 'package:e305/themeData.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preferences/preference_service.dart';
import 'package:preferences/preferences.dart';

import 'getPosts.dart';
import 'globals.dart' as globals;
import 'postDefinition.dart';

String lastQuery = '';

class SearchPage extends StatefulWidget {
  final String initTag;
  final bool popToHome;
  final bool replace;
  final Key key;

  //MyCustomForm({Key key}) : super(key: key));
  SearchPage(this.initTag, this.key,
      {this.popToHome = true, this.replace = false});

  @override
  _SearchPageState createState() =>
      _SearchPageState(initTag, 0, popToHome: popToHome, replace: replace);
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  String tag;
  final GlobalKey pageKey = GlobalKey();
  final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final GlobalKey<AutoCompleteTextFieldState<String>> searchKey = GlobalKey();
  final bool replace;
  final CancelToken token = CancelToken();

  int page = 0;
  bool holdLoad = false;
  bool popToHome = true;

  int previousPostCount = 0;
  ScrollController _scrollController = ScrollController();
  double previousPos = 0.0;
  List<Post2> posts = [];

  _SearchPageState(this.tag, this.page,
      {this.popToHome = true, this.replace = false});

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    lastQuery = tag;
    if (tag == null) {
      tag = '';
    }
    TextEditingController searchControl = TextEditingController(text: tag);
    return (OrientationBuilder(builder: (context, orientation) {
      int crossAxisCountVar = orientation == Orientation.portrait ? 6 : 12;
      int crossAxisCountVarFit = orientation == Orientation.portrait ? 3 : 3;
      return Scaffold(
          key: key,
          body: gradientBackground(
            context,
            child: CustomScrollView(controller: _scrollController, slivers: <
                Widget>[
              SliverAppBar(
                pinned: false,
                snap: false,
                floating: true,
                title: AutoCompleteTextField(
                  //initialText: tag,
                  key: searchKey,
                  controller: searchControl,
                  suggestions: globals.tags +
                      [
                        'date:day',
                        'date:week',
                        'date:month',
                        'date:decade',
                        'type:jpg',
                        'type:png',
                        'type:gif',
                        'type:webm',
                        'order:id',
                        'order:score',
                        'order:favcount',
                        'order:tagcount',
                        'order:desclength',
                        'order:comments',
                        'order:mpixels',
                        'order:filesize',
                        'order:landscape',
                        'order:random',
                        'order:score_asc',
                        'order:favcount_asc',
                        'order:tagcount_asc',
                        'order:desclength_asc',
                        'order:comments_asc',
                        'order:mpixels_asc',
                        'order:filesize_asc',
                        'order:portrait'
                      ],

                  textSubmitted: (text) {
                    FocusScope.of(context).unfocus();
                    Get.to(SearchPage(
                      text,
                      globals.postPageKey,
                      replace: replace,
                    ));
                  },
                  itemBuilder: (context, item) {
                    return Container(
                      color: getPanacheTheme().bottomAppBarColor,
                      padding: const EdgeInsets.all(8),
                      child: (item != null)
                          ? AutoSizeText(
                              item,
                              style:
                                  getPanacheTheme().primaryTextTheme.subtitle2,
                            )
                          : Container(),
                    );
                  },
                  itemFilter: (item, query) {
                    if (query.contains(' ')) {
                      String last = query.split(' ').last;
                      return item.toLowerCase().startsWith(last.toLowerCase());
                    }
                    return item.toLowerCase().startsWith(query.toLowerCase());
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      //helperText: ,
                      hintText: "Enter a tag"),
                  itemSubmitted: (newTag) {
                    if (!globals.tags.contains(newTag)) {
                      globals.tags.add(newTag);
                    }
                    Get.to(
                      SearchPage(
                        newTag,
                        globals.postPageKey,
                        replace: replace,
                      ),
                    );
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(FontAwesomeIcons.save),
                    onPressed: () {
                      if (!globals.follows.contains(tag)) {
                        try {
                          Get.snackbar(
                              "Saved! ", "Saved Search: " + tag.toString(),
                              icon: Icon(FontAwesomeIcons.solidSave));
                        } on NoSuchMethodError {
                          log('Snackbar Error');
                        }
                        globals.follows.add(tag);
                        globals.saveFollowList();
                      }
                    },
                  )
                ],
              ),
              (((PrefService.getBool('suggestBar') != null &&
                      PrefService.getBool('suggestBar') == true)))
                  ? FutureBuilder(
                      future: suggestionBar(context, tag, posts),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return snapshot.data;
                        } else {
                          return SliverToBoxAdapter(child: Container());
                        }
                      })
                  : SliverToBoxAdapter(child: Container()),
//              SliverToBoxAdapter(
//                  child: bannerAd(context, size: AdmobBannerSize.BANNER)),
              AnimatedContainer(
                duration: Duration(seconds: 1),
                child: FutureBuilder(
                  future: getPosts2(context,
                      tag: tag + ' -type:swf',
                      page: page,
                      previousPostCount: previousPostCount,
                      holdLoad: holdLoad,
                      posts: posts,
                      refresh: true,
                      token: token),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      var data = {
                        'posts': posts,
                        'page': page,
                        'holdLoad': holdLoad,
                        'previousPostCount': previousPostCount,
                      };
                      if (snapshot.data != null) {
                        data = snapshot.data;
                      }
                      posts = data['posts'];
                      holdLoad = data['holdLoad'];
                      page = data['page'];
                      previousPostCount = posts.length;
                      globals.lastResults = posts;
                      log('Connection: Done');

                      if (snapshot.hasData &&
                          snapshot.data['posts'].length != 0) {
                        return SliverStaggeredGrid.countBuilder(
                          key: PageStorageKey(0),
                          itemCount: posts.length,
                          crossAxisCount: crossAxisCountVar,
                          itemBuilder: (BuildContext context, int index) {
                            return GridPostCardWidget(
                                context, posts, index, replace);
                          },
                          staggeredTileBuilder: (int index) =>
                              StaggeredTile.fit(crossAxisCountVarFit),
                        );
                      } else {
                        var colorResponses = [
                          "Sure is dark... and empty",
                          "try a different tag, nothing but the void around here",
                          "Enjoy the emptiness, there's nothing here. Very zen."
                        ];
                        return SliverFillRemaining(
                          child: Center(
                            child: Card(
                              child: Text(
                                (colorResponses..shuffle()).first,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lexendDeca(fontSize: 15),
                              ),
                            ),
                          ),
                        );
                      }
                    } else {
                      try {
                        return SliverStaggeredGrid.countBuilder(
                          key: PageStorageKey(0),
                          itemCount: posts.length,
                          crossAxisCount: crossAxisCountVar,
                          itemBuilder: (BuildContext context, int index) {
                            return GridPostCardWidget(
                                context, posts, index, replace,
                                icon: FontAwesomeIcons.syncAlt);
                          },
                          staggeredTileBuilder: (int index) =>
                              StaggeredTile.fit(crossAxisCountVarFit),
                        );
                      } on NoSuchMethodError {
                        return SliverFillRemaining(child: Text("Waiting"));
                      }
                    }
                  },
                ),
              ),
              //SliverToBoxAdapter(child: bannerAd(context)),
              SliverToBoxAdapter(
                  child: Container(
                height: kBottomNavigationBarHeight,
              ))
            ]),
          ));
    }));
  }

  @override
  void dispose() {
    token.cancel('Page is disposed');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    globals.pageNumber += 1;
    super.initState();
    page = 0;
    //searchKey = GlobalKey();
    holdLoad = false;
    previousPostCount = 0;
    _scrollController = ScrollController();
    previousPos = 0.0;
    posts = [];
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !holdLoad) {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }
}
