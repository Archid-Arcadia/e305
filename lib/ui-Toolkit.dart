import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:e305/commentDefinition.dart';
import 'package:e305/getComments.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/globals.dart';
import 'package:e305/loginManager.dart';
import 'package:e305/mediaManager.dart';
import 'package:e305/networking.dart';
import 'package:e305/postDetailPage.dart';
import 'package:e305/showToast.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:e305/themeData.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:getflutter/getflutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:linkify/linkify.dart';
import 'package:pedantic/pedantic.dart';
import 'package:preferences/preference_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'fancyTime.dart';
import 'getSet.dart';
import 'globals.dart' as globals;
import 'models/Comment.dart' as comment_models;
import 'postDefinition.dart';
import 'searchPage.dart';

//final translator = GoogleTranslator();

List<Post2> favoritesPosts = [];

PrefService prefService = prefService;

int reccomendCounter = 0;

Widget circleImageButton(
    {double elevation = 4.0,
    ImageProvider image,
    width = 80.0,
    height = 80.0,
    Function onTap,
    Function onPress,
    String text = ''}) {
  if (image == null) {
    image = AdvancedNetworkImage(
      'https://miro.medium.com/fit/c/160/160/0*DDXi_w_xJvLT3NhP.jpeg',
    );
  }
  if (onPress == null) {
    onPress = () {};
  }
  if (onTap == null) {
    onTap = () {};
  }
  return Padding(
    padding: EdgeInsets.all(2),
    child: Material(
      elevation: elevation,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      //color: Colors.transparent,
      child: Ink.image(
        image: image,
        fit: determineScaling(),
        width: width,
        height: height,
        child: Stack(children: <Widget>[
          Center(
            child: SizedBox(
              width: width - width / 2,
              height: height - height / 2,
              child: Center(
                child: AutoSizeText(
                  text,
                  textAlign: TextAlign.center,
                  minFontSize: 8,
                  maxFontSize: 20,
                  style: TextStyle(
                    //fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(1.0, 0.0),
                        blurRadius: 10.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      Shadow(
                        offset: Offset(0.0, 1.0),
                        blurRadius: 10.0,
                        color: Color.fromARGB(125, 0, 0, 255),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            onLongPress: onPress,
          )
        ]),
      ),
    ),
  );
}

Future<ConfirmAction> ConfirmDialog(
  BuildContext context,
  onAccept, {
  String title = 'Really?',
  String message =
      'This will reset your in-app favorites, all of them. Did you really mean to do this?',
  String acceptText = 'YES!!',
  String cancelText = 'Wait, No!',
}) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: const Text('Wait, No!'),
            onPressed: () {
              ConfirmAction.CANCEL;
              Get.back();
            },
          ),
          FlatButton(
            child: const Text('YES!!'),
            onPressed: () {
              onAccept;
              ConfirmAction.ACCEPT;
              Get.back();
            },
          )
        ],
      );
    },
  );
}

Widget exitButton(context, Widget child) {
  return Scaffold(
    extendBodyBehindAppBar: true,
    body: child,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
    ),
  );
}

Widget experimentalPostPreview(
  context,
  Post2 post, {
  List<Post2> posts,
  int index = 0,
  double width,
  double height,
}) {
  FlareControls flareControls = FlareControls();
  bool favorited = false;
  List Favorites = globals.favoritesCache.keys.toList();
  if (((PrefService.getBool('likedThis') == null ||
      PrefService.getBool('likedThis') == true))) {
    if (Favorites.contains(post.id.toString())) {
      favorited = true;
    }
  }
  if (posts == null) {
    posts = [];
    posts.add(post);
  }
  if (width == null) {
    width = MediaQuery.of(context).size.width / 3;
  }
  if (height == null) {
    height = MediaQuery.of(context).size.height / 4;
  }
  post = defaultFilterFixer(post);
  return Padding(
    padding: EdgeInsets.only(
        left: width * 0.016,
        right: width * 0.016,
        top: 0,
        bottom: height * 0.02),
    child: Material(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(height * 0.08))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        child: Container(
          width: width,
          //height: height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AdvancedNetworkImage(post.previewUrl,
                      cacheRule: CacheRule(maxAge: Duration(minutes: 5)),
                      fallbackAssetImage: post.fileUrl),
                  fit: determineScaling()),
              backgroundBlendMode: BlendMode.multiply,
              color: Theme.of(context).backgroundColor),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
            child: Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: height * 0.004),
                    child: Material(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(height * 0.08))),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(children: [
                        Container(
                          height: height * 0.8,
                          //width: height * 0.8,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AdvancedNetworkImage(post.sampleUrl,
                                  fallbackAssetImage: post.fileUrl

//                                  postProcessing: (listImage) async {
//                                //print(listImage);
//                                var result =
//                                    await FlutterImageCompress.compressWithList(
//                                  listImage,
//                                  quality: 10,
//                                );
//                                //print(result);
//                                //print(result.runtimeType);
//                                return Uint8List.fromList(result);
//                              }
                                  ),
                              fit: determineScaling(),
                            ),
                            //borderRadius: BorderRadius.all(Radius.circular(40))
                          ),
                        ),
                        Container(
                          child: FlareActor(
                            'assets/instagram_like.flr',
                            controller: flareControls,
                            animation: 'idle',
                          ),
                          height: height * 0.8,
                        )
                      ]),
                      elevation: 10,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: (height * 0.03),
                        left: (width * 0.06),
                        right: (width * 0.06),
                        bottom: (height * 0.03)),
                    child: Row(
                      children: <Widget>[
                        Icon((((votingRecordTable[
                                        'post-' + post.id.toString()] !=
                                    null)
                                ? true
                                : false)
                            ? (((votingRecordTable[
                                        'post-' + post.id.toString()] ==
                                    1))
                                ? FontAwesomeIcons.solidThumbsUp
                                : FontAwesomeIcons.thumbsUp)
                            : FontAwesomeIcons.thumbsUp)),
                        Container(
                          width: width * 0.01,
                        ),
                        Text(post.scoreTotal.toString()),
                        Container(
                          width: width * 0.04,
                        ),
                        Icon(favorited
                            ? FontAwesomeIcons.solidHeart
                            : FontAwesomeIcons.heart),
                        Container(
                          width: width * 0.01,
                        ),
                        Text(post.fav_count.toString()),
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          child: AutoSizeText(fancyTimeDifferenceFromString(
                              context, posts[index].created_at)),
                        ),
                        Container(
                          width: width * 0.01,
                        ),
                        Icon(
                          FontAwesomeIcons.fire,
                          color: Colors.red,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () {
          Get.to(PostDetail(
            posts[index],
            index: index,
            posts: posts,
          ));
        },
        onDoubleTap: () {
          flareControls.play("like");
          //showToast('Saved To Favorites!', context);
          if (globals.favoritesCache[post.id.toString()] == null) {
            globals.favoritesCache[post.id.toString()] = post.toJson();
            log('Stored Favorite: ' + post.id.toString());
          }
          globals.saveFavoritesCache();
          addFavToAccount(post.id);
        },
        onLongPress: () {
          galleryLRScroll(context, posts, currentIndex: index);
        },
      ),
    ),
  );
}

