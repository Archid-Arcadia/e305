import 'dart:core';
import 'dart:math';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:e305/cloudFlareDetector.dart';
import 'package:e305/loginManager.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:flutter/cupertino.dart';
import 'package:preferences/preferences.dart';
import 'package:synchronized/synchronized.dart' as sync;

import 'globals.dart' as globals;
import 'networking.dart';
import 'postDefinition.dart';
import 'ui-Toolkit.dart';

int lastRun = 0;

Future<Post2> getPostByID2(context, int id,
    {priority = 1, CancelToken token}) async {
  Post2 tempPost;
  String search = ('https://e621.net/posts/' + id.toString() + '.json');
  var data = await networkingPriority(priority: priority).get(search,
      options: buildCacheOptions(Duration(minutes: 10),
          maxStale: Duration(days: 10)),
      cancelToken: token);
  flareDetect(context, data);
  if (data.statusCode == 200) {
    var p = data.data['post'];
    globals.postLock = false;
    tempPost = Post2(
        id: p['id'],
        created_at: p['created_at'],
        updated_at: p['updated_at'],
        fileWidth: p['file']['width'],
        fileHeight: p['file']['height'],
        fileExt: p['file']['ext'],
        fileSize: p['file']['size'],
        fileMd5: p['file']['md5'],
        fileUrl: p['file']['url'],
        previewWidth: p['preview']['width'],
        previewHeight: p['preview']['height'],
        previewUrl: p['preview']['url'],
        sampleHas: p['sample']['has'],
        sampleHeight: p['sample']['height'],
        sampleWidth: p['sample']['width'],
        sampleUrl: p['sample']['url'],
        scoreUp: p['score']['up'],
        scoreDown: p['score']['down'],
        scoreTotal: p['score']['total'],
        tags: p['tags'],
        locked_tags: p['locked_tags'],
        change_seq: p['change_seq'],
        flags: p['flags'],
        rating: p['rating'],
        fav_count: p['fav_count'],
        sources: p['sources'],
        pools: p['pools'],
        parent_id: p['relationships']['parent_id'],
        has_children: p['relationships']['has_children'],
        has_active_children: p['relationships']['has_active_children'],
        children: p['relationships']['children'],
        approver_id: p['approver_id'],
        uploader_id: p['uploader_id'],
        description: p['description'],
        comment_count: p['comment_count'],
        is_favorited: p['is_favorited']);
    tempPost = defaultFilterFixer(tempPost);
    return tempPost;
  }
  return null;
}

sync.Lock upgradeLock = sync.Lock();
List<int> upgraded = [];

favoritesUpgrader(Map<String, dynamic> instance) async {
  try {
    int id = instance['id'];
    if (!upgraded.contains(id)) {
      print('Upgrading Post: ' + id.toString());
      Post2 upgrade = await upgradeLock.synchronized(() async {
        return defaultFilterFixer(await getPostByID2(BuildContext, id));
      });
      globals.favoritesCache[upgrade.id.toString()] = upgrade.toJson();
      globals.saveFavoritesCache();
      print('Upgrade Post: ' + id.toString() + ' [Complete]');
      upgraded.add(id);
    }
  } catch (e) {
    print('Upgrade: ' + e);
  }
}

