import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:e305/loginManager.dart';
import 'package:e305/postDetailPage.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:e305/themeData.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:getflutter/getflutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:preferences/preference_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';

import 'postDefinition.dart';

final key = GlobalKey<ScaffoldState>();
Axis baseAxis = Axis.horizontal;
double rotation = 0;

BoxFit determineScaling() {
  List<String> options = [
    'Contain',
    'Cover',
    'Fill',
    'Fit Height',
    'Fit Width',
    'None',
    'Scale Down'
  ];
  String scale = (PrefService.getString('image_scale'));
  if (scale != null) {
    if (scale == options[0]) {
      return BoxFit.contain;
    } else if (scale == options[1]) {
      return BoxFit.cover;
    } else if (scale == options[2]) {
      return BoxFit.fill;
    } else if (scale == options[3]) {
      return BoxFit.fitHeight;
    } else if (scale == options[4]) {
      return BoxFit.fitWidth;
    } else if (scale == options[5]) {
      return BoxFit.none;
    } else if (scale == options[6]) {
      return BoxFit.scaleDown;
    }
  }
  return BoxFit.cover;
}

galleryLRScroll(context, List<Post2> posts,
    {int currentIndex = 0, bool replace = false, bool loop = false}) {
  List<int> rebuild = [];
  bool locked = false;

  if (posts.isNotEmpty) {
    return Get.to(StatefulBuilder(builder: (context, StateSetter setState) {
      IconData twist = FontAwesomeIcons.arrowsAltV;
      if (baseAxis == Axis.horizontal) {
        twist = FontAwesomeIcons.arrowsAltH;
      }
      IconData lock = FontAwesomeIcons.lockOpen;
      if (locked == true) {
        lock = FontAwesomeIcons.lock;
      }
      return Scaffold(
        key: key,
        appBar: GFAppBar(
          title: AutoSizeText(
            'Reader Mode',
            style: TextStyle(fontSize: 14),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          actions: <Widget>[
            IconButton(
              icon: Icon(twist),
              onPressed: () {
                String direction = 'horizantal';
                if (baseAxis == Axis.horizontal) {
                  baseAxis = Axis.vertical;
                  direction = 'vertical';
                } else {
                  baseAxis = Axis.horizontal;
                }
                key.currentState.showSnackBar(
                  SnackBar(
                    content: Text("Scroll Switched to: " + direction),
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {});
              },
            ),
            IconButton(
              icon: Icon(lock),
              onPressed: () {
                String lockStatus = 'unlocked';
                if (locked == false) {
                  locked = true;
                  lockStatus = 'locked';
                } else {
                  locked = false;
                }
                key.currentState.showSnackBar(
                  SnackBar(
                    content: Text("Page swiping: " + lockStatus),
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {});
              },
            )
          ],
        ),
        body: PageView.builder(
          physics: (locked) ? NeverScrollableScrollPhysics() : null,
          itemBuilder: (BuildContext context, int index) {
            posts[index] = defaultFilterFixer(posts[index]);
            bool _open = false;
            PersistentBottomSheetController _controller;
            final GlobalKey<ScaffoldState> scaffoldKey =
                GlobalKey<ScaffoldState>();
            var item = posts[index].fileUrl;
            Widget image = PhotoView(
              imageProvider: AdvancedNetworkImage(item,
                  cacheRule: CacheRule(maxAge: const Duration(days: 7))),
            );
            if (posts[index].fileExt == 'webm' ||
                posts[index].fileExt == 'swf') {
              image = mediaBuilder(posts[index], context);
            }
            image = Scaffold(
                key: scaffoldKey,
                body: Transform.rotate(
                    angle: rotation,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      child: image,
                      alignment: Alignment.center,
                    )),
                bottomNavigationBar: BottomAppBar(
                  color: Colors.black,
                  child: AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      alignment: Alignment.center,
                      height: 40,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StatefulBuilder(
                                builder: (context, StateSetter setState) {
                              return IconButton(
                                icon: Icon(FontAwesomeIcons.infoCircle),
                                onPressed: () async {
                                  if (!_open) {
                                    _open = !_open;
                                    _controller = await scaffoldKey.currentState
                                        .showBottomSheet(
                                            (context) => SingleChildScrollView(
                                                child: JsonViewerWidget(
                                                    posts[index].toJson())),
                                            backgroundColor:
                                                Colors.black54.withAlpha(150));
                                  } else {
                                    _open = !_open;
                                    _controller.close();
                                  }
                                },
                              );
                            }),
                            IconButton(
                              color: Colors.red,
                              icon: Icon((faved(posts[index]))
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.heart),
                              onPressed: () {
                                favSwitcher(posts[index]);
                                setState(() {});
                              },
                            ),
                            Container(
                              width: 20,
                            ),
                            AutoSizeText('Page: ' +
                                (index + 1).toString() +
                                '/' +
                                posts.length.toString()),
                            Container(
                              width: 20,
                            ),
                            GFIconButton(
                              icon: Icon(FontAwesomeIcons.bookOpen),
                              onPressed: () {
                                Get.to(
                                  PostDetail(
                                    posts[index],
                                    index: index,
                                    posts: posts,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(FontAwesomeIcons.redo),
                              onPressed: () async {
                                rotation += pi / 2;
                                if (rotation == 2 * pi) {
                                  rotation = 0;
                                }
                                setState(() {});
                              },
                            ),
                          ])),
                ));
            if (index == currentIndex) {
              return image;
            } else {
              return image;
            }
          },
          itemCount: posts.length,
          onPageChanged: (int index) {
            currentIndex = index;
            rebuild.add(index);
          },
          controller: PageController(
            initialPage: currentIndex,
          ),
          scrollDirection: baseAxis,
        ),
      );
    }));
  } else {
    Get.snackbar(
      'No posts',
      'For one reason or another theres no posts to view.',
      icon: Icon(
        FontAwesomeIcons.timesCircle,
        color: Colors.amber,
      ),
    );
//  DismissDirection approvedDirection = DismissDirection.horizontal;
//
//  if (index == posts.length - 1) {
//    approvedDirection = DismissDirection.startToEnd;
//  } else if (index == 0) {
//    approvedDirection = DismissDirection.endToStart;
//  }
//
//  return Navigator.of(context, rootNavigator: true).push(
//    CupertinoPageRoute(
//      builder: (context) => Scaffold(
//        body: SafeArea(
//          child: exitButton(
//            context,
//            Swiper(
//              itemCount: posts.length,
//              index: index,
//              loop: loop,
//              itemBuilder: (BuildContext context, int lIndex) {
//                bool fullImage = (PrefService.getBool('fullImage') != null)
//                    ? PrefService.getBool('fullImage')
//                    : true;
//                String targetImage = posts[lIndex].fileUrl;
//                if (!fullImage) {
//                  targetImage = posts[lIndex].sampleUrl;
//                }
//                Widget viewer = InkWell(
//                  onLongPress: () {
//                    Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (context) => PostDetail(
//                                  posts[lIndex],
//                                  index: lIndex,
//                                  posts: posts,
//                                )));
//                  },
//                  child: PhotoView(
//                      tightMode: true,
//                      imageProvider: AdvancedNetworkImage(
//                          (targetImage != null) ? posts[lIndex].fileUrl : '',
//                          useDiskCache: true,
//                          cacheRule:
//                              CacheRule(maxAge: const Duration(minutes: 5))),
//                      minScale: PhotoViewComputedScale.contained * .25,
//                      maxScale: PhotoViewComputedScale.covered * 10,
//                      loadingBuilder: (context, imageChunk) {
//                        return Center(
//                          child: GFLoader(),
//                        );
//                      }),
//                );
//                if (posts[lIndex].fileExt == 'webm' ||
//                    posts[lIndex].fileExt == 'swf') {
//                  viewer = mediaBuilder(posts[lIndex], context);
//                }
//                return viewer;
//              },
//            ),
//          ),
//        ),
//      ),
//    ),
//  );
//
  }
}

Widget mediaBuilder(Post2 post, context, {bool cache = false}) {
  post = defaultFilterFixer(post);
  FlareControls flareControls = FlareControls();

  if (post.fileExt == 'swf') {
    return Center(
      child: AspectRatio(
        child: Center(
          child: Text(
            'SWF is not supported on Android',
            style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 25),
          ),
        ),
        aspectRatio: 2 / 1,
      ),
    );
  } else if (post.fileExt != 'webm') {
    bool fullImage = (PrefService.getBool('fullImage') != null)
        ? PrefService.getBool('fullImage')
        : false;
    String targetImage = post.fileUrl;
    if (!fullImage) {
      targetImage = post.sampleUrl;
    }
    return InkWell(
      onTap: () {
        Get.to(
          exitButton(
              context,
              Center(
                child: ClipRect(
                  child: PhotoView(
                      imageProvider: AdvancedNetworkImage(
                          ((targetImage != null) ? targetImage : ''),
                          useDiskCache: cache,
                          cacheRule:
                              CacheRule(maxAge: const Duration(minutes: 5))),
                      minScale: PhotoViewComputedScale.contained * .75,
                      maxScale: PhotoViewComputedScale.covered * 3),
                ),
              )),
        );
      },
      onDoubleTap: () {
        flareControls.play("like");
        favSwitcher(post, dislikeAllowed: false);
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: post.sampleWidth / post.sampleHeight,
          child: ClipRect(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                AnimatedContainer(
                    alignment: Alignment.center,
                    key: Key(post.id.toString()),
                    duration: Duration(milliseconds: 250),
                    child: TransitionToImage(
                      image: (faved(post))
                          ? AdvancedNetworkImage(
                              ((targetImage != null) ? targetImage : ''),
                              cacheRule:
                                  CacheRule(maxAge: const Duration(days: 7)))
                          : AdvancedNetworkImage(
                              ((targetImage != null) ? targetImage : ''),
                              useDiskCache: cache,
                              cacheRule: CacheRule(
                                  maxAge: const Duration(minutes: 5))),
                      loadingWidgetBuilder: (_, double progress, __) => Center(
                          child: Stack(children: <Widget>[
                        AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AdvancedNetworkImage(post.previewUrl,
                                      cacheRule: CacheRule(
                                          maxAge: const Duration(days: 7)),
                                      loadingProgress: (prog, listProg) {
                                    return Center(
                                      child: AnimatedContainer(
                                          duration: Duration(milliseconds: 250),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AdvancedNetworkImage(
                                                    targetImage,
                                                    cacheRule: CacheRule(
                                                        maxAge: const Duration(
                                                            days: 7))),
                                                fit: determineScaling()),
                                          )),
                                    );
                                  }),
                                  fit: determineScaling()),
                            )),
                        Align(
                          child: AutoSizeText(
                            (progress * 100).toInt().toString() + '%',
                            style: TextStyle(
                                fontSize: 100,
                                shadows: [
                                  Shadow(
                                      color:
                                          Color.fromRGBO(105, 105, 105, 0.35),
                                      blurRadius: 10.0)
                                ],
                                color: Color.fromRGBO(255, 255, 255, 0.5)),
                            maxLines: 1,
                            maxFontSize: 100,
                            minFontSize: 5,
                          ),
                          alignment: Alignment.center,
                        ),
                      ])),
                      fit: determineScaling(),
                    )),
                AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  child: Center(
                    child: Container(
                      child: FlareActor(
                        'assets/instagram_like.flr',
                        controller: flareControls,
                        animation: 'idle',
                      ),
                    ),
                  ),
                ),
                (post.flags['deleted'] || post.flags['flagged'])
                    ? AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            Text(
                              'This post was Deleted/Flagged on e621',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            GFButton(
                              text: 'Investigate on site?',
                              onPressed: () {
                                launch('https://e621.net/posts/' +
                                    post.id.toString());
                              },
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75)),
                        constraints: BoxConstraints.expand(),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
