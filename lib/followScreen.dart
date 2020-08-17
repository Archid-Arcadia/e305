import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/searchPage.dart';
import 'package:e305/themeData.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:getflutter/getflutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'globals.dart' as globals;

class FollowScreen extends StatefulWidget {
  final List<String> follows;

  FollowScreen(this.follows);

  @override
  _FavoriteScreen createState() => _FavoriteScreen(follows);
}

class _FavoriteScreen extends State<FollowScreen> {
  final follows;

  _FavoriteScreen(this.follows);

  Widget genFollowList(context, List<String> follows) {
    List<Widget> followCards = [];
    follows.sort();
    for (String follow in follows) {
      Widget followCard = FutureBuilder(
        future: getTopImage2(context, follow, 0,
            pageOwner: globals.pageNumber,
            safeLock: true,
            thumbnail: false,
            animations: true),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return GFCard(
              boxFit: BoxFit.cover,
              height: MediaQuery.of(context).size.width,
              imageOverlay: AdvancedNetworkImage(snapshot.data,
                  cacheRule: CacheRule(maxAge: const Duration(days: 7))),
              titlePosition: GFPosition.end,
              title: GFListTile(
                icon: GFIconButton(
                  icon: Icon(FontAwesomeIcons.times),
                  onPressed: () {
                    globals.follows.remove(follow);
                    globals.saveFollowList();
                    if (mounted) {
                      setState(() {});
                    }
                    ;
                  },
                ),
              ),
              content: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                child: AutoSizeText(
                  follow,
                  style: GoogleFonts.lexendDeca(fontSize: 30),
                  minFontSize: 5,
                  maxFontSize: 50,
                  maxLines: 1,
                ),
                color: getPanacheTheme().bottomAppBarColor,
              ),
              buttonBar: GFButtonBar(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  GFButton(
                    onPressed: () {
                      Get.to(
                        SearchPage(follow, GlobalKey()),
                      );
                    },
                    text: 'Search',
                  )
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return GFCard(
              boxFit: BoxFit.cover,
              title: GFListTile(
                icon: GFIconButton(
                  icon: Icon(FontAwesomeIcons.times),
                  onPressed: () {
                    globals.follows.remove(follow);
                    globals.saveFollowList();
                    if (mounted) {
                      setState(() {});
                    }
                    ;
                  },
                ),
              ),
              //imageOverlay: AdvancedNetworkImage(snapshot.data),
              content: GFListTile(
                avatar: Icon(FontAwesomeIcons.ban),
                title: AutoSizeText(
                  follow,
                  style: GoogleFonts.lexendDeca(fontSize: 30),
                  minFontSize: 5,
                  maxFontSize: 50,
                  maxLines: 1,
                ),
              ),
              buttonBar: GFButtonBar(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  GFButton(
                    onPressed: () {
                      Get.to(
                        SearchPage(follow, GlobalKey()),
                      );
                    },
                    text: 'Search',
                  )
                ],
              ),
            );
          } else {
            return GFCard(
              boxFit: BoxFit.cover,
              title: GFListTile(
                icon: GFIconButton(
                  icon: Icon(FontAwesomeIcons.times),
                  onPressed: () {
                    globals.follows.remove(follow);
                    globals.saveFollowList();
                    if (mounted) {
                      setState(() {});
                    }
                    ;
                  },
                ),
              ),
              //imageOverlay: AdvancedNetworkImage(snapshot.data),
              content: GFListTile(
                avatar: GFLoader(),
                title: Text(follow),
              ),
              buttonBar: GFButtonBar(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  GFButton(
                    onPressed: () {
                      Get.to(
                        SearchPage(follow, GlobalKey()),
                      );
                    },
                    text: 'Search',
                  )
                ],
              ),
            );
          }
        },
      );
      followCards.add(followCard);
    }
    return ListView(children: followCards);
  }

  @override
  Widget build(BuildContext context) {
    return mindTheBottom(
      context,
      Scaffold(
        appBar: GFAppBar(
          title: AutoSizeText(
            "Follows",
            style: GoogleFonts.lexendDeca(fontSize: 14),
          ),
          centerTitle: true,
        ),
        body: genFollowList(context, follows),
      ),
    );
  }
}