Future<Map<String, Object>> getPosts2(context,
    {String tag = '',
    int page = 0,
    List<Post2> posts,
    bool holdLoad = false,
    int previousPostCount = 0,
    priority = 1,
    refresh = false,
    CancelToken token,
    bool fixFilter,
    bool filter = true,
    Options auth}) async {
  if (posts == null) {
    posts = [];
  }
  if (tag == null) {
    tag = '';
  }
  bool safe = (PrefService.getString('safe_choice') == 'SFW' ||
      PrefService.getString('safe_choice') == null);
  bool safeQ = (PrefService.getString('safe_choice') == 'KSFW');
  if (safe && !(tag.contains('rating:s') && !(safeQ))) {
    tag = tag + ' rating:s';
  } else if (safeQ) {
    tag = tag + ' -rating:e';
  }
//  while (globals.lastRun == DateTime.now().second) {
//    await Future.delayed(Duration(seconds: 1));
//  }

  log('Ran getPost(' + tag + ') at: ' + DateTime.now().second.toString());
  globals.lastRun = DateTime.now().second + 0.0;
  var rng = Random();
  page = page + 1;
  Response data;
  if (auth == null) {
    data = await networkingPriority(
            priority: priority, refresh: refresh, token: token)
        .get(
            'https://e621.net/posts.json?limit=320&' +
                'page=' +
                page.toString() +
                '&tags=' +
                Uri.encodeComponent(tag),
            cancelToken: token)
        .then((val) {
      //print('Exiting request');
      return val;
    });
  } else {
    data = await networkingPriority(
            priority: priority, refresh: refresh, token: token)
        .get(
            'https://e621.net/posts.json?limit=320&' +
                'page=' +
                page.toString() +
                '&tags=' +
                Uri.encodeComponent(tag),
            options: auth,
            cancelToken: token)
        .then((val) {
      //print('Exiting request');
      return val;
    });
  }
  //print(data.data);
  //log(data.body);

  flareDetect(context, data);

  if (data.statusCode == 200) {
    var jsonData = data.data['posts'];
    List<int> postIDs = [];
    for (Post2 oPost in posts) {
      postIDs.add(oPost.id);
    }
    for (var p in jsonData) {
      Post2 post = Post2(
          id: p['id'],
          created_at: p['created_at'],
          updated_at: p['updated_at'],
          fileWidth: p['file']['width'],
          fileHeight: p['file']['height'],
          fileExt: p['file']['ext'],
          fileSize: p['file']['size'],
          fileMd5: p['file']['md5'],
          fileUrl: p['file']['url'],
          previewWidth: p['preview']['width'],
          previewHeight: p['preview']['height'],
          previewUrl: p['preview']['url'],
          sampleHas: p['sample']['has'],
          sampleHeight: p['sample']['height'],
          sampleWidth: p['sample']['width'],
          sampleUrl: p['sample']['url'],
          scoreUp: p['score']['up'],
          scoreDown: p['score']['down'],
          scoreTotal: p['score']['total'],
          tags: p['tags'],
          locked_tags: p['locked_tags'],
          change_seq: p['change_seq'],
          flags: p['flags'],
          rating: p['rating'],
          fav_count: p['fav_count'],
          sources: p['sources'],
          pools: p['pools'],
          parent_id: p['relationships']['parent_id'],
          has_children: p['relationships']['has_children'],
          has_active_children: p['relationships']['has_active_children'],
          children: p['relationships']['children'],
          approver_id: p['approver_id'],
          uploader_id: p['uploader_id'],
          description: p['description'],
          comment_count: p['comment_count'],
          is_favorited: p['is_favorited']);
      if ((filter) ? await theGreatFilter2(post) : true) {
        if (!postIDs.contains(post.id)) {
          postIDs.add(post.id);
          posts.add(defaultFilterFixer(post));
        } else {
          //log('Failed post already in list');
        }
      } else {}
    }
    //log('Skipped: ' + skipped.toString());
    //log(posts.length.toString());
    if (posts.length == previousPostCount) {
      holdLoad = true;
    }
    previousPostCount = posts.length;
    //log(previousPostCount);
    var _results = {
      'posts': posts,
      'page': page,
      'holdLoad': holdLoad,
      'previousPostCount': previousPostCount,
    };
    return _results;
  } else if (data.statusCode == 503) {
    log('Failed to Load posts, Hard-Limit', type: 'GetPost 503 Error');
    await Future.delayed(Duration(seconds: rng.nextInt(5).clamp(1, 5)));
    return getPosts2(context,
        tag: tag,
        page: page,
        posts: posts,
        holdLoad: holdLoad,
        previousPostCount: previousPostCount,
        priority: priority,
        token: token);
  } else {
    log(data.statusCode, type: 'GetPost Unexpected StatusCode Error');
  }
  return null;
}