LinearGradient getGradient(context, {bool background = false}) {
  if (background) {
    return (Theme.of(context).brightness == Brightness.light)
        ? Gradients.haze
        : Gradients.deepSpace;
  }
  return (Theme.of(context).brightness == Brightness.light)
      ? Gradients.coralCandyGradient
      : Gradients.taitanum;
}

Future<Map<String, dynamic>> getValue(Map<String, dynamic> input) async {
  String tags = input['tags'];
  Map<String, dynamic> favoritesCache = input['favoritesCache'];
  Map<String, dynamic> favstats = input['favstats'];
  int totalFavs = favoritesCache.keys.length;
  int totalAcceptedTags = 0;
  double total = 0;
  double totalAlt = 0;
  try {
    String text = "N/A";
    List<String> tagList = tags.split(' ');
    for (String tag in tagList) {
      if (favstats.keys.contains(tag)) {
        double value = 0;
        value = (favstats[tag] / (totalFavs / favstats.keys.length));
        totalAcceptedTags += 1;
        total += (value);
        totalAlt += (favstats[tag] / totalFavs);
        //total += 1;
      }
      //print(tag);
    }
    log('Raw score: ' + total.toString() + '/' + totalAcceptedTags.toString());
    log('Mod Score: ' + ((total) / totalAcceptedTags).toString());
    log('totalFavs: ' + totalFavs.toString());
    log('tagcount: ' + tags.length.toString());
    log('totalAcceptedTags: ' + totalAcceptedTags.toString());
    log('favstatsKeys: ' + favstats.keys.length.toString());
    log('Check: ' + (totalFavs / favstats.keys.length).toString());
    if ((totalFavs / favstats.keys.length) > 0.25) {
      total = ((total / totalAcceptedTags)).clamp(0, 1).toDouble();
    } else {
      double entry = ((total / totalAcceptedTags) * 0.75);
      log('entry: ' + entry.toString());
      total = (entry * 0.25).clamp(0, 1).toDouble();
    }
    totalAlt = (totalAlt / tagList.length);
    log(totalAlt);
    text = (total * 100).toStringAsPrecision(3) + "%";
    Map<String, dynamic> result = {'total': total, 'text': text};
    return result;
  } catch (e) {
    log(e);
    log(favstats);
    log(favoritesCache);
    return {'total': 0, 'text': 'Error'};
  }
}

Future<Map<String, dynamic>> getValueIsolate(Map<String, dynamic> input) async {
  try {
    var result = await compute(getValue, input);
    return result;
  } catch (e) {
    log('Isolate: ' + e.toString());
  }
  return null;
}

Widget gradientBackground(context, {Widget child}) {
  bool tempGB = PrefService.getBool('gradientBackgrounds');
  bool useGradient = (tempGB == null) ? false : tempGB;
  if (child == null) {
    child = Container();
  }

  return Container(
    child: child,
    decoration: (useGradient)
        ? BoxDecoration(gradient: getGradient(context, background: true))
        : BoxDecoration(color: Colors.black),
  );
}

Widget gridPostCards(context, List<Post2> posts, int index,
    {IconData icon, PrefService prefService, bool maintainState = false}) {
  if (icon == null) {
    icon = FontAwesomeIcons.newspaper;
  }
  if (prefService == null) {
    prefService = PrefService();
  }
  return Card(
    elevation: 2.5,
    key: PageStorageKey(index),
    color: Colors.white12,
    child: Column(
      children: <Widget>[
        InkWell(
          onLongPress: () {
            galleryLRScroll(context, posts, currentIndex: index, replace: true);
          },
          onTap: () {
            Get.to(
              PostDetail(posts[index], index: index),
            );
          },
          child: Hero(
              tag: posts[index].id.toString(),
              child: thumbnailBuilder(context, posts[index], animate: true)),
          onDoubleTap: () {},
        ),
        ListTile(
          isThreeLine: true,
          leading: Icon(
            icon,
          ),
          title: (posts[index].tags['artist'].isEmpty)
              ? (Text(
                  "Artist:" + ' ' + "Unknown",
                  style: TextStyle(fontSize: 12),
                ))
              : (Text(
                  "Artist:" + ' ' + posts[index].tags['artist'][0],
                  style: TextStyle(fontSize: 12),
                )),
          subtitle: AutoSizeText(
            "Score: " +
                posts[index].scoreTotal.toString() +
                ((PrefService.getBool('favCountChoice') == null ||
                        PrefService.getBool('favCountChoice') == true)
                    ? '     ❤️' + posts[index].fav_count.toString()
                    : '') +
                "\n" +
                "Uploaded: " +
                fancyTimeDifferenceFromString(context, posts[index].created_at),
            minFontSize: 5,
            maxFontSize: 30,
            style: TextStyle(fontSize: 20),
            maxLines: 2,
          ),
          onTap: () {
            Get.to(PostDetail(posts[index], index: index));
          },
        ),
      ],
    ),
  );
}

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

void log(Object o, {bool analytics = true, String type = 'Event'}) {
//  if (analytics) {
//    if (o.runtimeType == Post2) {
//      o = (o as Post2).toJson();
//    }
//    try {
//      fanalytics.logEvent(
//        name: type,
//        parameters: <String, dynamic>{
//          type: o.toString(),
//        },
//      );
//    } catch (e) {
//      print('Crash Detector failed to run');
//    }
//  }
  assert(() {
    print(o);
    return true;
  }());
}

Widget mindTheBottom(context, Widget child) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height - kBottomNavigationBarHeight,
    child: child,
  );
}

Widget mindTheTop(context, Widget child) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height - kToolbarHeight,
    child: child,
  );
}

