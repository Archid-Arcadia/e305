import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:e305/mediaManager.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:e305/themeData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:getflutter/components/accordian/gf_accordian.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/getflutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'getPosts.dart';
import 'postDefinition.dart';
import 'postDetailPage.dart';

Future<Widget> childrenView(BuildContext context, Post2 post_source, int index,
    {CancelToken token}) async {
  try {
    List<Widget> children = [];
    List<int> childrenPosts = [];
    if (post_source.children != null) {
      childrenPosts = post_source.children.cast();
    }
    if (post_source.parent_id != null) {
      if (childrenPosts.isNotEmpty) {
        childrenPosts.add(post_source.parent_id);
      } else {
        childrenPosts.add(post_source.parent_id);
      }
    }
    List<Post2> approvedPosts = [];
    for (int id in childrenPosts) {
      var postID = await getPostByID2(context, id, token: token);
      if (await theGreatFilter2(postID)) {
        approvedPosts.add(postID);
      }
    }
    List<Post2> approvedPostsWOrigin = [];
    approvedPostsWOrigin.addAll(approvedPosts);
    approvedPostsWOrigin.add(post_source);
    for (Post2 post in approvedPosts) {
      int index = approvedPosts.indexWhere((element) {
        return element == post;
      });
      children.add(Padding(
        padding: const EdgeInsets.only(left: 2.0, right: 2.0),
        child: RaisedButton.icon(
          label: AutoSizeText(post.id.toString()),
          icon: GFAvatar(
            shape: GFAvatarShape.standard,
            backgroundImage: AdvancedNetworkImage(post.previewUrl,
                cacheRule: CacheRule(maxAge: const Duration(days: 7))),
          ),
          onPressed: () {
            Navigator.push(context, CupertinoPageRoute(builder: (context) {
              return PostDetail(
                post,
                index: index,
                posts: approvedPostsWOrigin,
              );
            }));
//            Get.to(PostDetail(
//              post,
//              index: index,
//              posts: approvedPostsWOrigin,
//            ));
          },
          onLongPress: () {
            galleryLRScroll(context, approvedPostsWOrigin, currentIndex: index);
          },
        ),
      ));
    }
    return (approvedPosts.isNotEmpty)
        ? GFAccordion(
      collapsedTitlebackgroundColor: getPanacheTheme().cardTheme.color,
            expandedTitlebackgroundColor: getPanacheTheme().backgroundColor,
            textStyle: GoogleFonts.lexendDeca(),
            contentbackgroundColor: getPanacheTheme().scaffoldBackgroundColor,
            title: (post_source.parent_id == null) ? "Children" : "Parent",
            contentChild: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                alignment: Alignment.center,
                //width: MediaQuery.of(context).size.width,
                height: 50,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: children,
                )),
          )
        : Container();
  } catch (e) {
    print(e);
    return Container();
  }
}