Future<Map<String, Object>> getPostsIfChanged2(context,
    {String tag = '',
    int page = 0,
    List<Post2> posts,
    bool holdLoad = false,
    int previousPostCount = 0,
    int minutes = 1,
    priority = 1,
    CancelToken token}) async {
  if (globals.homeRecent != null &&
      globals.lastHomeRecentLoad != null &&
      PrefService.getString('safe_choice') == globals.lastSafe) {
    if (globals.lastHomeRecentLoad.difference(DateTime.now()).abs() <=
        Duration(minutes: minutes)) {
      log(
          'Will Reload: HomeRecent: ' +
              (Duration(minutes: minutes) -
                      globals.lastHomeRecentLoad
                          .difference(DateTime.now())
                          .abs())
                  .toString(),
          type: 'Home Reload Spam block');
      return Future(() {
        return globals.homeRecent;
      });
    }
  }
  Map<String, Object> data;
  await getPosts2(context,
          tag: tag,
          page: page,
          posts: posts,
          holdLoad: holdLoad,
          previousPostCount: previousPostCount,
          priority: priority,
          token: token)
      .then((val) {
    data = val;
  });
  globals.homeRecent = data;
  globals.lastSafe = PrefService.getString('safe_choice');
  globals.lastHomeRecentLoad = DateTime.now();
  log('Reloaded: HomeRecent: ' + globals.lastHomeRecentLoad.toString());
  //log(data);
  return data;
}