Map<String, dynamic> normalizeMap(Map<String, dynamic> input) {
  Map<String, double> output = {};

  List<int> array = input.values.toList().cast<int>().toList();
  int high = array.reduce(max);
  int low = array.reduce(min);
  if (low == 0) {
    low = 1;
  }
  for (String key in input.keys) {
    log(key + ':' + input[key].toString());
    if (key.isNotEmpty) {
      double element = input[key].toDouble();
      if (element < 0) {
        output[key] = (-(element / low) * 1);
      } else {
        output[key] = ((element / high) * 1);
      }
    }
    log(key +
        ':' +
        input[key].toString() +
        ' to ' +
        key +
        ':' +
        output[key].toString());
  }
  return output;
}

double scaleToGridSize(BuildContext context, Post2 post) {
  //double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  //double pref_height = post.sampleHeight + 10.0;
  //double pref_width = post.sampleWidth + 10.0;
  //double aspect_ratio = pref_width / pref_height;
  //print(aspect_ratio);
  double modifier = 1;
  while ((post.sampleWidth) / modifier > width) {
    modifier += 0.1;
  }
  return modifier;
}

void searchSetWithPost(
    context, Post2 post, GlobalKey<ScaffoldState> key) async {
  showToast("Searching for Sets with this Post...", context);
  await getSetNamesWithID(context, post.id).then((listOfSets) {
    if (listOfSets.isNotEmpty) {
      //showInSnackBar('Got One!');
      var item = (listOfSets..shuffle()).first;
      Get.to(SearchPage(
        "set:" + item,
        postPageKey,
        popToHome: false,
      ));
    } else {
      //showInSnackBar('No Sets contain this Post!');
      log('Nope');
    }
  });
}

Widget StadiumBorderButton(
    context, IconData ico, TextEditingController controller, Widget target) {
  return RaisedButton(
    shape: StadiumBorder(),
    onPressed: () {
      Get.to(target);
    },
    child: Icon(ico),
  );
}

Future<Widget> suggestionBar(
    context, String currentTag, List<Post2> posts) async {
  List<Widget> tags = [];
  List<String> superTagList = [];
  log('Building Suggestions');
  if (posts.isEmpty) {
    if (globals.lastResults.isNotEmpty) {
      posts = globals.lastResults;
    } else {
      return SliverToBoxAdapter(child: Container());
    }
  }
  for (Post2 post in posts) {
    if (post.tags.isNotEmpty) {
      for (String tag in post.tags['character'] + post.tags['species']) {
        superTagList.add(tag);
      }
    }
  }
  globals.lastSearchTagResults =
      globals.lastSearchTagResults.followedBy(superTagList).toSet().toList();

  if (superTagList.length > 10) {
    superTagList.shuffle();
    superTagList = superTagList.getRange(0, 9).toList();
  }

  for (String itag in currentTag.split(' ')) {
    if (itag != '') {
      superTagList.add(itag);
    }
  }
  superTagList = superTagList.reversed.toList();
  //globals.lastSearchTagResults = superTagList;
  globals.lastResults = posts;
  for (String itag in superTagList) {
    tags.add(Card(
      shape: StadiumBorder(),
      child: Center(
          child: Container(
        child: Row(children: [
          SizedBox(
            width: 10.0,
          ),
          Text(itag),
          (currentTag.contains(itag))
              ? IconButton(
                  icon: Icon(FontAwesomeIcons.timesCircle),
                  onPressed: () {
                    Get.to(
                      SearchPage(
                          currentTag
                              .replaceFirst(itag, '')
                              .replaceAll('  ', ' '),
                          globals.postPageKey),
                    );
                  },
                )
              : IconButton(
                  icon: Icon(FontAwesomeIcons.plusCircle),
                  onPressed: () {
                    Get.to(SearchPage(
                        currentTag + ' ' + itag, globals.postPageKey));
                  },
                )
        ]),
        //width: 50,
      )),
    ));
  }
  log('Finished Building Suggestions');
  return SliverStickyHeader(
    header: Container(
        height: 60.0,
        //color: Colors.grey[850],
        //padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: tags,
        )),
  );
}

String truncateWithEllipsis(int cutoff, String myString) {
  return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
}

Widget waitingCard(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 135,
      height: 90,
      child: Card(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
            ),
            Center(
              child: GFLoader(),
            ),
            SizedBox(
              width: 10,
            ),
            Center(
              child: Text("Uploaded: "),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    ),
  );
}

enum ConfirmAction { CANCEL, ACCEPT }

class Destination {
  final String title;

  final IconData icon;
  final MaterialColor color;
  final Route path;

  const Destination(this.title, this.icon, this.color, this.path);
}

class TextBox extends StatelessWidget {
  final int transitionTime;
  final Alignment textLocation;
  final Color boxColor;
  final InputBorder fieldBorder;
  final String hintText;

  TextBox(
      {this.transitionTime = 1,
      this.textLocation = Alignment.centerLeft,
      this.boxColor = Colors.white,
      this.fieldBorder = InputBorder.none,
      this.hintText = 'Search'});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: transitionTime),
      alignment: textLocation,
      color: boxColor,
      child: TextField(
        decoration: InputDecoration(border: fieldBorder, hintText: hintText),
      ),
    );
  }
}