//  return Container(
//      child: Center(
//          child: AspectRatio(
//              aspectRatio: post.sampleWidth / post.sampleHeight,
//              child: SimpleViewPlayer(
//                post.fileUrl,
//                isFullScreen: false,
//              ))));
  return GestureDetector(
    child: Stack(
      children: [
        Image(image: AdvancedNetworkImage(post.sampleUrl)),
        Align(
          child: Icon(
            FontAwesomeIcons.playCircle,
            size: 100,
            color: Colors.lightBlue,
          ),
          alignment: Alignment.center,
        ),
      ],
      alignment: Alignment.center,
    ),
    onTap: () {
      Get.to(ListVideo(post));
    },
  );
//  return Center(
//      child: AspectRatio(
//          aspectRatio: post.sampleWidth / post.sampleHeight,
//          child: ClipRect(
//              child: ChewieListItem(
//            post.fileUrl,
//            aspect: post.sampleWidth / post.sampleHeight,
//            looping: true,
//          ))));
}

class ListVideo extends StatefulWidget {
  final Post2 src1;

  ListVideo(this.src1);

  @override
  _ListVideoState createState() => _ListVideoState(src1);
}

class _ListVideoState extends State<ListVideo> {
  VideoController vc;
  Post2 src1;

  _ListVideoState(this.src1);