Future<String> getTopImage2(context, String tag, int attempts,
    {bool safe = true,
    bool safeLock = false,
    int pageOwner = 0,
    bool animations = false,
    bool thumbnail = true,
    priority = 1,
    CancelToken token}) async {
  if (pageOwner == 0) {
    pageOwner = globals.pageNumber;
  }
  bool safe = (PrefService.getString('safe_choice') == 'SFW' ||
      PrefService.getString('safe_choice') == null);
  bool safeQ = (PrefService.getString('safe_choice') == 'KSFW');
  String r = 'e';
  String modifier = '';
  if (safe) {
    r = 's';
  }
  if (safeQ) {
    r = 'e';
    modifier = '-';
  }
  String search = ('https://e621.net/posts.json?tags=' +
      (Uri.encodeComponent(tag +
              ((animations) ? ' -type:swf ' : ' -animation ') +
              modifier +
              'rating:' +
              r +
              ' ') +
          'order:score'));

  var rng = Random();
  //print('$tag: ' + globals.tagCacheHelper[search].toString());

  if (globals.tagCacheHelper[search] == null) {
    //log('New tag being Cached: ' + tag);
//    while (globals.postLock) {
//      await Future.delayed(Duration(milliseconds: 333));
//    }
    if (globals.pageNumber != pageOwner) {
      log('killed request');
      return null;
    }

    globals.postLock = true;
    try {
      var data = await networkingPriority(priority: priority, token: token).get(
          search,
          options:
              buildCacheOptions(Duration.zero, maxStale: Duration(days: 30)),
          cancelToken: token);
      flareDetect(context, data);
      if (data.statusCode == 200) {
        var jsonData = data.data['posts'];
        //print(jsonData);
        Post2 onePost;
        Post2 tempPost;
        List<Post2> postList = [];
        globals.postLock = false;
        for (var p in jsonData) {
          tempPost = Post2(
              id: p['id'],
              created_at: p['created_at'],
              updated_at: p['updated_at'],
              fileWidth: p['file']['width'],
              fileHeight: p['file']['height'],
              fileExt: p['file']['ext'],
              fileSize: p['file']['size'],
              fileMd5: p['file']['md5'],
              fileUrl: p['file']['url'],
              previewWidth: p['preview']['width'],
              previewHeight: p['preview']['height'],
              previewUrl: p['preview']['url'],
              sampleHas: p['sample']['has'],
              sampleHeight: p['sample']['height'],
              sampleWidth: p['sample']['width'],
              sampleUrl: p['sample']['url'],
              scoreUp: p['score']['up'],
              scoreDown: p['score']['down'],
              scoreTotal: p['score']['total'],
              tags: p['tags'],
              locked_tags: p['locked_tags'],
              change_seq: p['change_seq'],
              flags: p['flags'],
              rating: p['rating'],
              fav_count: p['fav_count'],
              sources: p['sources'],
              pools: p['pools'],
              parent_id: p['relationships']['parent_id'],
              has_children: p['relationships']['has_children'],
              has_active_children: p['relationships']['has_active_children'],
              children: p['relationships']['children'],
              approver_id: p['approver_id'],
              uploader_id: p['uploader_id'],
              description: p['description'],
              comment_count: p['comment_count'],
              is_favorited: p['is_favorited']);
          if (p['file_ext'] != 'webm' && p['file_ext'] != 'swf') {
            postList.add(tempPost);
          }
        }
        try {
          onePost = (postList..shuffle()).first;
        } catch (e) {
          onePost = (postList..shuffle()).last;
        }
        onePost = defaultFilterFixer(onePost);
        if (thumbnail) {
          globals.tagCacheHelper[search] = onePost.previewUrl;
        } else {
          globals.tagCacheHelper[search] = onePost.sampleUrl;
        }
        globals.saveTagCacheHelper();
        return globals.tagCacheHelper[search];
      } else if (data.statusCode == 503) {
        log('Hard-limit');
        await Future.delayed(Duration(seconds: rng.nextInt(5).clamp(2, 5)));
        attempts += 1;
        globals.postLock = false;
        return getTopImage2(context, tag, attempts,
            safe: safe,
            safeLock: safeLock,
            priority: priority,
            animations: animations,
            thumbnail: thumbnail,
            pageOwner: pageOwner,
            token: token);
      }
    } on FormatException {
      await Future.delayed(Duration(seconds: attempts));
      if (attempts < 10) {
        globals.postLock = false;
        return getTopImage2(context, tag, attempts + 1,
            safe: safe,
            safeLock: safeLock,
            priority: priority,
            token: token,
            pageOwner: pageOwner,
            thumbnail: thumbnail,
            animations: animations);
      } else {
        throw (FormatException);
      }
    } on NoSuchMethodError {
      await Future.delayed(Duration(seconds: attempts));
      if (safe && !safeLock) {
        log(tag + ': Switching to UnSafe');
      }
      if (attempts < 10) {
        globals.postLock = false;
        return getTopImage2(context, tag, attempts + 1,
            safe: safe,
            safeLock: safeLock,
            priority: priority,
            token: token,
            animations: animations,
            thumbnail: thumbnail,
            pageOwner: pageOwner);
      } else {
        log('Timed Out');
        throw (NoSuchMethodError);
      }
    }
  } else {
    //log('Tag(' +
    //    tag +
    //    ') retrieved from Cache | ' +
    //    globals.tagCacheHelper.keys.length.toString() +
    //    ' Tags Cached.');
    return globals.tagCacheHelper[search];
  }
  return null;
}

