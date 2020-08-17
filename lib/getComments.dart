import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:e305/commentDefinition.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/models/Comment.dart' as comment_models;
import 'package:e305/networking.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:synchronized/synchronized.dart' as sync;
import 'package:xml/xml.dart' as xml;
import 'package:xml2json/xml2json.dart';

import 'postDefinition.dart';
import 'ui-Toolkit.dart';

Future<List<Comment2>> getComments2(Post2 post,
    {priority = 1, CancelToken token}) async {
  var rng = Random();
  var response =
      await networkingPriority(priority: priority, token: token, refresh: true)
          .get(
              'https://e621.net/comments.atom?search%5Bpost_id%5D=' +
                  post.id.toString(),
              cancelToken: token);
  if (response.statusCode == 200) {
    List<Comment2> commentList = [];
    String commentsXml = response.data;
    var atomDoc = xml.parse(commentsXml);
    var atomIDs = atomDoc.findAllElements('id');
    List<String> part2 = [];
    for (var id in atomIDs) {
      if (id.toString().contains(':Comment/')) {
        part2.add(id.toString().split(':Comment/')[1].split('</id>')[0]);
      }
    }

    for (String commentId in part2) {
      var response = await networkingPriority(priority: priority, token: token)
          .get('https://e621.net/comments/' + commentId + '.json',
              cancelToken: token);
      var data = response.data;
      commentList.add(Comment2(
          data['id'],
          data['post_id'],
          data['creator_id'],
          data['body'],
          data['score'],
          data['created_at'],
          data['updated_at'],
          data['updater_id'],
          data['do_not_bump_post'],
          data['is_hidden'],
          data['is_sticky'],
          data['creator_name'],
          data['updater_name']));
    }
    return commentList;
  } else if (response.statusCode == 503) {
    int wait = (rng.nextDouble() * 10).toInt();
    log(post.id.toString() +
        ' Comments> Hard-Limit --- Waiting:' +
        wait.toString());
    await Future.delayed(Duration(seconds: wait));
    return getComments2(post);
  } else {
    return getComments2(post);
  }
}

Future<List<Comment2>> getCommentsExperiment(Post2 post,
    {CancelToken token}) async {
  List<Comment2> comments = [];
  if (post.comment_count > 0) {
    var htmlQuery =
        await networkingPriority(priority: 0, token: token, refresh: true).get(
            'https://e621.net/posts/' + post.id.toString(),
            cancelToken: token);
    String commentHtmlXml = htmlQuery.data;

    var document = html_parser.parse(commentHtmlXml);
    List<dom.Element> commentElement =
        document.body.getElementsByClassName('list-of-comments');
    if (commentElement.isNotEmpty) {
      //print(commentElement[0].text);
      dom.Element list_of_comments = commentElement[0];
      List<dom.Element> comment_post_grids =
          list_of_comments.getElementsByClassName("comment comment-post-grid ");
      if (comment_post_grids.isNotEmpty) {
        for (dom.Element comment_grid in comment_post_grids) {
          //print(comment_grid.attributes['data-creator']);
          String author = comment_grid.attributes['data-creator'];
          //print(comment_grid.attributes['data-score']);
          String score = comment_grid.attributes['data-score'];
          //print(comment_grid.attributes['data-creator-id']);
          String authorID = comment_grid.attributes['data-creator-id'];
          String commentID = comment_grid.attributes['data-comment-id'];
          dom.Element content = comment_grid
              .getElementsByClassName('content')[0]
              .getElementsByClassName('body styled-dtext')[0];
          //print(content.innerHtml);
          String body = content.innerHtml;
          String post_time = comment_grid
              .getElementsByClassName('post-time')[0]
              .getElementsByTagName('time')[0]
              .attributes['datetime'];
          //print(post_time);
          comments.add(commentBuilder(
              id: int.parse(commentID),
              updater_name: author,
              updater_id: int.parse(authorID),
              score: int.parse(score),
              post_id: post.id,
              creator_name: author,
              creator_id: int.parse(authorID),
              updated_at: post_time,
              created_at: post_time,
              body: body,
              do_not_bump_post: false,
              is_hidden: false,
              is_sticky: false));
        }
      }
    }
  }
  return comments;
}

