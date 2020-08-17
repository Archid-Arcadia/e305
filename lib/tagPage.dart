import 'dart:core';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/getWiki.dart';
import 'package:e305/showToast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'globals.dart' as globals;
import 'postDefinition.dart';
import 'searchPage.dart';
import 'wikiDefinition.dart';

class TagPage extends StatefulWidget {
  final id;
  final String sort;
  final String tag;

  TagPage(this.id, this.tag, {this.sort = ''});

  @override
  _TagPageState createState() => _TagPageState(id, tag, sort: sort);
}

class _TagPageState extends State<TagPage> {
  final id;
  Post2 post;
  Wiki wiki;
  String tag;
  String sort = '';

  _TagPageState(this.id, this.tag, {String sort = ''});

  @override
  Widget build(BuildContext context) {
    String background = (post != null)
        ? post.fileUrl
        : 'https://cdn.dribbble.com/users/902865/screenshots/4814970/loading-opaque.gif';
    String artist = tag;
    String description = (wiki != null) ? wiki.body : ' ';
    getWiki(context, artist).then((val) {
      wiki = val;
      if (mounted) {
        setState(() {});
      }
      ;
    });
    return SafeArea(
        child: (Scaffold(
      body: Container(
        child: Stack(children: <Widget>[
          Stack(children: <Widget>[
            Positioned.fill(
              child: Image.network(
                background,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                    decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.transparent,
                        Colors.grey.withOpacity(0.25)
                      ]),
                  //color: Colors.black.withOpacity(0.1),
                )))
          ]),
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: BackButton(
              color: Colors.deepPurple,
              onPressed: () => Get.back(),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 0,
            child: Align(
              key: Key('SubTitle'),
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                height: 300,
                width: 300,
                child: SingleChildScrollView(
                  child: AutoSizeText(
                    description,
                    style: GoogleFonts.lexendDeca(
                        color: Colors.white, fontSize: 24),
                    maxFontSize: 24,
                    minFontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 350,
            left: 10,
            child: Align(
              key: Key('Title'),
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                height: 100,
                width: 150,
                child: AutoSizeText(
                  artist,
                  style: GoogleFonts.lexendDeca(
                      color: Colors.white, fontSize: 100),
                  maxFontSize: 200,
                  minFontSize: 20,
                  maxLines: 2,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 300,
            right: 35,
            child: Align(
              key: Key('Button'),
              alignment: Alignment.bottomRight,
              child: SizedBox(
                  height: 75,
                  width: 75,
                  child: FloatingActionButton(
                    onPressed: () => {
                      showToast('Following Artist', context),
                      if (!globals.follows.contains(artist))
                        {globals.follows.add(artist), globals.saveFollowList()}
                    },
                    child: Icon(FontAwesomeIcons.plus),
                  )),
            ),
          ),
          Positioned(
            bottom: 400,
            right: 35,
            child: Align(
              key: Key('Button'),
              alignment: Alignment.bottomRight,
              child: SizedBox(
                  height: 75,
                  width: 75,
                  child: FloatingActionButton(
                    backgroundColor: Colors.orange,
                    key: Key('Search_Artist'),
                    onPressed: () => {
                      Get.to(
                        SearchPage(artist + this.sort, globals.postPageKey),
                      )
                    },
                    child: Icon(FontAwesomeIcons.play),
                  )),
            ),
          ),
        ]),
      ),
    )));
  }

  @override
  void initState() {
    globals.pageNumber += 1;
    if (id is int) {
      getPostByID2(context, id).then((val) {
        post = val;
      });
    }
    if (id is String) {
      getTopPost2(context, id, 0, pageOwner: globals.pageNumber).then((val) {
        post = val;
        if (mounted) {
          setState(() {});
        }
        ;
      });
    }
    super.initState();
  }
}