GridPostCardWidget(
    BuildContext contextGiven, List<Post2> posts, int index, bool replace,
    {IconData icon, Widget iconWidget, bool ignoreFav = false}) {
  bool favorited = false;
  List Favorites = globals.favoritesCache.keys.toList();
  return StatefulBuilder(builder: (innercontext, setState) {
    try {
      Widget cleanedArtistText(String cleanArtist) {
        if (cleanArtist.contains('conditional_dnp')) {
          cleanArtist = cleanArtist.replaceFirst('conditional_dnp', '');
          if (cleanArtist.startsWith(', ')) {
            cleanArtist = cleanArtist.replaceFirst(', ', '');
          } else if (cleanArtist.endsWith(', ')) {
            cleanArtist = cleanArtist.replaceRange(
                cleanArtist.length - 2, cleanArtist.length, '');
          } else if (cleanArtist.contains(', , ')) {
            cleanArtist = cleanArtist.replaceAll(', , ', ', ');
          }
        }

        return AutoSizeText(
          "Artist:" + ' ' + truncateWithEllipsis(20, cleanArtist),
          minFontSize: 8,
          maxFontSize: 50,
          style: TextStyle(fontSize: 14),
        );
      }

      double modifier = ((posts[index].sampleHeight < posts[index].sampleWidth)
          ? (posts[index].sampleHeight / posts[index].sampleWidth)
          : (posts[index].sampleWidth / posts[index].sampleHeight));
      double divisor = 1;
      if ((MediaQuery.of(contextGiven).size.width / 2) <
              posts[index].sampleWidth ||
          (MediaQuery.of(contextGiven).size.height / 2) <
              posts[index].sampleHeight) {
        divisor = 2;
      }
      FlareControls flareControls = FlareControls();

      if (((PrefService.getBool('likedThis') == null ||
          PrefService.getBool('likedThis') == true))) {
        if (!ignoreFav) {
          if (Favorites.contains(posts[index].id.toString())) {
            favorited = true;
          }
        }
      }

      return GestureDetector(
        child: Stack(children: [
          AnimatedContainer(
              duration: Duration(milliseconds: 250),
              child: GFCard(
                image: Image(
                  image: AdvancedNetworkImage(
                      getAppropriateImageQuality(posts[index])),
                  fit: determineScaling(),
                  filterQuality: FilterQuality.low,
                  alignment: Alignment.center,
                  height: posts[index].sampleHeight * (modifier / divisor),
                  width: posts[index].sampleWidth * (modifier / divisor),
                ),
                //content: thumbnailBuilder(context, posts[index]),
                titlePosition: GFPosition.end,
                semanticContainer: true,
                elevation: 2.5,
                margin: EdgeInsets.all(4),
                //padding: EdgeInsets.all(2),
                key: PageStorageKey(index),
                color: Colors.white12,
                title: GFListTile(
                  padding: EdgeInsets.all(2),
                  margin: EdgeInsets.all(4),
                  icon: (favorited
                      ? Icon(
                          FontAwesomeIcons.solidHeart,
                          size: 35,
                        )
                      : null),
                  title: (posts[index].tags['artist'] == null ||
                          posts[index].tags['artist'].isEmpty)
                      ? (AutoSizeText(
                          "Artist:" + ' ' + "Unknown",
                          style: TextStyle(fontSize: 14),
                          minFontSize: 12,
                          maxFontSize: 50,
                        ))
                      : cleanedArtistText(posts[index].tags['artist'][0]),
                  description: AutoSizeText(
                    "Score: " +
                        posts[index].scoreTotal.toString() +
                        ((PrefService.getBool('favCountChoice') == null ||
                                PrefService.getBool('favCountChoice') == true)
                            ? '\n❤️' + posts[index].fav_count.toString()
                            : '') +
                        "\n" +
                        "Uploaded: " +
                        fancyTimeDifferenceFromString(
                            contextGiven, posts[index].created_at),
                    minFontSize: 12,
                    maxFontSize: 50,
                    style: TextStyle(fontSize: 14),
                    maxLines: 3,
                  ),
                ),
              )),
          (posts[index].fileExt == 'webm')
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: posts[index].sampleHeight * (modifier / divisor),
                    child: Icon(
                      FontAwesomeIcons.playCircle,
                      color: getPanacheTheme().buttonColor,
                      size: 50,
                    ),
                    //width: post.sampleWidth + 0.0,
                    //height: post.sampleHeight + 0.0,
                  ),
                )
              : Container(),
          (posts[index].flags['deleted'] || posts[index].flags['flagged'])
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: posts[index].sampleHeight * (modifier / divisor),
                    child: Icon(
                      FontAwesomeIcons.skullCrossbones,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                )
              : Container(),
          Align(
            child: Container(
              height: posts[index].sampleHeight * (modifier / divisor),
              width: posts[index].sampleWidth * (modifier / divisor),
              child: FlareActor(
                'assets/instagram_like.flr',
                controller: flareControls,
                animation: 'idle',
              ),
            ),
            alignment: Alignment.center,
          ),
        ]),
        onTap: () {
          //print('Posts: ' + posts.toString());
          if (replace) {
            Get.to(PostDetail(
              posts[index],
              index: index,
              posts: posts,
            ));
          } else {
            Get.to(
              PostDetail(
                posts[index],
                index: index,
                posts: posts,
              ),
            );
          }
        },
        onDoubleTap: () async {
          setState(() {
            Favorites = globals.favoritesCache.keys.toList();
            favSwitcher(posts[index], dislikeAllowed: false);
            flareControls.play("like");
          });

          //showToast('Saved To Favorites', context);

          //await Future.delayed(Duration(seconds: 2));
        },
        onLongPress: () {
          galleryLRScroll(contextGiven, posts,
              currentIndex: index, replace: true);
        },
      );
    } catch (e) {
      print(e);
      return Container(
        height: 50,
        width: 50,
        child: Text(
          'This post failed to load, try again in a bit',
          style: TextStyle(color: Colors.black),
        ),
        color: Colors.orange,
      );
    }
  });
}