Future<Post2> getTopPost2(context, String tag, int attempts,
    {bool safe = true,
    bool safeLock = false,
    int pageOwner = 0,
    bool animations = false,
    priority = 1,
    CancelToken token}) async {
  bool safe = (PrefService.getString('safe_choice') == 'SFW' ||
      PrefService.getString('safe_choice') == null);
  bool safeQ = (PrefService.getString('safe_choice') == 'KSFW');
  String r = 'e';
  String modifier = '';
  if (safe) {
    r = 's';
  }
  if (safeQ) {
    r = 'e';
    modifier = '-';
  }
  String search = ('https://e621.net/post/index.json?limit=10&tags=' +
      (Uri.encodeComponent(tag +
              ((animations) ? ' -type:swf -type:webm ' : ' -animation ') +
              modifier +
              'rating:' +
              r +
              ' ') +
          'order:score'));

  var rng = Random();
  log('New tag being Cached: ' + tag);

  if (globals.pageNumber != pageOwner) {
    log('killed request');
    return null;
  }

  globals.postLock = true;
  try {
    var data = await networkingPriority(priority: priority, token: token).get(
        search,
        options: buildCacheOptions(Duration.zero, maxStale: Duration(days: 30)),
        cancelToken: token);
    flareDetect(context, data);
    if (data.statusCode == 200) {
      var jsonData = data.data;
      Post2 onePost;
      Post2 tempPost;
      List<Post2> postList = [];
      globals.postLock = false;
      for (var p in jsonData) {
        tempPost = Post2(
            id: p['id'],
            created_at: p['created_at'],
            updated_at: p['updated_at'],
            fileWidth: p['file']['width'],
            fileHeight: p['file']['height'],
            fileExt: p['file']['ext'],
            fileSize: p['file']['size'],
            fileMd5: p['file']['md5'],
            fileUrl: p['file']['url'],
            previewWidth: p['preview']['width'],
            previewHeight: p['preview']['height'],
            previewUrl: p['preview']['url'],
            sampleHas: p['sample']['has'],
            sampleHeight: p['sample']['height'],
            sampleWidth: p['sample']['width'],
            sampleUrl: p['sample']['url'],
            scoreUp: p['score']['up'],
            scoreDown: p['score']['down'],
            scoreTotal: p['score']['total'],
            tags: p['tags'],
            locked_tags: p['locked_tags'],
            change_seq: p['change_seq'],
            flags: p['flags'],
            rating: p['rating'],
            fav_count: p['fav_count'],
            sources: p['sources'],
            pools: p['pools'],
            parent_id: p['relationships']['parent_id'],
            has_children: p['relationships']['has_children'],
            has_active_children: p['relationships']['has_active_children'],
            children: p['relationships']['children'],
            approver_id: p['approver_id'],
            uploader_id: p['uploader_id'],
            description: p['description'],
            comment_count: p['comment_count'],
            is_favorited: p['is_favorited']);
        postList.add(tempPost);
      }
      onePost = (postList..shuffle()).first;
      onePost = defaultFilterFixer(onePost);
      globals.tagCacheHelper[search] = onePost.previewUrl;
      globals.saveTagCacheHelper();
      return onePost;
    } else if (data.statusCode == 503) {
      log('Hard-limit');
      await Future.delayed(Duration(seconds: rng.nextInt(5).clamp(2, 5)));
      attempts += 1;
      globals.postLock = false;
      return getTopPost2(context, tag, attempts,
          safe: safe, safeLock: safeLock, priority: priority);
    }
  } on FormatException {
    await Future.delayed(Duration(seconds: attempts));
    if (attempts < 10) {
      globals.postLock = false;
      return getTopPost2(context, tag, attempts + 1,
          priority: priority, token: token);
    } else {
      throw (FormatException);
    }
  } on NoSuchMethodError {
    await Future.delayed(Duration(seconds: attempts));
    if (safe && !safeLock) {
      log(tag + ': Switching to UnSafe');
    }
    if (attempts < 10) {
      globals.postLock = false;
      return (safeLock == false)
          ? getTopPost2(context, tag, attempts + 1,
              safe: false, priority: priority, token: token)
          : getTopPost2(context, tag, attempts + 1,
              safe: true, priority: priority, token: token);
    } else {
      log('Timed Out');
      throw (NoSuchMethodError);
    }
  }
  return null;
}

