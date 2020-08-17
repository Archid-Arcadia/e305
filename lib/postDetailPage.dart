import 'dart:core';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:e305/commentDefinition.dart';
import 'package:e305/getPool.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/loginManager.dart';
import 'package:e305/networking.dart';
import 'package:e305/poolBrowseExperimental.dart';
import 'package:e305/poolDefenition.dart';
import 'package:e305/searchPage.dart';
import 'package:e305/tagBuilder.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:getflutter/components/button/gf_button.dart';
import 'package:getflutter/getflutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';
import 'package:url_launcher/url_launcher.dart';

import 'childrenView.dart';
import 'getComments.dart';
import 'globals.dart' as globals;
import 'mediaManager.dart';
import 'postDefinition.dart';
import 'save.dart';

TextEditingController controller = TextEditingController();

class PostDetail extends StatefulWidget {
  final Post2 post;
  final int index;
  final List<Post2> posts;
  final bool voteStale;

  PostDetail(this.post, {this.index = 0, this.posts, this.voteStale = false});

  @override
  _PostDetail createState() =>
      _PostDetail(post, this.index, this.posts, this.voteStale);
}

class _PostDetail extends State<PostDetail> {
  final Post2 post;
  final int index;
  final List<Post2> posts;
  final formKey = GlobalKey<FormState>();
  final CancelToken token = CancelToken();
  final voteStale;
  Widget commentWidget;

  int pageOwner = globals.pageNumber;

  //var comments = 'Comments Coming Soon';
  _PostDetail(this.post, this.index, this.posts, this.voteStale);