Widget voting(BuildContext context1, Post2 post,
    {bool stale = false, CancelToken token}) {
  bool upVoted = false;
  bool downVoted = false;
  bool doubleVote = false;
  Map<String, dynamic> scores;
  if (votingRecordTable['post-' + post.id.toString()] != null) {
    if (votingRecordTable['post-' + post.id.toString()] == 1) {
      upVoted = true;
    } else if (votingRecordTable['post-' + post.id.toString()] == -1) {
      downVoted = true;
    }
    stale = true;
  }
  return Container(
      //height: 120,
      child: StatefulBuilder(builder: (context, setState) {
    log('UpVote: ' + upVoted.toString());
    log('DownVote: ' + downVoted.toString());
    log('DoubleVote: ' + doubleVote.toString());
    if (stale) {
      getPostByID2(context1, post.id, token: token).then((value) {
        post = value;
        stale = false;
        setState(() {});
      });
    }
    return Container(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Align(
        child: AutoSizeText(
          'Score: ' +
              ((scores != null) ? scores['score'] : (post.scoreTotal))
                  .toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      Divider(
        color: getPanacheTheme().cardColor,
      ),
      (loggedIn())
          ? Align(
              child: AutoSizeText(
                'Vote',
                minFontSize: 25,
              ),
              //alignment: Alignment.center,
            )
          : Container(),
      (loggedIn())
          ? Container(
              color: getPanacheTheme().cardColor,
              child: Row(children: <Widget>[
                Expanded(
                    child: Container(
                        child: IconButton(
                            icon: Icon((upVoted)
                                ? FontAwesomeIcons.solidThumbsUp
                                : FontAwesomeIcons.thumbsUp),
                            onPressed: () async {
                              if (!upVoted) {
                                try {
                                  var response = await networkingPriority(
                                          refresh: true, token: token)
                                      .post(
                                          'https://e621.net/posts/' +
                                              post.id.toString() +
                                              '/votes.json?score=1&no_unvote=true',
                                          options: Options(headers: {
                                            'authorization':
                                                accountTable['basicAuth']
                                          }));
                                  if (doubleVote == true) {
                                    doubleVote = false;
                                  }
                                  if (response.data['our_score'] != 1) {
                                    doubleVote = true;
                                  }
                                  upVoted = true;
                                  downVoted = false;
                                  votingRecordTable[
                                      'post-' + post.id.toString()] = 1;
                                  unawaited(saveVotingRecord());
                                  log(response.data);
                                  scores = response.data;
                                  setState(() {});
                                } on DioError catch (e) {
                                  print(e.error);
                                }
                              } else {
                                try {
                                  var response = await networkingPriority(
                                          refresh: true, token: token)
                                      .post(
                                          'https://e621.net/posts/' +
                                              post.id.toString() +
                                              '/votes.json?score=1',
                                          options: Options(headers: {
                                            'authorization':
                                                accountTable['basicAuth']
                                          }));
                                  if (doubleVote == true) {
                                    doubleVote = false;
                                  }
                                  if (response.data['our_score'] != 0) {
                                    doubleVote = true;
                                  }
                                  upVoted = false;
                                  votingRecordTable[
                                      'post-' + post.id.toString()] = 0;
                                  unawaited(saveVotingRecord());
                                  downVoted = false;
                                  log(response.data);
                                  scores = response.data;
                                  setState(() {});
                                } on DioError catch (e) {
                                  print(e.error);
                                }
                              }
                            }))),
                Expanded(
                    child: Container(
                  child: Container(
                    child: IconButton(
                        icon: Icon((downVoted)
                            ? FontAwesomeIcons.solidThumbsDown
                            : FontAwesomeIcons.thumbsDown),
                        onPressed: () async {
                          if (!downVoted) {
                            try {
                              var response = await networkingPriority(
                                      refresh: true, token: token)
                                  .post(
                                      'https://e621.net/posts/' +
                                          post.id.toString() +
                                          '/votes.json?score=-1&no_unvote=true',
                                      options: Options(headers: {
                                        'authorization':
                                            accountTable['basicAuth']
                                      }));
                              if (doubleVote == true) {
                                doubleVote = false;
                              }
                              if (response.data['our_score'] != -1) {
                                doubleVote = true;
                              }
                              downVoted = true;
                              votingRecordTable['post-' + post.id.toString()] =
                                  -1;
                              unawaited(saveVotingRecord());
                              upVoted = false;
                              log(response.data);
                              scores = response.data;
                              setState(() {});
                            } on DioError catch (e) {
                              print(e.error);
                            }
                          } else {
                            try {
                              var response = await networkingPriority(
                                      refresh: true, token: token)
                                  .post(
                                      'https://e621.net/posts/' +
                                          post.id.toString() +
                                          '/votes.json?score=-1',
                                      options: Options(headers: {
                                        'authorization':
                                            accountTable['basicAuth']
                                      }));
                              if (doubleVote == true) {
                                doubleVote = false;
                              }
                              if (response.data['our_score'] != 0) {
                                doubleVote = true;
                              }
                              upVoted = false;
                              votingRecordTable['post-' + post.id.toString()] =
                                  0;
                              unawaited(saveVotingRecord());
                              downVoted = false;
                              print(response.data);
                              scores = response.data;
                              setState(() {});
                            } on DioError catch (e) {
                              print(e.error);
                            }
                          }
                        }),
                  ),
                ))
              ]))
          : Container()
    ]));
  }));
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

List<Widget> quoteHandler(BuildContext context, String body) {
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
        content: Text("Are you sure you want to open: $link ?"),
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

  List<Widget> quotes = [];
  while (body.contains('[quote]') &&
      body.contains('[/quote]') &&
      body.contains(' said:')) {
    //print(runOne);
    String quoteTarget = body.split('[quote]')[1].split('[/quote]')[0];
    quotes.add(Linkify(onOpen: _onOpen, text: body.split('[quote]')[0]));
    body = body.split('[/quote]')[1];
    //print(body);
    //print(quoteTarget.split('show/')[1].split(' said:')[0]);
    String quoteBody = quoteTarget.split(' said:')[1];
    //print(quoteBody);
    int userId;
    if (quoteTarget.contains('show/') && quoteTarget.contains(' said:')) {
      userId = int.parse(quoteTarget.split('show/')[1].split(' said:')[0]);
    }
    String userName;
    if (quoteTarget.contains('"')) {
      userName = quoteTarget.split('"')[1].split('"')[0];
    } else if (quoteTarget.contains(' said:')) {
      userName = quoteTarget.split(' said:')[0];
    }
    quotes.add(GFCard(
        content: makeASingleCommentView(context, quoteBody, userId, userName)));
    //runOne++;
  }
  quotes.add(Linkify(onOpen: _onOpen, text: body));
  return quotes;
}

Widget makeASingleCommentView(
    BuildContext context, String body, int userId, String userName,
    {CancelToken token, bool html = false}) {
  //print('get Comments');
  //print('get Avatars');
  List<Widget> bodyParts = [];
  String manipulatedBody = body;
  while (manipulatedBody.contains('Thumb #')) {
    bodyParts
        .addAll(quoteHandler(context, manipulatedBody.split('Thumb #')[0]));
    manipulatedBody = manipulatedBody.split('Thumb #')[1];
    if (manipulatedBody.contains(' ')) {
      bodyParts.add(FutureBuilder(
          future: getPostByID2(
              context, int.parse(manipulatedBody.split(' ')[0]),
              token: token),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image(
                  image: NetworkImage((snapshot.data as Post2).previewUrl));
            } else {
              return GFLoader();
            }
          }));
    } else {
      bodyParts.add(FutureBuilder(
          future:
              getPostByID2(context, int.parse(manipulatedBody), token: token),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (theGreatFilter2(snapshot.data)) {
                return GestureDetector(
                    child: Image(
                        image:
                            NetworkImage((snapshot.data as Post2).previewUrl)),
                    onTap: () {
                      Get.to(PostDetail(
                        snapshot.data,
                      ));
                    });
              } else {
                return Container();
              }
            } else {
              return GFLoader();
            }
          }));
      manipulatedBody = '';
    }
  }
  bodyParts.addAll(quoteHandler(context, manipulatedBody));
  //print(bodyParts);
  Widget rectifiedBody = Column(
    children: bodyParts,
  );
  return GFListTile(
    avatar: (userId != null)
        ? FutureBuilder(
            future: getCommentProfilePic(userName, userId, token: token),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                //print(comment.creatorId);
                //print(snapshot.data);
                return (snapshot.data != null)
                    ? GestureDetector(
                        child: GFAvatar(
                          backgroundImage: AdvancedNetworkImage(
                              (snapshot.data as Post2).sampleUrl),
                        ),
                        onTap: () {
                          Get.to(
                            PostDetail(
                              snapshot.data,
                            ),
                          );
                        },
                      )
                    : Container();
              } else {
                return GFLoader();
              }
            })
        : null,
    description: (!html) ? rectifiedBody : Html(data: body),
    title: SelectableText(
      userName,
      style: TextStyle(color: Colors.blue),
    ),
    padding: EdgeInsets.only(top: 0),
  );
}