Future<Map<String, Object>> getTrending2(context,
    {String timeFrame = 'day',
    int page = 0,
    List<Post2> posts,
    bool holdLoad = false,
    bool fallback = false,
    int previousPostCount = 0,
    int day,
    int month,
    int year,
    Duration offset,
    int minimumReturn,
    priority = 1,
    refresh = true,
    CancelToken token}) async {
  if (minimumReturn == null) {
    int tempMinRet;
    log(PrefService.getString('minTrend'));
    if (PrefService.getString('minTrend') != null) {
      try {
        tempMinRet = int.parse(PrefService.getString('minTrend'));
      } catch (e) {
        log('Dumb minimum: ' +
            PrefService.getString('minTrend') +
            ' using 10 instead.');
        tempMinRet = null;
      }
    }
    minimumReturn = (tempMinRet == null) ? 10 : tempMinRet;
  }
  if (offset == null) {
    offset = Duration();
  }
  DateTime now = DateTime.now().subtract(offset);
  if (posts == null) {
    posts = [];
  }
  //log(now);
  if (day == null) {
    day = now.day;
  }
  if (month == null) {
    month = now.month;
  }
  if (year == null) {
    year = now.year;
  }
  //log('Ran getTrending() at: ' + DateTime.now().second.toString());
  globals.lastRun = DateTime.now().second + 0.0;
  var rng = Random();
  page = page + 1;
  log('https://e621.net/post/popular_by_' +
      timeFrame +
      '.json?day=' +
      day.toString() +
      '&month=' +
      month.toString() +
      '&year=' +
      year.toString());
  String strMonth = month.toString();
  if (month.toString().length == 1) {
    strMonth = '0' + month.toString();
  }
  String strDay = day.toString();
  if (day.toString().length == 1) {
    strDay = '0' + day.toString();
  }
  var data = await networkingPriority(
          priority: priority, refresh: refresh, token: token)
      .get(
          'https://e621.net/explore/posts/popular.json?date=' +
              year.toString() +
              '-' +
              strMonth +
              '-' +
              strDay +
              '&scale=' +
              timeFrame,
          options:
              buildCacheOptions(Duration.zero, maxStale: Duration(days: 30)),
          cancelToken: token);
  flareDetect(context, data);
  if (data.statusCode == 200) {
    int skipped = 0;
    //log('Processing...' + (data.body.length.toString()));
    var jsonData = data.data['posts'];
    //log('Processing... ' + jsonData.length.toString() + ' items.');
    for (var p in jsonData) {
      Post2 post = Post2(
          id: p['id'],
          created_at: p['created_at'],
          updated_at: p['updated_at'],
          fileWidth: p['file']['width'],
          fileHeight: p['file']['height'],
          fileExt: p['file']['ext'],
          fileSize: p['file']['size'],
          fileMd5: p['file']['md5'],
          fileUrl: p['file']['url'],
          previewWidth: p['preview']['width'],
          previewHeight: p['preview']['height'],
          previewUrl: p['preview']['url'],
          sampleHas: p['sample']['has'],
          sampleHeight: p['sample']['height'],
          sampleWidth: p['sample']['width'],
          sampleUrl: p['sample']['url'],
          scoreUp: p['score']['up'],
          scoreDown: p['score']['down'],
          scoreTotal: p['score']['total'],
          tags: p['tags'],
          locked_tags: p['locked_tags'],
          change_seq: p['change_seq'],
          flags: p['flags'],
          rating: p['rating'],
          fav_count: p['fav_count'],
          sources: p['sources'],
          pools: p['pools'],
          parent_id: p['relationships']['parent_id'],
          has_children: p['relationships']['has_children'],
          has_active_children: p['relationships']['has_active_children'],
          children: p['relationships']['children'],
          approver_id: p['approver_id'],
          uploader_id: p['uploader_id'],
          description: p['description'],
          comment_count: p['comment_count'],
          is_favorited: p['is_favorited']);
      //log(post.toJson());
      if (await theGreatFilter2(post)) {
        post = defaultFilterFixer(post);
        posts.add(post);
      } else {
        skipped++;
      }
    }
    log('Skipped: ' + skipped.toString());
    //log(posts.length.toString());
    //log(posts.length);
    //print(minimumReturn);
    if ((posts.length < minimumReturn) &&
        fallback &&
        now.isAfter(DateTime(2007, 2, 9))) {
      log(
          'Going back farther: ' +
              (DateTime.now().difference(now) + Duration(days: 1)).toString(),
          analytics: false);
      return getTrending2(context,
          timeFrame: timeFrame,
          page: page,
          posts: posts,
          holdLoad: holdLoad,
          previousPostCount: previousPostCount,
          fallback: fallback,
          minimumReturn: minimumReturn,
          offset: (DateTime.now().difference(now) + Duration(days: 1)),
          refresh: refresh,
          token: token);
    }
    if (posts.length == previousPostCount) {
      holdLoad = true;
    }
    previousPostCount = posts.length;
    //log(previousPostCount);
    var _results = {
      'page': page,
      'posts': posts,
      'holdLoad': holdLoad,
      'previousPostCount': previousPostCount,
    };
    return _results;
  } else if (data.statusCode == 503) {
    log('Failed to Load posts, Hard-Limit');
    await Future.delayed(Duration(seconds: (rng.nextDouble() * 5).toInt()));
    return getTrending2(context,
        timeFrame: timeFrame,
        page: page,
        posts: posts,
        holdLoad: holdLoad,
        fallback: fallback,
        previousPostCount: previousPostCount,
        priority: priority,
        refresh: refresh,
        token: token);
  } else {
    log(data.statusCode);
  }
  return null;
}

