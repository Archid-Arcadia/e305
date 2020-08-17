import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:e305/fancyTime.dart';
import 'package:e305/getPool.dart';
import 'package:e305/mediaManager.dart';
import 'package:e305/poolBrowseExperimental.dart';
import 'package:e305/poolDefenition.dart';
import 'package:e305/postDefinition.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:e305/themeData.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:getflutter/getflutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pagination_view/pagination_view.dart';

import 'globals.dart' as globals;

Map<String, Future> thumbnails;

class PoolPage extends StatefulWidget {
  final String query;

  PoolPage({this.query = ''});

  @override
  State<StatefulWidget> createState() {
    return _poolSearch(query);
  }
}

class _poolSearch extends State<PoolPage>
    with AutomaticKeepAliveClientMixin<PoolPage> {
  //Ads ads;
  String query;
  int page = 0;

  bool popToHome = true;

  int previousPoolsCount = 0;
  ScrollController _scrollController;
  double previousPos = 0.0;
  List<Pool2> pools = [];

  final controller = TextEditingController();
  final GlobalKey<ScaffoldState> persistKey = GlobalKey<ScaffoldState>();
  final GlobalKey listViewKey = GlobalKey();
  CancelToken token;

  _poolSearch(this.query);

  @override
  void dispose() {
    //ads.dispose();
    token.cancel('page disposed');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    globals.pageNumber += 1;
    super.initState();

    previousPoolsCount = 0;
    _scrollController = ScrollController();
    previousPos = 0.0;
    pools = [];
    thumbnails = {};
    token = CancelToken();
    _scrollController.addListener(() async {
//      print(_scrollController.position.maxScrollExtent.toString() +
//          ' : ' +
//          _scrollController.position.pixels.toString());
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          mounted) {
        print('reloading poolMain');
        setState(() {});
        await Future.delayed(Duration(seconds: 2));
      }
    });
  }

  @override
  bool get wantKeepAlive => false;

  String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}...';
  }

//  @override
//  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //controller.text = query;
    //page = globals.pageNumber;
    controller.text = query;
    //String title = 'Pools: ' + controller.text;
    return (Scaffold(
        key: persistKey,
        appBar: GFAppBar(
          //title: Text(title),
          searchBar: true,
          searchController: controller,
          onSubmitted: (query) {
            Get.to(PoolPage(query: query));
          },
          searchHintText: 'Enter pool Title',
          title: Text(
            (query == null || query.isEmpty)
                ? 'Recent Pools'
                : 'Pool Search: ' + query.toString(),
            style: TextStyle(fontSize: 14),
          ),
        ),
        body: gradientBackground(
          context,
          child: PaginationView<Pool2>(
            paginationViewType: PaginationViewType.listView,
            itemBuilder: (BuildContext context, Pool2 pool, int position) {
              bool holdLoad = false;
              return Container(
                  child: InkWell(
                child: GFCard(
                  buttonBar: GFButtonBar(
                    alignment: WrapAlignment.start,
                    children: [
                      GFIconButton(
                          icon: Icon(FontAwesomeIcons.book),
                          onPressed: () async {
                            int previousPostCount = 0;
                            List<Post2> posts = [];
                            List<int> postIds = [];
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
                                        reason: true, blacklist: true)) {
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
                            if (posts.length != pool.post_count) {
                              Get.snackbar(
                                'Images Skipped',
                                '${posts.length}/${pool.post_count} posts loaded.',
                                icon: Icon(
                                  FontAwesomeIcons.exclamationTriangle,
                                  color: Colors.amber,
                                ),
                              );
                            }
                            galleryLRScroll(context, posts,
                                currentIndex: 0, loop: false, replace: false);
                          }),
                    ],
                  ),
                  margin: EdgeInsets.all(4),
                  title: GFListTile(
                    padding: EdgeInsets.all(2),
                    margin: EdgeInsets.all(4),
                    title: AutoSizeText(
                      'Pool: ' + pool.name,
                      style: getPanacheTheme().textTheme.bodyText2,
                      maxLines: 2,
                    ),
                    subTitle: AutoSizeText(
                      "Posts: " +
                          pool.post_count.toString() +
                          '\r\n' +
                          "Updated: " +
                          fancyTimeDifferenceFromString(
                              context, pool.updated_at),
                      style: getPanacheTheme().textTheme.subtitle2,
                      maxLines: 2,
                    ),
//                    description: Text(
//                      'Description: ' +
//                          truncateWithEllipsis(140, pool.description)
//                              .replaceAll('\n', ' ')
//                              .replaceAll('\r', ' '),
//                      style: TextStyle(fontSize: 9),
//                    ),
                  ),
                  content: Container(
                    child: FutureBuilder(
                        future: poolThumbnail(pool),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return snapshot.data['Widget'];
                          } else {
                            return Container(
                                child: GFLoader(),
                                height: highRes() ? 350 : 150);
                          }
                        }),
                  ),
                ),
                onTap: () async {
                  await Get.to(PoolBrowseExp(pool));
                },
              ));
            },
            pageFetch: (int pagex) {
              page += 1;
              print('Pool Retrieve page: ${page}');
              bool getting = true;
              Future<List<Pool2>> results;
              while (getting) {
                getting = false;
                try {
                  results = getPoolV2(context,
                      query: controller.text,
                      page: page,
                      limit: 25,
                      priority: 1,
                      refresh: false,
                      overrideSpamGaurd: false,
                      token: token);
                } on DioError {
                  getting = true;
                }
              }
              return results;
            },
            onError: (dynamic error) {
              //restart();
              return Center(
                  child: Text(
                      'Some error occured: ${(error as DioError).response.statusCode.toString()}'));
            },
            onEmpty: Center(
              child: AutoSizeText("Sorry! There's nothing here."),
            ),
            bottomLoader: Center(
              child: CircularProgressIndicator(),
            ),
            initialLoader: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        )));
  }

  Widget textBox(TextEditingController controller) {
    return Row(
        //padding: const EdgeInsets.only(top: 0, bottom: 30.0, left: 5, right: 5),
        children: <Widget>[
          Text("Pool: "),
          Expanded(
              child: TextField(
                  controller: controller,
                  onSubmitted: (data) {
                    Get.to(PoolPage(query: controller.text));
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Pool Title",
//            border: OutlineInputBorder(
//              borderRadius: BorderRadius.circular(25.0),
//              borderSide: BorderSide(),
//            ),
                    //fillColor: Colors.green
                  ),
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.lexendDeca())),
        ]);
  }
}
