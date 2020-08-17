import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:e305/cloudFlareDetector.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/mediaManager.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:e305/themeData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:synchronized/synchronized.dart' as sync;

import 'globals.dart' as globals;
import 'networking.dart';
import 'poolDefenition.dart';
import 'postDefinition.dart';
import 'ui-Toolkit.dart';

final _poolLock = sync.Lock();
//Map<int, Pool2> poolThumbs = {};

Future<List<Pool2>> getPoolV2(context,
    {String query = '',
    int limit = 50,
    int page = 1,
    priority = 1,
    refresh = false,
    CancelToken token,
    overrideSpamGaurd = false}) async {
  log('Ran getPoolV2(' + query + ') at: ' + DateTime.now().second.toString());
  globals.lastRun = DateTime.now().second + 0.0;
  var data = await networkingPriority(
          priority: priority,
          refresh: refresh,
          token: token,
          overrideSpamGaurd: overrideSpamGaurd)
      .get(
          'https://e621.net/pools.json?limit=' +
              limit.toString() +
              '&page=' +
              page.toString() +
              '&search[name_matches]=' +
              Uri.encodeComponent(query),
          cancelToken: token);
  flareDetect(context, data);
  if (data.statusCode == 200) {
    List<Pool2> results = [];
    var jsonData = data.data;
    for (var p in jsonData) {
      Pool2 pool = Pool2(
          p['id'],
          p['name'],
          p['creator_id'],
          p['description'],
          p['is_active'],
          p['post_ids'],
          p['is_deleted'],
          p['created_at'],
          p['updated_at'],
          p['category'],
          p['creator_name'],
          p['post_count']);
      if (pool.post_count > 0) {
        results.add(pool);
      }
    }
    return results;
  } else if (data.statusCode == 503) {
    log('Failed to Load pool, Hard-Limit');
    await Future.delayed(Duration(seconds: 1));
    return getPoolV2(context, query: query, refresh: refresh, token: token);
  } else {
    log(data.statusCode);
    return [];
  }
}

Future<Pool2> populatePool(int id,
    {page = 0,
    bool lock = false,
    priority = 1,
    refresh = false,
    bool just1 = false,
    CancelToken token}) async {
  page = page + 1;
  //print(query);
  //final Dio poolDio = Dio();
  globals.postLock = true;
  Response response;
  if (lock) {
    response = await _poolLock.synchronized(() async {
      //await Future.delayed(Duration(milliseconds: 250));
      Response response = await networkingPriority(
              priority: priority, refresh: refresh, token: token)
          .get('https://e621.net/pools/' + id.toString() + '.json',
              cancelToken: token);
      while (response.statusCode == 503) {
        log(503.toString() + '| Pool: ' + id.toString());
        await Future.delayed(Duration(seconds: 1));
        response = await networkingPriority(
                priority: priority, refresh: refresh, token: token)
            .get('https://e621.net/pools/' + id.toString() + '.json',
                cancelToken: token);
      }
      return response;
    });
  } else {
    response = await networkingPriority(
            priority: priority, refresh: refresh, token: token)
        .get('https://e621.net/pools/' + id.toString() + '.json',
            cancelToken: token);
    while (response.statusCode == 503) {
      log(503.toString() + '| Pool: ' + id.toString());
      await Future.delayed(Duration(milliseconds: 500));
      response = await networkingPriority(
              priority: priority, refresh: refresh, token: token)
          .get('https://e621.net/pools/' + id.toString() + '.json',
              cancelToken: token);
    }
  }
  globals.postLock = false;
  //print(response);
  var data = response.data;
  //print(data.runtimeType);
  //print('----------------------------------------------------------');
  Pool2 result = Pool2(
      data['id'],
      data['name'],
      data['creator_id'],
      data['description'],
      data['is_active'],
      data['post_ids'],
      data['is_deleted'],
      data['created_at'],
      data['updated_at'],
      data['category'],
      data['creator_name'],
      data['post_count']);
  List<Post2> posts = [];
  for (int post_id in data['post_ids']) {
    //print(jPost);
    Post2 post = await getPostByID2(BuildContext, post_id);
    if (just1) {
      result.posts = [post];
      return result;
    }
    if (await theGreatFilter2(post)) {
      posts.add(post);
    }
  }
  result.posts = posts;
  return result;
}

final _poolThumbLock = sync.Lock();