Future<List<Comment2>> getCommentsPlain(Post2 post, {CancelToken token}) async {
  List<Comment2> comments = [];
  if (post.comment_count > 0) {
    final myTransformer = Xml2Json();
    var response =
        await networkingPriority(priority: 0, token: token, refresh: true).get(
            'https://e621.net/comments.atom?search%5Bpost_id%5D=' +
                post.id.toString(),
            cancelToken: token);

    if (response.statusCode == 200) {
      String commentsXml = response.data;

      myTransformer.parse(commentsXml);
      Map<String, dynamic> xmlJson =
          Map<String, dynamic>.from(jsonDecode(myTransformer.toBadgerfish()));
      //print(xmlJson['feed']['entry']);
      //print('RAW: ' + xmlJson['feed']['entry'].toString());
      if (post.comment_count == 1) {
        var p = xmlJson['feed']['entry'];
//        print('Content: ' +
//            p['content']['\$']
//                .split('"/>\\n\\n')[1]
//                .split('<p>')[1]
//                .split('</p>')[0]
//                .toString());
//        print('ID: ' + p['id']['\$'].split('Comment/')[1].toString());
//        print('Published: ' + p['published']['\$'].toString());
//        print('Updated: ' + p['updated']['\$'].toString());
//        print('Link: ' + p['link']['@href'].toString());
//        print('Title: ' + p['title']['\$'].toString());
//        print('Author_Name: ' + p['author']['name']['\$'].toString());
//        print(
//            'Author_ID: ' + p['author']['uri']['\$'].substring(23).toString());
//        print((p as Map).keys);
        comments.add(commentBuilder(
            id: int.parse(p['id']['\$'].split('Comment/')[1]),
            body: p['content']['\$']
                .split('"/>\\n\\n')[1]
                .split('<p>')[1]
                .split('</p>')[0]
                .toString(),
            created_at: p['updated']['\$'].toString(),
            updated_at: p['updated']['\$'].toString(),
            creator_id: int.parse(p['author']['uri']['\$'].substring(23)),
            creator_name: p['author']['name']['\$'].toString(),
            post_id: post.id,
            score: 0,
            updater_id: int.parse(p['author']['uri']['\$'].substring(23)),
            updater_name: p['author']['name']['\$'].toString()));
      } else {
        for (var p in xmlJson['feed']['entry']) {
//          print('Content: ' +
//              p['content']['\$']
//                  .split('"/>\\n\\n')[1]
//                  .split('<p>')[1]
//                  .split('</p>')[0]
//                  .toString());
//          print('ID: ' + p['id']['\$'].split('Comment/')[1].toString());
//          print('Published: ' + p['published']['\$'].toString());
//          print('Updated: ' + p['updated']['\$'].toString());
//          print('Link: ' + p['link']['@href'].toString());
//          print('Title: ' + p['title']['\$'].toString());
//          print('Author_Name: ' + p['author']['name']['\$'].toString());
//          print('Author_ID: ' +
//              p['author']['uri']['\$'].substring(23).toString());
//          print((p as Map).keys);
          comments.add(commentBuilder(
              id: int.parse(p['id']['\$'].split('Comment/')[1]),
              body: p['content']['\$']
                  .split('"/>\\n\\n')[1]
                  .split('<p>')[1]
                  .split('</p>')[0]
                  .toString(),
              created_at: p['updated']['\$'].toString(),
              updated_at: p['updated']['\$'].toString(),
              creator_id: int.parse(p['author']['uri']['\$'].substring(23)),
              creator_name: p['author']['name']['\$'].toString(),
              post_id: post.id,
              score: 0,
              updater_id: int.parse(p['author']['uri']['\$'].substring(23)),
              updater_name: p['author']['name']['\$'].toString()));
        }
//        print('XML string');
        //print(goodXmlString);
//        print('');
      }
      return comments;
    }
  }
  return null;
}

Future<List<int>> getCommentIds(int id, {CancelToken token}) async {
  var response =
      await networkingPriority(priority: 0, token: token, refresh: true).get(
          'https://e621.net/comments.atom?search%5Bpost_id%5D=' + id.toString(),
          cancelToken: token);
  if (response.statusCode == 200) {
    String commentsXml = response.data;
    var atomDoc = xml.parse(commentsXml);
    var atomIDs = atomDoc.findAllElements('id');

    List<int> part2 = [];
    for (var id in atomIDs) {
      if (id.toString().contains(':Comment/')) {
        part2.add(
            int.parse(id.toString().split(':Comment/')[1].split('</id>')[0]));
      }
    }
    return part2;
  } else {
    return [];
  }
}

Future<comment_models.Comment> getSingleComment(int id,
    {bool refresh = false, CancelToken token}) async {
  var response = await networkingPriority(refresh: refresh, token: token).get(
      'https://e621.net/comments/' + id.toString() + '.json',
      cancelToken: token);
  comment_models.Comment comment =
      comment_models.Comment.fromJson(response.data);
  return comment;
}

sync.Lock profilePicLock = sync.Lock();

Future<Post2> getCommentProfilePic(String user, int userId,
    {CancelToken token}) async {
  return profilePicLock.synchronized(() async {
    var response = await networkingPriority(priority: 0, token: token)
        .get('https://e621.net/users/' + userId.toString(), cancelToken: token);
    Post2 image_path;
    if (response.statusCode == 200) {
      String commentsXml = response.data.toString();
      int postId;
      //print(commentsXml.contains('<div class="post-thumb placeholder" id="tp-'));
      if (commentsXml.contains('<div class="post-thumb placeholder" id="tp-')) {
        //print('yes');
        postId = int.parse(commentsXml
            .split('<div class="post-thumb placeholder" id="tp-')[1]
            .split('"')[0]);
        Post2 post = await getPostByID2(BuildContext, postId);
        if (theGreatFilter2(post)) {
          image_path = post;
        }
      }
      return image_path;
    } else {
      return image_path;
    }
  });
}