Future<Map<String, Object>> getTrendingIfChanged2(context,
    {String timeFrame = 'day',
    int page = 0,
    List<Post2> posts,
    bool holdLoad = false,
    bool fallback = false,
    int previousPostCount = 0,
    int day,
    int month,
    int year,
    Duration offset,
    int minimumReturn,
    int minutes = 10,
    priority = 1,
    refresh = true,
    CancelToken token}) async {
  log(PrefService.getString('safe_choice').toString() == globals.lastTrendSafe);
  if (globals.homeTrend != null &&
      globals.lastHomeTrendLoad != null &&
      PrefService.getString('minTrend') == globals.lastMinTrend &&
      PrefService.getString('safe_choice').toString() ==
          globals.lastTrendSafe) {
    if (globals.lastHomeTrendLoad.difference(DateTime.now()).abs() <=
        Duration(minutes: minutes)) {
      log('Will Reload: HomeTrend: ' +
          (Duration(minutes: minutes) -
                  globals.lastHomeTrendLoad.difference(DateTime.now()).abs())
              .toString());
      return Future(() {
        return globals.homeTrend;
      });
    }
  }
  Map<String, Object> data;
  await getTrending2(context,
          timeFrame: timeFrame,
          fallback: fallback,
          offset: offset,
          day: day,
          month: month,
          year: year,
          minimumReturn: minimumReturn,
          holdLoad: holdLoad,
          posts: posts,
          page: page,
          previousPostCount: previousPostCount,
          priority: priority,
          refresh: refresh,
          token: token)
      .then((val) {
    data = val;
  });
  globals.homeTrend = data;
  globals.lastHomeTrendLoad = DateTime.now();
  globals.lastMinTrend = PrefService.getString('minTrend');
  globals.lastTrendSafe = PrefService.getString('safe_choice').toString();
  log('Reloaded: HomeTrend: ' + globals.lastHomeTrendLoad.toString());
  log(data);
  return data;
}