  @override
  void initState() {
    super.initState();
    vc = VideoController(
        source: VideoPlayerController.network(src1.fileUrl),
        autoplay: true,
        looping: true,
        circularProgressIndicatorColor: Colors.amber)
      ..initialize();
  }

  @override
  void dispose() {
    vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Post #: ' + src1.id.toString(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
          child: AspectRatio(
        aspectRatio: src1.fileWidth / src1.fileHeight,
        child: VideoBox(controller: vc),
      )),
    );
  }
}

class videoOutPlayer extends StatefulWidget {
  final Post2 post;

  videoOutPlayer(this.post);

  @override
  _videoOutPlayer createState() => _videoOutPlayer(post);
}

class _videoOutPlayer extends State<videoOutPlayer> {
  final Post2 post;

  _videoOutPlayer(this.post);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget holster(Widget vid) {
      return Center(
          child: AspectRatio(
              aspectRatio: post.sampleWidth / post.sampleHeight,
              child: ClipRect(child: vid)));
    }

    return holster(AnimatedContainer(
      duration: Duration(milliseconds: 250),
      child: Stack(children: [
        GestureDetector(
          child: Image(
            image: AdvancedNetworkImage(post.sampleUrl),
          ),
          onTap: () {
            Get.to(Scaffold(
                appBar: GFAppBar(
                  backgroundColor: Colors.black12.withAlpha(10),
                ),
                body: VideoBox(
                  controller: VideoController(
                    source: VideoPlayerController.network(post.fileUrl),
                    looping: true,
                  )..initialize(),
                )));
          },
        ),
        Align(
          child: GestureDetector(
              child: Icon(
                FontAwesomeIcons.playCircle,
                color: Colors.lightBlue,
                size: 100,
              ),
              onTap: () {
                Get.to(Scaffold(
                    appBar: GFAppBar(
                      backgroundColor: Colors.black12.withAlpha(10),
                    ),
                    body: VideoBox(
                      controller: VideoController(
                        source: VideoPlayerController.network(post.fileUrl),
                        looping: true,
                      )..initialize(),
                    )));
              }),
          alignment: Alignment.center,
        ),
      ]),
    ));
  }
}