Future<Widget> singleCommentView(BuildContext context, int commentID,
    {CancelToken token}) async {
  bool upVoted = false;
  bool downVoted = false;
  bool doubleVote = false;
  bool refresh = false;
  Map<String, dynamic> scores;
  if (votingRecordTable['comment-' + commentID.toString()] != null) {
    if (votingRecordTable['comment-' + commentID.toString()] == 1) {
      upVoted = true;
    } else if (votingRecordTable['comment-' + commentID.toString()] == -1) {
      downVoted = true;
    }
    refresh = true;
  }
  comment_models.Comment comment =
      await getSingleComment(commentID, refresh: refresh, token: token);
  return StatefulBuilder(builder: (context, setState) {
    bool enableVoting = loggedIn();
    List<Widget> bodyParts = [];
    String manipulatedBody = comment.body;
    //print(comment.body);
    while (manipulatedBody.contains('Thumb #')) {
      bodyParts
          .addAll(quoteHandler(context, manipulatedBody.split('Thumb #')[0]));
      //print(manipulatedBody);
      manipulatedBody = manipulatedBody.split('Thumb #')[1];

      if (manipulatedBody.contains(' ')) {
        bodyParts.add(FutureBuilder(
            future: getPostByID2(
                context, int.parse(manipulatedBody.split(' ')[0]),
                token: token),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image(
                    image: NetworkImage((snapshot.data as Post2).previewUrl));
              } else {
                return GFLoader();
              }
            }));
      } else {
        bodyParts.add(FutureBuilder(
            future:
                getPostByID2(context, int.parse(manipulatedBody), token: token),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (theGreatFilter2(snapshot.data)) {
                  return GestureDetector(
                      child: Image(
                          image: NetworkImage(
                              (snapshot.data as Post2).previewUrl)),
                      onTap: () {
                        Get.to(
                          PostDetail(
                            snapshot.data,
                          ),
                        );
                      });
                } else {
                  return Container();
                }
              } else {
                return GFLoader();
              }
            }));
        manipulatedBody = '';
      }
      //print(loop);
      //loop++;
    }

    //int loop = 0;

    bodyParts.addAll(quoteHandler(context, manipulatedBody));
    Widget voteUtility() {
      return Container(
          height: 120,
          child: Container(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                color: getPanacheTheme().cardColor,
                child: Row(children: <Widget>[
                  Container(
                      child: IconButton(
                          icon: Icon((upVoted)
                              ? FontAwesomeIcons.solidThumbsUp
                              : FontAwesomeIcons.thumbsUp),
                          onPressed: () async {
                            if (!upVoted) {
                              try {
                                var response = await networkingPriority(
                                        refresh: true, token: token)
                                    .post(
                                        'https://e621.net/comments/' +
                                            comment.id.toString() +
                                            '/votes.json?score=1&no_unvote=true',
                                        options: Options(headers: {
                                          'authorization':
                                              accountTable['basicAuth']
                                        }));
                                if (doubleVote == true) {
                                  doubleVote = false;
                                }
                                if (response.data['our_score'] != 1) {
                                  doubleVote = true;
                                }
                                upVoted = true;
                                votingRecordTable[
                                    'comment-' + commentID.toString()] = 1;
                                unawaited(saveVotingRecord());
                                downVoted = false;
                                log(response.data);
                                if (response.data.runtimeType != String) {
                                  scores = response.data;
                                }
                                setState(() {});
                              } on DioError catch (e) {
                                print(e.error);
                              }
                            } else {
                              try {
                                var response = await networkingPriority(
                                        refresh: true, token: token)
                                    .post(
                                        'https://e621.net/posts/' +
                                            comment.id.toString() +
                                            '/votes.json?score=1',
                                        options: Options(headers: {
                                          'authorization':
                                              accountTable['basicAuth']
                                        }));
                                //printWrapped(response.data);
                                if (doubleVote == true) {
                                  doubleVote = false;
                                }
                                upVoted = false;
                                votingRecordTable[
                                    'comment-' + commentID.toString()] = 0;
                                unawaited(saveVotingRecord());
                                downVoted = false;
                                log(response.data);
                                if (response.data.runtimeType != String) {
                                  scores = response.data;
                                }
                                setState(() {});
                              } on DioError catch (e) {
                                print(e.error);
                              }
                            }
                          })),
                  Container(
                    child: Container(
                      child: IconButton(
                          icon: Icon((downVoted)
                              ? FontAwesomeIcons.solidThumbsDown
                              : FontAwesomeIcons.thumbsDown),
                          onPressed: () async {
                            if (!downVoted) {
                              try {
                                var response = await networkingPriority(
                                        refresh: true, token: token)
                                    .post(
                                        'https://e621.net/comments/' +
                                            comment.id.toString() +
                                            '/votes.json?score=-1&no_unvote=true',
                                        options: Options(headers: {
                                          'authorization':
                                              accountTable['basicAuth']
                                        }));
                                if (doubleVote == true) {
                                  doubleVote = false;
                                }
                                if (response.data['our_score'] != -1) {
                                  doubleVote = true;
                                }
                                downVoted = true;
                                votingRecordTable[
                                    'comment-' + commentID.toString()] = -1;
                                unawaited(saveVotingRecord());
                                upVoted = false;
                                log(response.data);
                                if (response.data.runtimeType != String) {
                                  scores = response.data;
                                }
                                setState(() {});
                              } on DioError catch (e) {
                                print(e.error);
                              }
                            } else {
                              try {
                                var response = await networkingPriority(
                                        refresh: true, token: token)
                                    .post(
                                        'https://e621.net/comments/' +
                                            comment.id.toString() +
                                            '/votes.json?score=-1',
                                        options: Options(headers: {
                                          'authorization':
                                              accountTable['basicAuth']
                                        }));
                                if (doubleVote == true) {
                                  doubleVote = false;
                                }
                                if (response.data['our_score'] != 0) {
                                  doubleVote = true;
                                }
                                upVoted = false;
                                votingRecordTable[
                                    'comment-' + commentID.toString()] = 0;
                                unawaited(saveVotingRecord());
                                downVoted = false;
                                print(response.data);
                                if (response.data.runtimeType != String) {
                                  scores = response.data;
                                  comment.score = response.data['score'];
                                }
                                setState(() {});
                              } on DioError catch (e) {
                                print(e.error);
                              }
                            }
                          }),
                    ),
                  )
                ]))
          ])));
    }

    if (enableVoting) {
      bodyParts.add(voteUtility());
    }
    Widget rectifiedBody = Column(children: bodyParts);
    return GFCard(
        buttonBar: GFButtonBar(
          children: <Widget>[],
        ),
        content: rectifiedBody,
        title: GFListTile(
          avatar: FutureBuilder(
              future: getCommentProfilePic(
                  comment.creatorName, comment.creatorId,
                  token: token),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  //print(comment.creatorId);
                  //print(snapshot.data);
                  return (snapshot.data != null)
                      ? GestureDetector(
                          child: GFAvatar(
                            backgroundImage: AdvancedNetworkImage(
                                (snapshot.data as Post2).sampleUrl),
                          ),
                          onTap: () {
                            Get.to(
                              PostDetail(
                                snapshot.data,
                              ),
                            );
                          },
                        )
                      : Container();
                } else {
                  return GFLoader();
                }
              }),
          title: Row(children: [
            AutoSizeText('User: '),
            SelectableText(comment.creatorName)
          ]),
          subTitle: Row(children: [
            AutoSizeText('Score: '),
            AutoSizeText(
              (scores != null)
                  ? scores['score'].toString()
                  : comment.score.toString(),
              style: TextStyle(
                  color: (comment.score == 0)
                      ? Colors.orange
                      : (comment.score > 0) ? Colors.green : Colors.red),
            ),
          ]),
          description: Row(children: [
            AutoSizeText('Created: '),
            AutoSizeText(
                fancyTimeDifferenceFromString(context, comment.createdAt))
          ]),
          padding: EdgeInsets.only(top: 0),
        ));
  });
}