Future<List<Post2>> getUsersFavoritePosts2(context, String user,
    {int attempts = 0,
    priority = 1,
    CancelToken token,
    bool shallow = false,
    bool owner = false}) async {
  bool comprehensiveDone = true;
  int page = 1;
  bool results = true;
  List<Post2> postList = [];
  List<String> postIdsOrder = [];
  while (results) {
    String search = ('https://e621.net/posts.json?limit=320&page=' +
        page.toString() +
        '&tags=' +
        (Uri.encodeComponent('fav:' + user)));
    log(search);
    var data = await networkingPriority(
            priority: priority, token: token, refresh: true)
        .get(search,
            options:
                buildCacheOptions(Duration.zero, maxStale: Duration(days: 30)),
            cancelToken: token);
    flareDetect(context, data);
    page += 1;
    if (data.statusCode == 200) {
      var jsonData = data.data['posts'];
      log(jsonData.toString());
      Post2 tempPost;
      globals.postLock = false;
      if (jsonData.length == 0) {
        results = false;
      } else {
        int added = 0;
        for (var p in jsonData) {
          try {
            tempPost = Post2(
                id: p['id'],
                created_at: p['created_at'],
                updated_at: p['updated_at'],
                fileWidth: p['file']['width'],
                fileHeight: p['file']['height'],
                fileExt: p['file']['ext'],
                fileSize: p['file']['size'],
                fileMd5: p['file']['md5'],
                fileUrl: p['file']['url'],
                previewWidth: p['preview']['width'],
                previewHeight: p['preview']['height'],
                previewUrl: p['preview']['url'],
                sampleHas: p['sample']['has'],
                sampleHeight: p['sample']['height'],
                sampleWidth: p['sample']['width'],
                sampleUrl: p['sample']['url'],
                scoreUp: p['score']['up'],
                scoreDown: p['score']['down'],
                scoreTotal: p['score']['total'],
                tags: p['tags'],
                locked_tags: p['locked_tags'],
                change_seq: p['change_seq'],
                flags: p['flags'],
                rating: p['rating'],
                fav_count: p['fav_count'],
                sources: p['sources'],
                pools: p['pools'],
                parent_id: p['relationships']['parent_id'],
                has_children: p['relationships']['has_children'],
                has_active_children: p['relationships']['has_active_children'],
                children: p['relationships']['children'],
                approver_id: p['approver_id'],
                uploader_id: p['uploader_id'],
                description: p['description'],
                comment_count: p['comment_count'],
                is_favorited: p['is_favorited']);
            tempPost = defaultFilterFixer(tempPost);
            postIdsOrder.add(tempPost.id.toString());
            postList.add(tempPost);
            if (globals.favoritesCache[tempPost.id.toString()] == null) {
              added += 1;
              globals.favoritesCache[tempPost.id.toString()] =
                  tempPost.toJson();
              print('Stored Favorite: ' + tempPost.id.toString());
            } else {
              globals.favoritesCache[tempPost.id.toString()] =
                  tempPost.toJson();
              log('Updated Favorite: ' + tempPost.id.toString());
            }
          } catch (e) {
            log(e);
            await Future.delayed(Duration(seconds: attempts));
            if (attempts < 10) {
              globals.postLock = false;
              return getUsersFavoritePosts2(context, user,
                  attempts: attempts + 1, priority: priority);
            } else {
              rethrow;
            }
          }
        }
        if (shallow && added == 0) {
          results = false;
          comprehensiveDone = false;
        } else {
          print('Added: ' + added.toString());
        }
      }
    }
    log(data.statusCode);
    await Future.delayed(Duration(seconds: 1));
  }
  if (owner & comprehensiveDone) {
    log('idSort Added');
    accountTable['idSort'] = postIdsOrder;
    await saveAccount();
  } else {
    log('Owner: ' + owner.toString());
    log('ComprehensiveDone: ' + comprehensiveDone.toString());
  }
  globals.saveFavoritesCache();
  return postList;
}

Future<Map<String, Object>> memGetPosts2(context,
    {String tag = '',
    int page = 0,
    List<Post2> posts,
    bool holdLoad = false,
    int previousPostCount = 0,
    priority = 1,
    CancelToken token}) async {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  return _memoizer.runOnce(() async => getPosts2(context,
      tag: tag,
      page: page,
      previousPostCount: previousPostCount,
      holdLoad: holdLoad,
      posts: posts,
      priority: priority,
      token: token));
}