Widget thumbnailBuilder(context, Post2 post,
    {bool animate = true, bool cache = false, bool manageSetState = false}) {
  bool highres = (PrefService.getBool('hiresChoice') != null)
      ? PrefService.getBool('hiresChoice')
      : true;
  FlareControls flareControls = FlareControls();
  animate = (PrefService.getBool('animateChoice') != null)
      ? PrefService.getBool('animateChoice')
      : true;
  post = defaultFilterFixer(post);
  if (post.fileExt == 'webm') {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      //width: 200,
      //height: 125,
      child: Stack(children: [
        Align(
          alignment: Alignment.center,
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              height: 225,
              width: 350,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(
                      image: (cache)
                          ? (highres)
                              ? AdvancedNetworkImage(
                                  ((post.sampleUrl != null)
                                      ? post.sampleUrl
                                      : ''),
                                  //scale: .075,
                                  useDiskCache: true,
                                  cacheRule: const CacheRule(
                                      maxAge: Duration(days: 1)))
                              : AdvancedNetworkImage(
                                  ((post.previewUrl != null)
                                      ? post.previewUrl
                                      : ''),
                                  //scale: .075,
                                  useDiskCache: true,
                                  cacheRule: const CacheRule(
                                      maxAge: Duration(days: 1)))
                          : (highres)
                              ? AdvancedNetworkImage(
                                  (post.sampleUrl != null)
                                      ? post.sampleUrl
                                      : '',
                                  cacheRule:
                                      CacheRule(maxAge: const Duration(days: 7))
                                  //scale: .075
                                  )
                              : AdvancedNetworkImage(
                                  (post.previewUrl != null)
                                      ? post.previewUrl
                                      : '',
                                  //scale: .075
                                ),
                      fit: determineScaling())),
              //width: 200,
              //height: 125,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            height: 225,
            child: Icon(
              FontAwesomeIcons.playCircle,
              color: getPanacheTheme().buttonColor,
              size: 50,
            ),
            //width: post.sampleWidth + 0.0,
            //height: post.sampleHeight + 0.0,
          ),
        ),
        (post.flags['deleted'] || post.flags['flagged'])
            ? Align(
                alignment: Alignment.center,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  height: 225,
                  child: Icon(
                    FontAwesomeIcons.skullCrossbones,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
              )
            : Container(),
      ]),
    );
  } else if (post.fileExt == 'swf') {
    return Container(
      child: Stack(children: [
        Center(
          child: Container(
            width: 225,
            height: 350,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                    image: (cache)
                        ? AdvancedNetworkImage(
                            ((post.previewUrl != null) ? post.previewUrl : ''),
                            scale: .075,
                            useDiskCache: true,
                            cacheRule:
                                const CacheRule(maxAge: Duration(days: 1)))
                        : NetworkImage(
                            (post.previewUrl != null) ? post.previewUrl : '',
                            scale: .075),
                    fit: determineScaling())),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 225,
            child: Icon(
              FontAwesomeIcons.skullCrossbones,
              color: getPanacheTheme().buttonColor,
              size: 50,
            ),
          ),
        ),
      ]),
    );
  } else {
    double modifier = scaleToGridSize(context, post);
    return GestureDetector(
      child: Stack(children: <Widget>[
        Material(
            elevation: 5,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: Container(
              alignment: Alignment.center,
              height: post.sampleHeight / modifier,
              width: post.sampleWidth / modifier,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(
                      image: (cache)
                          ? AdvancedNetworkImage(
                              ((animate &&
                                          (post.fileExt == 'apng' ||
                                              post.fileExt == 'gif')) ||
                                      ((post.fileExt != 'apng' &&
                                              post.fileExt != 'gif') &&
                                          highres))
                                  ? ((post.sampleUrl != null)
                                      ? post.sampleUrl
                                      : '')
                                  : ((post.previewUrl != null)
                                      ? post.previewUrl
                                      : ''),
                              //scale: .075,
                              useDiskCache: true,
                              cacheRule:
                                  const CacheRule(maxAge: Duration(days: 1)))
                          : NetworkImage(
                              ((animate &&
                                          (post.fileExt == 'apng' ||
                                              post.fileExt == 'gif')) ||
                                      ((post.fileExt != 'apng' &&
                                              post.fileExt != 'gif') &&
                                          highres))
                                  ? ((post.sampleUrl != null)
                                      ? post.sampleUrl
                                      : '')
                                  : ((post.previewUrl != null)
                                      ? post.previewUrl
                                      : ''),
                              scale: 0.25),
                      fit: determineScaling())),
            )),
        Align(
          child: Container(
            height: post.sampleHeight / modifier,
            width: post.sampleHeight / modifier,
            child: FlareActor(
              'assets/instagram_like.flr',
              controller: flareControls,
              animation: 'idle',
            ),
          ),
          alignment: Alignment.center,
        ),
        (post.flags['deleted'] || post.flags['flagged'])
            ? Align(
                alignment: Alignment.center,
                child: Container(
                  height: 225,
                  child: Icon(
                    FontAwesomeIcons.skullCrossbones,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
              )
            : Container(),
      ]),
      onDoubleTap: () async {
        flareControls.play("like");
        //showToast('Saved To Favorites', context);
        favSwitcher(post, dislikeAllowed: false);
        if (manageSetState) {
          Scaffold.of(context).setState(() {});
        }
      },
    );
  }
}