Widget singleCommentViewExperiment(BuildContext context, Comment2 comment,
    {CancelToken token}) {
  bool upVoted = false;
  bool downVoted = false;
  bool doubleVote = false;
  Map<String, dynamic> scores;
  if (votingRecordTable['comment-' + comment.id.toString()] != null) {
    if (votingRecordTable['comment-' + comment.id.toString()] == 1) {
      upVoted = true;
    } else if (votingRecordTable['comment-' + comment.id.toString()] == -1) {
      downVoted = true;
    }
  }
  return StatefulBuilder(builder: (context, setState) {
    bool enableVoting = loggedIn();
    Widget voteUtility() {
      return Container(
          //height: 120,
          child: Container(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            color: getPanacheTheme().cardColor,
            child: Row(children: <Widget>[
              Container(
                  child: IconButton(
                      icon: Icon((upVoted)
                          ? FontAwesomeIcons.solidThumbsUp
                          : FontAwesomeIcons.thumbsUp),
                      onPressed: () async {
                        if (!upVoted) {
                          try {
                            var response = await networkingPriority(
                                    refresh: true, token: token)
                                .post(
                                    'https://e621.net/comments/' +
                                        comment.id.toString() +
                                        '/votes.json?score=1&no_unvote=true',
                                    options: Options(headers: {
                                      'authorization': accountTable['basicAuth']
                                    }));
                            if (doubleVote == true) {
                              doubleVote = false;
                            }
                            if (response.data['our_score'] != 1) {
                              doubleVote = true;
                            }
                            upVoted = true;
                            votingRecordTable[
                                'comment-' + comment.id.toString()] = 1;
                            unawaited(saveVotingRecord());
                            downVoted = false;
                            log(response.data);
                            if (response.data.runtimeType != String) {
                              scores = response.data;
                            }
                            setState(() {});
                          } on DioError catch (e) {
                            print(e.error);
                          }
                        } else {
                          try {
                            var response = await networkingPriority(
                                    refresh: true, token: token)
                                .post(
                                    'https://e621.net/posts/' +
                                        comment.id.toString() +
                                        '/votes.json?score=1',
                                    options: Options(headers: {
                                      'authorization': accountTable['basicAuth']
                                    }));
                            //printWrapped(response.data);
                            if (doubleVote == true) {
                              doubleVote = false;
                            }
                            upVoted = false;
                            votingRecordTable[
                                'comment-' + comment.id.toString()] = 0;
                            unawaited(saveVotingRecord());
                            downVoted = false;
                            log(response.data);
                            if (response.data.runtimeType != String) {
                              scores = response.data;
                            }
                            setState(() {});
                          } on DioError catch (e) {
                            print(e.error);
                          }
                        }
                      })),
              Container(
                child: Container(
                  child: IconButton(
                      icon: Icon((downVoted)
                          ? FontAwesomeIcons.solidThumbsDown
                          : FontAwesomeIcons.thumbsDown),
                      onPressed: () async {
                        if (!downVoted) {
                          try {
                            var response = await networkingPriority(
                                    refresh: true, token: token)
                                .post(
                                    'https://e621.net/comments/' +
                                        comment.id.toString() +
                                        '/votes.json?score=-1&no_unvote=true',
                                    options: Options(headers: {
                                      'authorization': accountTable['basicAuth']
                                    }));
                            if (doubleVote == true) {
                              doubleVote = false;
                            }
                            if (response.data['our_score'] != -1) {
                              doubleVote = true;
                            }
                            downVoted = true;
                            votingRecordTable[
                                'comment-' + comment.id.toString()] = -1;
                            unawaited(saveVotingRecord());
                            upVoted = false;
                            log(response.data);
                            if (response.data.runtimeType != String) {
                              scores = response.data;
                            }
                            setState(() {});
                          } on DioError catch (e) {
                            print(e.error);
                          }
                        } else {
                          try {
                            var response = await networkingPriority(
                                    refresh: true, token: token)
                                .post(
                                    'https://e621.net/comments/' +
                                        comment.id.toString() +
                                        '/votes.json?score=-1',
                                    options: Options(headers: {
                                      'authorization': accountTable['basicAuth']
                                    }));
                            if (doubleVote == true) {
                              doubleVote = false;
                            }
                            if (response.data['our_score'] != 0) {
                              doubleVote = true;
                            }
                            upVoted = false;
                            votingRecordTable[
                                'comment-' + comment.id.toString()] = 0;
                            unawaited(saveVotingRecord());
                            downVoted = false;
                            print(response.data);
                            if (response.data.runtimeType != String) {
                              scores = response.data;
                              comment.score = response.data['score'];
                            }
                            setState(() {});
                          } on DioError catch (e) {
                            print(e.error);
                          }
                        }
                      }),
                ),
              )
            ]))
      ])));
    }

    Future<void> _onOpen(String link) async {
      if (await canLaunch(link)) {
        // set up the button
        Widget okButton = FlatButton(
          child: Text("Go for it", style: GoogleFonts.lexendDeca()),
          onPressed: () async {
            Get.back();
            await launch(link);
          },
        );
        Widget cancelButton = FlatButton(
          child: Text("Abort", style: GoogleFonts.lexendDeca()),
          onPressed: () {
            Get.back();
          },
        );
        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text("Links are scary!", style: GoogleFonts.lexendDeca()),
          content: Text(
            "Are you sure you want to open:\n\n" + link + " ?",
            style: GoogleFonts.lexendDeca(),
          ),
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

    return GFCard(
        buttonBar: GFButtonBar(
          children: <Widget>[],
        ),
        content: Column(children: [
          Html(
            data: comment.body,
            onLinkTap: _onOpen,
            shrinkWrap: true,
            style: {
              "blockquote": Style(
                  color: Colors.white,
                  padding: EdgeInsets.only(left: 20),
                  border: Border.all(color: Color.fromRGBO(66, 76, 70, 1)),
                  backgroundColor: Color.fromRGBO(66, 76, 85, 1),
                  //fontFamily: GoogleFonts.lexendDeca().fontFamily,
                  fontSize: FontSize(11),
                  after: "\n"),
              "a": Style(color: Color.fromRGBO(254, 209, 140, 1))
            },
          ),
          (enableVoting) ? voteUtility() : Container()
        ]),
        title: GFListTile(
          avatar: FutureBuilder(
              future: getCommentProfilePic(
                  comment.creator_name, comment.creator_id,
                  token: token),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  //print(comment.creatorId);
                  //print(snapshot.data);
                  return (snapshot.data != null)
                      ? GestureDetector(
                          child: GFAvatar(
                            backgroundImage: AdvancedNetworkImage(
                                (snapshot.data as Post2).sampleUrl),
                          ),
                          onTap: () {
                            Get.to(
                              PostDetail(
                                snapshot.data,
                              ),
                            );
                          },
                        )
                      : Container();
                } else {
                  return GFLoader();
                }
              }),
          title: Row(children: [
            AutoSizeText('User: '),
            SelectableText(comment.creator_name)
          ]),
          subTitle: Row(children: [
            AutoSizeText('Score: '),
            AutoSizeText(
              (scores != null)
                  ? scores['score'].toString()
                  : comment.score.toString(),
              style: TextStyle(
                  color: (comment.score == 0)
                      ? Colors.orange
                      : (comment.score > 0) ? Colors.green : Colors.red),
            ),
          ]),
          description: Row(children: [
            AutoSizeText('Created: '),
            AutoSizeText(
                fancyTimeDifferenceFromString(context, comment.created_at))
          ]),
          padding: EdgeInsets.only(top: 0),
        ));
  });
}