  @override
  void initState() {
    Future<List<Comment2>> textComments =
        getCommentsExperiment(post, token: token);
    //getCommentsExperiment(post);
    commentWidget = FutureBuilder(
        future: textComments,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (post.comment_count > 0 || snapshot.data.length > 0) {
              return ListView.builder(
                  primary: false,
                  padding: EdgeInsets.all(0),
                  shrinkWrap: true,
                  itemCount: (snapshot.data).length,
                  itemBuilder: (context, index) {
                    return singleCommentViewExperiment(
                        context, snapshot.data.reversed.toList()[index],
                        token: token);
                  });
              //Text(jsonDecode(snapshot.data)[0]['text']);
            } else if (snapshot.hasError) {
              log("${snapshot.error}", type: 'Comments_Error');
              return Center(
                  child: Expanded(
                      child: AutoSizeText(
                "Comments are disabled, sorry",
                minFontSize: 18,
              )));
            }
          }
          if (post.comment_count > 0) {
            return Center(
                child: AutoSizeText(
              "Retrieving Comments...",
              minFontSize: 18,
              maxFontSize: 30,
            ));
          }
          return Center(
              child: AutoSizeText(
            "No Comments yet",
            minFontSize: 18,
            maxFontSize: 30,
          ));
        });
    log(post, type: 'Opened_Post');
    super.initState();
  }

  @override
  void dispose() {
    if (!token.isCancelled) {
      token.cancel('Page is disposed');
      log('Disposed page', type: 'PostDetails_Closed');
    }

    super.dispose();
  }

  //PostDetail(this.post);

  //log(post.url('e621'));
  @override
  Widget build(BuildContext context) {
    Future<void> _onOpen(LinkableElement link) async {
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
          content: Text("Are you sure you want to open: " + link.url + " ?"),
          actions: [
            cancelButton,
            okButton,
          ],
        );
        // show the dialog
        unawaited(Get.dialog(alert));
      } else {
        throw 'Could not launch $link';
      }
    }

    Widget newComment(BuildContext context, int postID) {
      return loggedIn()
          ? GFCard(
              content: TextField(
                decoration: const InputDecoration(
                  icon: Icon(FontAwesomeIcons.comment),
                  hintText: 'Comment here',
                  labelText: 'New Comment',
                ),
                onSubmitted: (String value) async {
                  Uri target = Uri(
                      scheme: 'https',
                      host: 'e621.net',
                      path: '/comments.json',
                      queryParameters: stringify({
                        "comment[post_id]": postID.toString(),
                        "comment[body]": value.toString()
                      }));
                  var response;
                  try {
                    response =
                        await networkingPriority(refresh: false, token: token)
                            .post(target.toString(),
                                options: Options(headers: {
                                  'authorization': accountTable['basicAuth']
                                }));
                    print(response.data);
                    setState(() {
                      Future<List<Comment2>> textComments =
                          getCommentsExperiment(post, token: token);
                      //getCommentsExperiment(post);
                      commentWidget = FutureBuilder(
                          future: textComments,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (post.comment_count > 0 ||
                                  snapshot.data.length > 0) {
                                return ListView.builder(
                                    primary: false,
                                    padding: EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    itemCount: (snapshot.data).length,
                                    itemBuilder: (context, index) {
                                      return singleCommentViewExperiment(
                                          context,
                                          snapshot.data.reversed
                                              .toList()[index],
                                          token: token);
                                    });
                                //Text(jsonDecode(snapshot.data)[0]['text']);
                              } else if (snapshot.hasError) {
                                log("${snapshot.error}",
                                    type: 'Comments_Error');
                                return Center(
                                    child: Expanded(
                                        child: AutoSizeText(
                                  "Comments are disabled, sorry",
                                  minFontSize: 18,
                                )));
                              }
                            }
                            return Center(
                                child: AutoSizeText(
                              "No Comments yet",
                              minFontSize: 18,
                              maxFontSize: 30,
                            ));
                          });
                    });
                  } on DioError catch (e) {
                    log(e.error);
                  }
                },
              ),
            )
          : Container();
    }

    try {
      GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
      //getComments(post);
      var date = DateTime.parse(post.created_at);
      //bool pressAttention = false;
      if (post.tags['General'] != null) {
        post.tags['artist'] = post.tags['General'][0];
      }
      List<Widget> artistCards = [AutoSizeText("Artist:")];
      try {
        for (String artist in post.tags['artist']) {
          if (artist.toLowerCase() != 'conditional_dnp') {
            artistCards.add(
              (InkWell(
                onTap: () {
                  Get.to(
                    (SearchPage(artist, Key('Artist'))),
                  );
                },
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: Card(
                      shape: StadiumBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(0.0),
                        child: AutoSizeText(
                          artist,
                          style: GoogleFonts.roboto(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ),
                ),
              )),
            );
          }
        }
      } catch (e) {
        log('Artist build: ' + e);
        artistCards.add(Container());
      }
      List popUpItems = <PopupMenuItem<Widget>>[
        PopupMenuItem(
            child: ListTile(
          title: Text("Find Set with post"),
          leading: Icon(FontAwesomeIcons.binoculars),
          onTap: () async {
            await searchSetWithPost(context, post, key);
            try {
              Get.snackbar('Set Finder', "No Set Found",
                  icon: Icon(FontAwesomeIcons.binoculars),
                  duration: Duration(seconds: 2));
            } on NoSuchMethodError {
              log('Snackbar Error');
            }
          },
        )),
        PopupMenuItem(
            child: ListTile(
                title: Text("Find Pool"),
                leading: Icon(FontAwesomeIcons.water),
                onTap: () async {
                  Navigator.of(context).pop();
                  if (post.pools.isEmpty) {
                    await http
                        .read('https://e621.net/posts/' + post.id.toString())
                        .then((contents) async {
                      String body = contents.toString();
                      if (body.contains('?pool_id=')) {
                        String id = '';
                        id = body.split('?pool_id=')[1].split('">')[0];
                        log(id);
                        Pool2 pool = await populatePool(int.parse(id),
                            just1: true, token: CancelToken());
                        unawaited(Get.to(
                          PoolBrowseExp(pool),
                        ));
                      } else {
                        log('No Pool found');
                        try {
                          await Get.snackbar('Pool Finder', "No Pools Found",
                              icon: Icon(FontAwesomeIcons.swimmingPool),
                              duration: Duration(seconds: 2));
                        } on NoSuchMethodError {
                          log('Snackbar Error');
                        }
                      }
                    });
                  } else {
                    print('Pool Embedded');
                    Pool2 pool = await populatePool(post.pools[0],
                        just1: true, token: CancelToken());
                    unawaited(Get.to(
                      PoolBrowseExp(pool),
                    ));
                  }
                })),
        PopupMenuItem(
            child: ListTile(
          leading: Icon(FontAwesomeIcons.photoVideo),
          onTap: () async {
            await launch(post.fileUrl);
          },
          title: Text("Open File Url"),
        )),
        PopupMenuItem(
            child: ListTile(
          title: Text("Open e621 Page"),
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image(
                  image: AdvancedNetworkImage(
                      'https://e621.net/apple-touch-icon.png',
                      cacheRule: CacheRule(maxAge: const Duration(days: 7))))),
          onTap: () async {
            log('https://e621.net/post/show/' + post.id.toString());
            await launch('https://e621.net/post/show/' + post.id.toString());
          },
        )),
        PopupMenuItem(
            child: ListTile(
          leading: Icon(FontAwesomeIcons.info),
          onTap: () async {
            await Get.to(Scaffold(
              backgroundColor: Colors.white,
              appBar: GFAppBar(
                title: Text(
                  'Post ID# ' + post.id.toString(),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              body: SingleChildScrollView(
                  child: JsonViewerWidget(
                post.toJson(),
              )),
            ));
          },
          title: Text('View Raw Post Data'),
        )),
      ];
      return (gradientBackground(
        context,
        child: OrientationBuilder(builder: (context, orientation) {
          //log('post.hasChildren: ' + post.hasChildren.toString());

          if (orientation == Orientation.portrait) {
            return Scaffold(
              key: key,
              appBar: GFAppBar(
                title: textBox(context),
                actions: <Widget>[
                  PopupMenuButton(
                    icon: Icon(FontAwesomeIcons.ellipsisV),
                    //isExpanded: true,
                    onSelected: (choice) {},
                    itemBuilder: (BuildContext context) {
                      return popUpItems;
                    },
                  )
                ],
                backgroundColor: Colors.black54,
              ),
              body: Container(
                child: ListView(
                  children: <Widget>[
                    InkWell(
                      child: mediaBuilder(post, context),
                      onLongPress: () {
                        galleryLRScroll(
                            context, (posts != null) ? posts : [post],
                            currentIndex: this.index, replace: true);
                      },
                    ),
                    voting(context, post, stale: voteStale),
                    //recomendRating(context, ''),
                    tagger(post, context, pageOwner, token: token),
                    ExpandablePanel(
                      header: AutoSizeText("Description:",
                          style: GoogleFonts.roboto(fontSize: 20)),
                      collapsed: AutoSizeText(post.description.toString(),
                          maxLines: 2, style: GoogleFonts.roboto(fontSize: 15)),
                      expanded: AutoSizeText(
                          post.description.toString() +
                              '\r\n' +
                              "Poster: " +
                              post.uploader_id.toString() +
                              '\n\r' +
                              "Upload Date: " +
                              date.toString().split('.')[0] +
                              '\n\r' +
                              "Rating:" +
                              post.rating +
                              '\n\r' +
                              'File Type: ' +
                              post.fileExt,
                          style: GoogleFonts.roboto(fontSize: 15)),
                    ),
                    (((post.has_children != null) && post.has_children) ||
                            post.parent_id != null)
                        ? FutureBuilder(
                            future: childrenView(context, post, index,
                                token: token),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return (snapshot.data != null)
                                    ? snapshot.data
                                    : Container();
                              } else {
                                return GFLoader();
                              }
                            },
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: StatefulBuilder(
                        builder: (context, StateSetter setState) {
                          return GFButton(
                            onPressed: () async {
                              await save2(post, context);
                              setState(() {});
                              //Future.delayed(Duration(seconds: 2),
                            },
                            shape: GFButtonShape.pills,
                            textStyle: GoogleFonts.lexendDeca(),
                            color: Colors.deepOrange,
                            padding: const EdgeInsets.all(8.0),
                            text: ("Download"),
                          );
                        },
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: StatefulBuilder(
                            builder: (context, StateSetter setState) {
                          return GFButton(
                            shape: GFButtonShape.pills,
                            textStyle: GoogleFonts.lexendDeca(),
                            onPressed: () async {
                              //setState(() => pressAttention = true);
                              favSwitcher(post);
                              setState(() {});
                            },
                            color: Colors.pink,
                            highlightColor: Colors.pinkAccent,
                            padding: const EdgeInsets.all(8.0),
                            text:
                                (!faved(post)) ? ("Favorite") : ("Unfavorite"),
                          );
                        })),
//                    Padding(
//                      padding: EdgeInsets.only(left: 5, right: 5),
//                      child: ((post.sources != null) && post.sources.isNotEmpty)
//                          ? Row(children: <Widget>[
//                              Expanded(
//                                  child: GFButton(
//                                shape: GFButtonShape.pills,
//                                textStyle: GoogleFonts.roboto(),
//                                onPressed: () {
//                                  if (post.sources.isNotEmpty) {
//                                    log(post.sources[0]);
//                                    launch(post.sources[0]);
//                                  }
//                                },
//                                color: Colors.deepPurple,
//                                padding: const EdgeInsets.all(8.0),
//                                text: (AppLocalizations.of(context)
//                                    .translate('openSource')),
//                              ))
//                            ])
//                          : Row(children: <Widget>[
//                              Expanded(
//                                  child: GFButton(
//                                shape: GFButtonShape.pills,
//                                textStyle: GoogleFonts.roboto(),
//                                onPressed: null,
//                                color: Colors.orangeAccent,
//                                padding: const EdgeInsets.all(8.0),
//                                text: (AppLocalizations.of(context)
//                                    .translate('noSource')),
//                              )),
//                              (IconButton(
//                                icon: Icon(FontAwesomeIcons.globe),
//                                onPressed: () {
//                                  log('https://e621.net/post/show/' +
//                                      post.id.toString());
//                                  launch('https://e621.net/post/show/' +
//                                      post.id.toString());
//                                },
//                              ))
//                            ]),
//                    ),
                    Container(
                      child: Card(
                        child: ListView(
                          shrinkWrap: true,
                          primary: false,
                          //scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            ((post.tags['artist'] != null) &&
                                    post.tags['artist'].isEmpty)
                                ? (AutoSizeText(
                                    "Artist:" + "Unknown",
                                  ))
                                : SizedBox(
                                    height: 30,
                                    width: 100,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: artistCards,
                                    )),
                            //Spacer(flex: 10,),
                            Linkify(
                              text: "Source: " +
                                  (((post.sources != null) &&
                                          post.sources.isNotEmpty)
                                      ? post.sources[0]
                                      : 'No Sauce!'),
                              onOpen: _onOpen,
                            )
                          ],
                        ),
                      ),
                    ),
                    newComment(context, post.id),
                    commentWidget,
//                    Align(
//                      child: bannerAd(context,
//                          height: null, size: AdmobBannerSize.BANNER),
//                      alignment: Alignment.center,
//                    ),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              key: key,
              appBar: GFAppBar(
                title: textBox(context),
                actions: <Widget>[
                  PopupMenuButton(
                    icon: Icon(FontAwesomeIcons.ellipsisV),
                    //isExpanded: true,
                    onSelected: (choice) {},
                    itemBuilder: (BuildContext context) {
                      return popUpItems;
                    },
                  )
                ],
                backgroundColor: Colors.black54,
              ),
              body: Container(
                child: Row(children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.height / 1.5,
                    child: Hero(
                      tag: post.id.toString(),
                      child: Stack(children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AdvancedNetworkImage(post.previewUrl,
                                  cacheRule: CacheRule(
                                      maxAge: const Duration(days: 7))),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.0)),
                            ),
                          ),
                        ),
                        InkWell(
                          child: mediaBuilder(post, context),
//                        onLongPress: () {
//                          galleryLRScroll(context, globals.lastResults,
//                              index: this.index, replace: true);
//                        },
                        ),
                      ]),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    child: ListView(
                      children: <Widget>[
                        //Image.network(post.fileUrl),
                        voting(context, post, stale: voteStale, token: token),
                        //recomendRating(context, ''),
                        tagger(post, context, pageOwner, token: token),
                        ExpandablePanel(
                            header: AutoSizeText("Description:",
                                style: GoogleFonts.roboto(fontSize: 20)),
                            collapsed: AutoSizeText(post.description.toString(),
                                maxLines: 2,
                                style: GoogleFonts.roboto(fontSize: 15)),
                            expanded: FutureBuilder(
                              future: networkingPriority(token: token)
                                  .get('https://e621.net/posts/' +
                                      post.id.toString())
                                  .then((Response value) {
                                String description = value.data;
                                var document = html_parser.parse(description);
                                List<dom.Element> commentElement = document.body
                                    .getElementsByClassName(
                                        'expandable-content styled-dtext original-artist-commentary');
                                if (commentElement.isNotEmpty) {
                                  return commentElement[0].innerHtml;
                                }
                              }),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Column(children: [
                                    Html(
                                      data: snapshot.data,
                                    ),
                                    Text("Poster: " +
                                        post.uploader_id.toString() +
                                        '\r' +
                                        "Upload Date: " +
                                        date.toString().split('.')[0] +
                                        "Content Rating:" +
                                        post.rating)
                                  ]);
                                } else {
                                  return Linkify(
                                    text: post.description.toString() +
                                        ' \n' +
                                        "Poster: " +
                                        post.uploader_id.toString() +
                                        '\r' +
                                        "Upload Date: " +
                                        date.toString().split('.')[0] +
                                        "Content Rating:" +
                                        post.rating,
                                    onOpen: _onOpen,
                                  );
                                }
                              },
                            )),
                        (post.has_children || post.parent_id != null)
                            ? FutureBuilder(
                                future: childrenView(context, post, index,
                                    token: token),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return (snapshot.data != null)
                                        ? snapshot.data
                                        : Container();
                                  } else {
                                    return Row(children: [
                                      Expanded(
                                        child: Container(),
                                      ),
                                      SizedBox(
                                          height: 50.0,
                                          width: 50.0,
                                          child: GFLoader()),
                                      Expanded(
                                        child: Container(),
                                      )
                                    ]);
                                  }
                                },
                              )
                            : Container(),
                        GFButton(
                          shape: GFButtonShape.pills,
                          textStyle: GoogleFonts.lexendDeca(),
                          onPressed: () {
                            save2(post, context);
                          },
                          color: Colors.deepOrange,
                          padding: const EdgeInsets.all(8.0),
                          text: ("Download"),
                        ),
                        StatefulBuilder(
                            builder: (context, StateSetter setState) {
                          return GFButton(
                            shape: GFButtonShape.pills,
                            textStyle: GoogleFonts.lexendDeca(),
                            onPressed: () {
                              //setState(() => pressAttention = true);
                              favSwitcher(post);
                              setState(() {});
                            },
                            color: Colors.pink,
                            highlightColor: Colors.pinkAccent,
                            padding: const EdgeInsets.all(8.0),
                            text:
                                (!faved(post)) ? ("Favorite") : ("Unfavorite"),
                          );
                        }),
//                        ((post.sources != null) && post.sources.isNotEmpty)
//                            ? Row(children: <Widget>[
//                                Expanded(
//                                    child: GFButton(
//                                  shape: GFButtonShape.pills,
//                                  textStyle: GoogleFonts.roboto(),
//                                  onPressed: () {
//                                    if (post.sources.isNotEmpty) {
//                                      log(post.sources[0]);
//                                      launch(post.sources[0]);
//                                    }
//                                  },
//                                  color: Colors.deepPurple,
//                                  padding: const EdgeInsets.all(8.0),
//                                  text: (AppLocalizations.of(context)
//                                      .translate('openSource')),
//                                )),
//                                (IconButton(
//                                  icon: Icon(FontAwesomeIcons.globe),
//                                  onPressed: () {
//                                    log('https://e621.net/post/show/' +
//                                        post.id.toString());
//                                    launch('https://e621.net/post/show/' +
//                                        post.id.toString());
//                                  },
//                                ))
//                              ])
//                            : Row(children: <Widget>[
//                                Expanded(
//                                    child: GFButton(
//                                  shape: GFButtonShape.pills,
//                                  textStyle: GoogleFonts.roboto(),
//                                  onPressed: () {
//                                    if (post.sources.isNotEmpty) {
//                                      log(post.sources[0]);
//                                      launch(post.sources[0]);
//                                    }
//                                  },
//                                  color: Colors.orangeAccent,
//                                  padding: const EdgeInsets.all(8.0),
//                                  text: (AppLocalizations.of(context)
//                                      .translate('noSource')),
//                                )),
//                                (IconButton(
//                                  icon: Icon(FontAwesomeIcons.searchengin),
//                                  onPressed: () {
//                                    log('https://e621.net/post/show/' +
//                                        post.id.toString());
//                                    launch('https://e621.net/post/show/' +
//                                        post.id.toString());
//                                  },
//                                ))
//                              ]),
                        Container(
                          child: Card(
                              child: ListView(
                            shrinkWrap: true,
                            primary: false,
                            //scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              ((post.tags['artist'] != null) &&
                                      post.tags['artist'].isEmpty)
                                  ? (AutoSizeText(
                                      "Artist:" + "Unknown",
                                    ))
                                  : SizedBox(
                                      height: 30,
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: artistCards,
                                      )),
                              //Spacer(flex: 10,),
                              Linkify(
                                text: "Source: " +
                                    (((post.sources != null) &&
                                            post.sources.isNotEmpty)
                                        ? post.sources[0]
                                        : 'No Sauce!'),
                                onOpen: _onOpen,
                              )
                            ],
                          )),
                        ),
                        newComment(context, post.id),
                        commentWidget,
//                        bannerAd(context,
//                            size: AdmobBannerSize.BANNER,
//                            height: 50,
//                            width: 200)
                      ],
                    ),
                  ))
                ]),
              ),
            );
          }
        }),
      ));
    } catch (e) {
      log(e);
      return (Scaffold(
          body: Container(
        color: Colors.red,
        height: 100,
      )));
    }
  }

  Widget textBox(BuildContext context) {
    return Center(
        child: Row(
            //padding: const EdgeInsets.only(top: 0, bottom: 30.0, left: 5, right: 5),
            children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Text(
            '#',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
              width: 65,
              child: TextField(
                key: formKey,
                controller: controller..text = post.id.toString(),
                onSubmitted: (data) async {
                  Widget newDetail =
                      await getPostByID2(context, int.parse(controller.text))
                          .then((value) {
                    if (value != null) {
                      return PostDetail(value);
                    }
                    return null;
                  });
                  if (newDetail != null) {
                    await Get.to(newDetail);
                  }
                },
                keyboardType: TextInputType.text,
                style: GoogleFonts.roboto(),
              )),
          Expanded(
            child: Container(),
          ),
        ]));
  }
}
