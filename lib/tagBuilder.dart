import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:e305/getWiki.dart';
import 'package:e305/globals.dart';
import 'package:e305/mediaManager.dart';
import 'package:e305/searchPage.dart';
import 'package:e305/showToast.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:e305/themeData.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:get/get.dart';
import 'package:getflutter/components/alert/gf_alert.dart';
import 'package:getflutter/components/button/gf_button.dart';
import 'package:getflutter/components/floating_widget/gf_floating_widget.dart';
import 'package:getflutter/getflutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preferences/preferences.dart';

import 'getPosts.dart';
import 'globals.dart' as globals;
import 'postDefinition.dart';
import 'ui-Toolkit.dart';

Widget tagger(Post2 post, context, pageOwner, {CancelToken token}) {
  globals.refreshTags();

  bool safe = (PrefService.getString('safe_choice') == 'SFW' ||
      PrefService.getString('safe_choice') == null);
  List<String> tags = [];
  Color tagToColor(String tag) {
    List<String> artist = post.tags['artist'].cast<String>().toList();
    if (artist.contains(tag)) {
      return Colors.blue;
    }
    List<String> general = post.tags['general'].cast<String>().toList();
    if (general.contains(tag)) {
      return Colors.deepOrangeAccent;
    }
    List<String> species = post.tags['species'].cast<String>().toList();
    if (species.contains(tag)) {
      return Colors.green;
    }
    List<String> character = post.tags['character'].cast<String>().toList();
    if (character.contains(tag)) {
      return Colors.pinkAccent;
    }
    List<String> copyright = post.tags['copyright'].cast<String>().toList();
    if (copyright.contains(tag)) {
      return Colors.white;
    }
    List<String> invalid = post.tags['invalid'].cast<String>().toList();
    if (invalid.contains(tag)) {
      return Colors.red;
    }
    List<String> lore = post.tags['lore'].cast<String>().toList();
    if (lore.contains(tag)) {
      return Colors.blueGrey;
    }
    List<String> meta = post.tags['meta'].cast<String>().toList();
    if (meta.contains(tag)) {
      return Colors.lime;
    }
  }

  for (String keys in post.tags.keys) {
    //print(post.tags[keys].runtimeType);
    tags.addAll(post.tags[keys].cast<String>().toList());
  }
  for (String tag in tags) {
    if (!globals.tags.contains(tag)) {
      globals.tags.add(tag);
    }
  }
  List<String> artists = post.tags['artist'].cast<String>().toList();
  post = defaultFilterFixer(post);
  return Container(
    child: ExpandablePanel(
      header: Column(children: [
        SizedBox(height: 10),
        Text(
          'Tags',
          style: GoogleFonts.lexendDeca(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 20),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 5),
      ]),
      collapsed: Text(tags.toString().substring(1, tags.toString().length - 1),
          softWrap: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lexendDeca(fontSize: 18)),
      expanded: GridView(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        primary: false,
        shrinkWrap: true,
        children: tags // split the text into an array
            .map(
              (String text) => FutureBuilder<String>(
                future: globals.tagThrottle.synchronized(() async {
                  return getTopImage2(context, text, 0,
                      safe: safe,
                      safeLock: safe,
                      pageOwner: pageOwner,
                      animations: false,
                      thumbnail: true,
                      priority: 3,
                      token: token);
                }),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        padding: EdgeInsets.all(5.0),
                        child: Material(
                            elevation: 2,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            child: InkWell(
                              child: Container(
                                height: 100,
                                width: 100,
                                child: Center(
                                  child: Text(
                                    text,
                                    style: GoogleFonts.lexendDeca(
                                        color: tagToColor(text),
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(1.0, 0.0),
                                            blurRadius: 10.0,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                          Shadow(
                                            offset: Offset(0.0, 1.0),
                                            blurRadius: 10.0,
                                            color:
                                                Color.fromARGB(125, 0, 0, 255),
                                          ),
                                        ],
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AdvancedNetworkImage(
                                      snapshot.data,
                                      useDiskCache: true,
                                      cacheRule: CacheRule(
                                          maxAge: const Duration(days: 30)),
                                    ),
                                    fit: determineScaling(),
                                    alignment: Alignment.center,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                              onLongPress: () async {
                                //log('getWiki');
                                String body =
                                    await getWiki(context, text).then((wiki) {
                                  return ((wiki.body) != null)
                                      ? (wiki.body)
                                      : ('No Wiki entry for this tag');
                                });
                                await showDialog(
                                    context: context,
                                    builder: (_) => GFFloatingWidget(
                                        child: GFAlert(
                                            title: text,
                                            titleTextStyle:
                                                GoogleFonts.lexendDeca(),
                                            type: GFAlertType.rounded,
                                            backgroundColor: getPanacheTheme()
                                                .backgroundColor,
                                            contentChild: Container(
                                              child: Scaffold(
                                                  body: ListView(
                                                children: <Widget>[
                                                  Image(
                                                      image: AdvancedNetworkImage(
                                                          snapshot.data,
                                                          useDiskCache: true,
                                                          cacheRule: CacheRule(
                                                              maxAge:
                                                                  const Duration(
                                                                      minutes:
                                                                          10))),
                                                      fit: determineScaling()),
                                                  Text(
                                                    body,
                                                    style: getPanacheTheme()
                                                        .primaryTextTheme
                                                        .bodyText2,
                                                  )
                                                ],
                                              )),
                                              height: 500,
                                            ),
                                            bottombar: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  GFButton(
                                                      shape:
                                                          GFButtonShape.pills,
                                                      text: 'Search: ' + text,
                                                      position: GFPosition.end,
                                                      onPressed: () {
                                                        Get.to(SearchPage(
                                                          text,
                                                          postPageKey,
                                                          replace: true,
                                                        ));
                                                      }),
                                                  GFButton(
                                                    shape: GFButtonShape.pills,
                                                    text: 'Block: ' + text,
                                                    position: GFPosition.end,
                                                    onPressed: () {
                                                      if (!blackList
                                                          .contains(text)) {
                                                        globals.blackList
                                                            .add(text);
                                                        globals.saveBlackList();
                                                        showToast(
                                                            'BLOCKED', context);
                                                      }
                                                    },
                                                  )
                                                ]))));
                              },
                              onTap: () {
                                Get.to(
                                  SearchPage(
                                    text,
                                    postPageKey,
                                    replace: true,
                                  ),
                                );
                              },
                            )));
                  } else if (snapshot.hasError) {
                    log("${snapshot.error}");
                    return InkWell(
                      child: Container(
                        height: 10,
                        padding: EdgeInsets.all(5.0),
                        child: Container(
                          height: 100,
                          width: 100,
                          child: Center(
                            child: AutoSizeText(
                              text,
                              maxLines: 1,
                              minFontSize: 2,
                              maxFontSize: 15,
                              style: GoogleFonts.lexendDeca(
                                  color: tagToColor(text),
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
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AdvancedNetworkImage(post.previewUrl,
                                  useDiskCache: true,
                                  cacheRule: CacheRule(
                                      maxAge: const Duration(days: 1))),
                              fit: determineScaling(),
                              alignment: Alignment.center,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      onLongPress: () async {
                        log('getWiki');
                        String body = await getWiki(context, text).then((wiki) {
                          return ((wiki.body) != null)
                              ? (wiki.body)
                              : ('No Wiki entry for this tag');
                        });
                        await showDialog(
                            context: context,
                            builder: (_) => NetworkGiffyDialog(
                                  buttonOkText: Text("Search" +
                                      ': ' +
                                      truncateWithEllipsis(10, text)),
                                  buttonCancelText: Text("Block"),
                                  onCancelButtonPressed: () {
                                    if (!blackList.contains(text)) {
                                      globals.blackList.add(text);
                                      globals.saveBlackList();
                                      showToast('BLOCKED', context);
                                    }
                                  },
                                  image: Image(
                                      image: AdvancedNetworkImage(
                                          post.previewUrl,
                                          useDiskCache: true,
                                          cacheRule: CacheRule(
                                              maxAge:
                                                  const Duration(minutes: 10))),
                                      fit: determineScaling()),
                                  title: Text(text,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lexendDeca(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600)),
                                  description: (Text(
                                    truncateWithEllipsis(128, body),
                                    style: GoogleFonts.lexendDeca(fontSize: 10),
                                  )),
                                  onOkButtonPressed: () {
                                    Get.to(
                                      SearchPage(
                                        text,
                                        postPageKey,
                                        replace: true,
                                      ),
                                    );
                                  },
                                ));
                      },
                      onTap: () {
                        Get.to(SearchPage(
                          text,
                          postPageKey,
                          replace: true,
                        ));
                      },
                    );
                  }
                  return MaterialButton(
                    child: Card(
                        child: Center(
                            child: AutoSizeText(
                      text,
                      maxLines: 1,
                      minFontSize: 2,
                      maxFontSize: 15,
                      style: GoogleFonts.lexendDeca(
                        color: tagToColor(text),
                      ),
                    ))),
                    onLongPress: () async {
                      log('getWiki');
                      String body = await getWiki(context, text, priority: 1)
                          .then((wiki) {
                        return ((wiki.body) != null)
                            ? (wiki.body)
                            : ('No Wiki entry for this tag');
                      });
                      await showDialog(
                          context: context,
                          builder: (_) => NetworkGiffyDialog(
                                buttonOkText: Text("Search" + ': ' + text),
                                buttonCancelText: Text("Block"),
                                onCancelButtonPressed: () {
                                  if (!blackList.contains(text)) {
                                    globals.blackList.add(text);
                                    globals.saveBlackList();
                                    showToast('BLOCKED', context);
                                  }
                                },
                                image: Image(
                                    image: AdvancedNetworkImage(
                                      post.previewUrl,
                                      useDiskCache: true,
                                      cacheRule: CacheRule(
                                          maxAge: const Duration(days: 30)),
                                    ),
                                    fit: determineScaling()),
                                title: Text(text,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexendDeca(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600)),
                                description: (Text(
                                  truncateWithEllipsis(128, body),
                                  style: GoogleFonts.lexendDeca(fontSize: 10),
                                )),
                                onOkButtonPressed: () {
                                  Get.to(
                                    SearchPage(
                                      text,
                                      postPageKey,
                                      replace: true,
                                    ),
                                  );
                                },
                              ));
                    },
                    onPressed: () {
                      Get.to(SearchPage(
                        text,
                        postPageKey,
                        replace: true,
                      ));
                    },
                  );
                },
              ),
            )
            .toList(), // convert the iterable to a list
      ),
    ),
  );
}