Widget simpleImagePreview(
    BuildContext contextGiven, List<Post2> posts, int index,
    {bool replace = false}) {
  // Adobe XD layer: 'Image Card' (group)
  double scaler(double value) {
    return value * 1.2;
  }

  return GestureDetector(
    child: Stack(
      children: <Widget>[
        Transform.translate(
          offset: Offset(2.75, scaler(184.0 - 100)),
          child:
              // Adobe XD layer: 'Text Block Zone' (shape)
              Container(
            width: scaler(254.0),
            height: scaler(218.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27.0),
              color: const Color(0xffe69744),
              border: Border.all(width: 1.0, color: const Color(0xff707070)),
              boxShadow: [
                BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(0, 3),
                    blurRadius: 6)
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0, scaler(111.0 - 100)),
          child:
              // Adobe XD layer: 'NoPath' (shape)
              Container(
            width: scaler(260.0),
            height: scaler(237.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27.0),
              image: DecorationImage(
                image: NetworkImage(posts[index].sampleUrl),
                fit: BoxFit.cover,
              ),
              border: Border.all(width: 1.0, color: const Color(0xff707070)),
              boxShadow: [
                BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(0, 3),
                    blurRadius: 6)
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(15, scaler(348.0 - 100)),
          child:
              // Adobe XD layer: 'Text' (text)
              SizedBox(
            width: scaler(236.0),
            height: scaler(100.0),
            child: AutoSizeText(
              'Score: ' +
                  posts[index].scoreTotal.toString() +
                  '\nFavCount: ' +
                  posts[index].fav_count.toString() +
                  '\n${fancyTimeDifferenceFromString(contextGiven, posts[index].updated_at)}',
              style: TextStyle(
                fontFamily: 'Segoe UI',
                fontSize: 15,
                color: const Color(0xffffffff),
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
    onTap: () {
      //print('Posts: ' + posts.toString());
      if (replace) {
        Get.to(PostDetail(
          posts[index],
          index: index,
          posts: posts,
        ));
      } else {
        Get.to(
          PostDetail(
            posts[index],
            index: index,
            posts: posts,
          ),
        );
      }
    },
    onLongPress: () {
      galleryLRScroll(contextGiven, posts, currentIndex: index, replace: true);
    },
  );
}