Widget carouselCard(BuildContext context, Post2 post,
    {int index = 0, List posts}) {
  bool highres = (PrefService.getBool('hiresChoice') != null)
      ? PrefService.getBool('hiresChoice')
      : true;
  String target = post.sampleUrl;
  if (!highres) {
    target = post.previewUrl;
  }
  if (posts == null) {
    posts = [post];
  }
  FlareControls flareControls = FlareControls();
  return StatefulBuilder(builder: (innerContext, setState) {
    return GestureDetector(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
                right: (50), left: (50), top: (50), bottom: (50)),
            alignment: Alignment.bottomCenter,
            child: Container(
              child: FlareActor(
                'assets/instagram_like.flr',
                controller: flareControls,
                animation: 'idle',
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.transparent,
                image: DecorationImage(
                    fit: determineScaling(),
                    image: AdvancedNetworkImage(target),
                    onError: (item, stack) {})),
          ),
          Align(
            child: Container(
              child: Wrap(
                spacing: (10),
                children: [
                  (faved(post))
                      ? Container(
                          child: Icon(
                            FontAwesomeIcons.solidHeart,
                            size: 30,
                          ),
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.black54.withAlpha(128)),
                        )
                      : Container(),
                  (loggedIn() &&
                          (votingRecordTable['post-' + post.id.toString()] ==
                              1))
                      ? Container(
                          child: Icon(
                            FontAwesomeIcons.solidThumbsUp,
                            size: 30,
                          ),
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.black54.withAlpha(128)),
                        )
                      : Container(),
                ],
                alignment: WrapAlignment.end,
              ),
              height: 80,
              padding: EdgeInsets.only(right: (20), top: (20)),
            ),
            alignment: Alignment.topRight,
          ),
          Align(
            child: Container(
              child: Wrap(
                spacing: (10),
                children: [
                  (post.fileExt == 'webm')
                      ? Container(
                          child: Icon(
                            FontAwesomeIcons.playCircle,
                            size: 30,
                          ),
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.black54.withAlpha(128)),
                        )
                      : Container(),
                  (post.has_active_children || post.parent_id != null)
                      ? Container(
                          child: Icon(
                            FontAwesomeIcons.layerGroup,
                            size: 30,
                          ),
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.black54.withAlpha(128)),
                        )
                      : Container(),
                ],
                alignment: WrapAlignment.start,
              ),
              height: 80,
              padding: EdgeInsets.only(left: (20), bottom: (20)),
            ),
            alignment: Alignment.bottomLeft,
          )
        ],
      ),
      onTap: () {
        Get.to(
          PostDetail(
            post,
            index: index,
            posts: [post],
          ),
        );
      },
      onLongPress: () {
        galleryLRScroll(context, (posts != null) ? posts.cast() : [post],
            currentIndex: index, replace: true);
      },
      onDoubleTap: () async {
        flareControls.play("like");
        //showToast('Saved To Favorites!', context);
        favSwitcher(post, dislikeAllowed: false);
        setState(() {});
      },
    );
  });
}

bool highRes() {
  bool highres = (PrefService.getBool('hiresChoice') != null)
      ? PrefService.getBool('hiresChoice')
      : true;
  return highres;
}

String getAppropriateImageQuality(Post2 post) {
  if (highRes()) {
    return post.sampleUrl;
  }
  return post.previewUrl;
}