Future<Map<String, dynamic>> poolThumbnail(Pool2 pool,
    {priority = 1, CancelToken token, bool lock = true}) async {
  var poolThumbs = await Hive.box('poolThumbs');
  Pool2 buildPool;
  Post2 chosenPost;
  Map<String, dynamic> response = {'Widget': null, 'Pass': false};
  try {
    if (poolThumbs.containsKey(pool.id)) {
      //print('Using cache thumb');
      buildPool = poolThumbs.get(pool.id);
      log(pool.name + ': ' + buildPool.posts.toString());
      if (buildPool.posts != null) {
        if (buildPool.posts.isNotEmpty) {
          if (buildPool.posts[0] != null) {
            chosenPost = buildPool.posts[0];
          } else {
            await poolThumbs.delete(pool.id);
          }
        }
      }
    } else {
      if (lock) {
        await _poolThumbLock.synchronized(() async {
          await getFirstPostInPool(pool.name).then((Post2 firstPost) {
            if (firstPost != null) {
              pool.posts = [firstPost];
              //log(pool.posts);
              poolThumbs.put(pool.id, pool);
            }
            buildPool = pool;
          });
        });
      } else {
        Random rng = Random();
        await Future.delayed(Duration(milliseconds: 100 * rng.nextInt(10)));
        await getFirstPostInPool(pool.name).then((Post2 firstPost) {
          if (firstPost != null) {
            pool.posts = [firstPost];
            //log(pool.posts);
            poolThumbs.put(pool.id, pool);
          }
          buildPool = pool;
        });
      }
      if (buildPool.posts.isNotEmpty) {
        chosenPost = defaultFilterFixer(buildPool.posts[0]);
//          poolThumbCatalog[pool.id.toString()] =
//              jsonEncode(chosenPost.toJson());
//          await savePoolThumbCatalog();

      }
    }
    int height = 50;
    if (chosenPost != null) {
//      if (highRes()) {
//        height = chosenPost.sampleHeight.clamp(50, 500);
//      } else {
//        height = chosenPost.previewHeight.clamp(50, 100);
//      }
      height = highRes() ? 350 : 150;
    }

    Widget payload = Container(
        //width: (chosenPost != null) ? chosenPost.sampleWidth + 0.0 : null,
        child: Stack(
      children: [
        Image(
          fit: determineScaling(),
          image: AdvancedNetworkImage(
              (chosenPost != null)
                  ? getAppropriateImageQuality(chosenPost)
                  : 'https://static1.e621.net/data/ac/44/ac441d5621196632104cf1ea680d6ec0.png',
              useDiskCache: true,
              height: (chosenPost != null) ? height : null,
              cacheRule: CacheRule(maxAge: const Duration(days: 7))),
          height: (chosenPost != null) ? height.toDouble() : 50,
        ),
        (chosenPost != null)
            ? !theGreatFilter2(chosenPost)
                ? Container(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                        child: Container(
                          height:
                              (chosenPost != null) ? height.toDouble() : null,
                          child: Center(
                              child: Icon(
                            FontAwesomeIcons.ban,
                            size: (chosenPost != null)
                                ? 175.toDouble()
                                : 75.toDouble(),
                            color: getPanacheTheme().accentColor,
                          )),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    height: (chosenPost != null) ? height.toDouble() : null,
                  )
                : Container()
            : Container()
      ],
      alignment: Alignment.center,
    ));
    response['Widget'] = payload;
    response['Pass'] = (chosenPost != null);
    return response;
  } catch (e) {
    print(e);
  }
  response = <String, dynamic>{
    'Widget': Container(
      height: highRes() ? 350 : 150,
    ),
    'Pass': false
  };
  return response;
}

Future<Post2> getFirstPostInPool(String pool_name) async {
  Map<String, Object> results = await getPosts2(BuildContext,
      tag: "order:id pool:" + pool_name + "", filter: false);
  if ((results['posts'] as List<Post2>).isNotEmpty) {
    return (results['posts'] as List<Post2>)[0];
  } else {
    return null;
  }
}

Future<Pool2> populatePoolExperiment(int id,
    {page = 0,
    bool lock = false,
    priority = 1,
    refresh = false,
    bool just1 = false,
    bool filter = true,
    CancelToken token}) async {
  //page = page + 1;
  //print(query);
  //final Dio poolDio = Dio();
  globals.postLock = true;
  Response response;
  if (lock) {
    response = await _poolLock.synchronized(() async {
      //await Future.delayed(Duration(milliseconds: 250));
      Response response = await networkingPriority(
              priority: priority, refresh: refresh, token: token)
          .get('https://e621.net/pools/' + id.toString() + '.json',
              cancelToken: token);
      while (response.statusCode == 503) {
        log(503.toString() + '| Pool: ' + id.toString());
        await Future.delayed(Duration(seconds: 1));
        response = await networkingPriority(
                priority: priority, refresh: refresh, token: token)
            .get('https://e621.net/pools/' + id.toString() + '.json',
                cancelToken: token);
      }
      return response;
    });
  } else {
    response = await networkingPriority(
            priority: priority, refresh: refresh, token: token)
        .get('https://e621.net/pools/' + id.toString() + '.json',
            cancelToken: token);
    while (response.statusCode == 503) {
      log(503.toString() + '| Pool: ' + id.toString());
      await Future.delayed(Duration(milliseconds: 500));
      response = await networkingPriority(
              priority: priority, refresh: refresh, token: token)
          .get('https://e621.net/pools/' + id.toString() + '.json',
              cancelToken: token);
    }
  }
  globals.postLock = false;
  //print(response);
  var data = response.data;
  //print(data.runtimeType);
  //print('----------------------------------------------------------');
  Pool2 result = Pool2(
      data['id'],
      data['name'],
      data['creator_id'],
      data['description'],
      data['is_active'],
      data['post_ids'],
      data['is_deleted'],
      data['created_at'],
      data['updated_at'],
      data['category'],
      data['creator_name'],
      data['post_count']);
  int remainder = result.post_count;
  List<Post2> posts = [];
  if (just1) {
    Post2 post = await getPostByID2(BuildContext, data['post_ids'][0]);
    result.posts = [post];
    return result;
  } else {
    Map<int, Post2> poolsPosts = {};
    while (remainder > 0) {
      remainder = remainder - 320;
      Map<String, Object> items = await getPosts2(BuildContext,
          tag: 'pool:' + id.toString(), page: page, filter: filter);
      for (Post2 post in items['posts']) {
        poolsPosts[post.id] = post;
      }
      page += 1;
    }
    for (int id in data['post_ids']) {
      if (poolsPosts.keys.contains(id)) {
        posts.add(poolsPosts[id]);
      }
    }
  }
  result.posts = posts;
  return result;
}
