import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:e305/accountDefenition.dart';
import 'package:e305/cloudFlareDetector.dart';
import 'package:e305/getComments.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/mediaManager.dart';
import 'package:e305/models/users.dart';
import 'package:e305/networking.dart';
import 'package:e305/postDefinition.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:e305/themeData.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:getflutter/components/appbar/gf_appbar.dart';
import 'package:getflutter/components/button/gf_button.dart';
import 'package:getflutter/getflutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedantic/pedantic.dart';
import 'package:preferences/preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart' as sync;

import "globals.dart" as globals;

Account user;
String passWord;
String userName;
String apiKey;
int id;
Map<String, dynamic> accountTable;
Map<String, dynamic> votingRecordTable = {};

Future<Account> verifyAccount(String username, String password,
    {priority = 1, CancelToken token}) async {
  //var client = http.Client();
  Account account;
  String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
  log(basicAuth);

  var response = await networkingPriority().get(
      'https://e621.net/user/show/' + (username.toLowerCase()),
      options: Options(headers: {'authorization': basicAuth}),
      cancelToken: token);
  if (response.statusCode == 200) {
    // print(response.data.toString());
    if (response.data.toString().toLowerCase().contains(
        ('<meta name="current-user-name" content="' +
                username.toLowerCase() +
                '">')
            .toLowerCase())) {
      apiKey = password;
      userName = username;
      id = int.parse(response.data
          .toString()
          .toLowerCase()
          .split('<meta name="current-user-id" content="'.toLowerCase())[1]
          .split('">')[0]);
      var userResponse = await networkingPriority().get(
          'https://e621.net/users/' + (id.toString()) + '.json',
          options: Options(headers: {'authorization': basicAuth}),
          cancelToken: token);
      User userProfile = User.fromJsonMap(userResponse.data);
      log(userProfile.toJson());
      accountTable = {
        'user': userName,
        'apiKey': password,
        'basicAuth': basicAuth,
        'id': id,
        'account': userProfile.toJson()
      };
      await saveAccount();
      account = Account(accountTable['user'], accountTable['basicAuth']);
      log(userName, type: 'sign_up');
    } else {
      log(response.data);
    }
    return account;
  } else {
    log(response.statusCode);
  }
  return account;
}

Future<bool> updateAccount({CancelToken token}) async {
  var userResponse = await networkingPriority(refresh: true).get(
      'https://e621.net/users/' + (accountTable['id']).toString() + '.json',
      options: Options(headers: {'authorization': accountTable['basicAuth']}),
      cancelToken: token);
  User userProfile = User.fromJsonMap(userResponse.data);
  log(userProfile.toJson());
  accountTable['account'] = userProfile.toJson();
  return true;
}

Future<bool> retrieveAccount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String accountStr = prefs.getString('account');
  if (accountStr != null) {
    var account = jsonDecode(accountStr);
    if (account != null) {
      accountTable = Map<String, dynamic>.from(account);
      if (accountTable['basicAuth'] == null) {
        accountTable = null;
        await saveAccount();
      }
      log('Got account!' + account.toString());
      //getUsersBlacklist();
      bool sync = (await PrefService.getBool('startupSync') == null)
          ? true
          : PrefService.getBool('startupSync');
      if (sync) {
        unawaited(getUsersFavoritesSort(BuildContext));
      }
      unawaited(retrieveVotingRecord());
      log(account['user'], type: 'login');
      return true;
    }
    return false;
  }
  return false;
}

bool loggedIn() {
  if (accountTable != null) {
    return true;
  }
  return false;
}

Future<bool> retrieveVotingRecord() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String votingStr = prefs.getString('votingRecord');
  if (votingStr != null) {
    var votingRecord = jsonDecode(votingStr);
    if (votingRecord != null) {
      votingRecordTable = Map<String, dynamic>.from(votingRecord);
      log('Got voting Record!' + votingRecordTable.toString());
      return true;
    }
    return false;
  }
  return false;
}

Future<bool> saveVotingRecord() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('votingRecord', jsonEncode(votingRecordTable));
  return true;
}

Future<bool> saveAccount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('account', jsonEncode(accountTable));
  return true;
}

Widget accountManager() {
  return StatefulBuilder(builder: (context, setState) {
    if (accountTable == null) {
      return loginPage();
    } else {
      return Scaffold(
          appBar: GFAppBar(
            title: Text(
              'Account Manager',
              style: TextStyle(fontSize: 14),
            ),
          ),
          body: Align(
            child: Container(
              child: ListView(
                children: [
                  Center(
                      child: FutureBuilder(
                          future: getCommentProfilePic(
                              accountTable['user'], accountTable['id']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return (snapshot.data != null)
                                  ? Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              fit: determineScaling(),
                                              image: AdvancedNetworkImage(
                                                  (snapshot.data as Post2)
                                                      .sampleUrl,
                                                  cacheRule: CacheRule(
                                                      maxAge: const Duration(
                                                          days: 7))))),
                                    )
                                  : Container();
                            } else {
                              return GFLoader();
                            }
                          })),
                  Center(
                      child: AutoSizeText(
                    "${accountTable['user'][0].toUpperCase()}${accountTable['user'].substring(1)}",
                    style: GoogleFonts.roboto(fontSize: 40),
                  )),
                  GFButton(
                    text: 'Logout',
                    onPressed: () {
                      accountTable = null;
                      saveAccount();
                      setState(() {});
                      Get.back();
                    },
                  ),
                  GFButton(
                    text: 'Manually Sync favs to e621 ( E305 >> e621 )',
                    onPressed: () {
                      revAddFavToAccount();
                    },
                  ),
                  (accountTable['id'].toString() == 228854.toString())
                      ? GFButton(
                          text: 'Purge NSFW',
                          onPressed: () async {
                            final _controller = StreamController<int>();
                            final _icontroller = StreamController<String>();
                            cleaner(StreamController controller,
                                StreamController icontroller) async {
                              final _controller = controller;
                              final _icontroller = icontroller;
                              int _count = 0;
                              for (String key
                                  in globals.favoritesCache.keys.toList()) {
                                print('Checking ${key}');
                                Post2 post =
                                    jsonToPost2(globals.favoritesCache[key]);
                                if (post.rating.toLowerCase() == 'e') {
                                  print('Purging ${key}');
                                  Future<bool> removalAgent() async {
                                    try {
                                      return (disfav(post, notify: false));
                                    } catch (e) {
                                      return false;
                                    }
                                  }

                                  bool result = await removalAgent();
                                  print(result ? 'Pass' : 'Fail');

                                  if ((_count > 10) &&
                                      _count.remainder(10) == 0) {
                                    _icontroller.sink.add(post.previewUrl);
                                  }
                                  await Future.delayed(Duration(seconds: 1));
                                }
                                _count++;
                                _controller.sink.add(_count);
                              }
                              unawaited(getUsersFavoritesSort(BuildContext));
                              accountTable['idSort'] = null;
                              unawaited(saveAccount());
                            }

                            if (!_controller.hasListener) {
                              unawaited(cleaner(_controller, _icontroller));
                            }
                            Widget removalScreen(
                                Stream progress, Stream image) {
                              int total = globals.favoritesCache.keys.length;
                              DateTime start = DateTime.now();
                              List<int> times = [];
                              double average(List<int> nums) {
                                return nums.reduce((num a, num b) => a + b) /
                                    nums.length;
                              }

                              return Scaffold(
                                appBar: GFAppBar(
                                  title: Text(
                                    'PURGE',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                body: Column(
                                  children: [
                                    Container(
                                        child: StreamBuilder(
                                            stream: image,
                                            builder: (context, snap) {
                                              if (snap.hasData) {
                                                Image(
                                                  image: AdvancedNetworkImage(
                                                      snap.data),
                                                );
                                              }
                                              return GFLoader();
                                            })),
                                    StreamBuilder(
                                        stream: progress,
                                        builder: (context, snap) {
                                          if (snap.hasData) {
                                            DateTime end = DateTime.now();
                                            Duration diff =
                                                end.difference(start);
                                            times.add(diff.inSeconds);
                                            start = DateTime.now();
                                            return Column(
                                              children: [
                                                Padding(
                                                  child: Container(
                                                    child:
                                                        LinearProgressIndicator(
                                                      value: snap.data / total,
                                                      //minHeight: 20,
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                ),
                                                Container(
                                                  child: Text(
                                                      '${(((snap.data / total) * 100) as double).toStringAsFixed(2)} % (${snap.data}/${total})'),
                                                ),
                                                Container(
                                                  child: Text(
                                                      'Remaining Time: ${((average(times) * (total - snap.data)) / 60).toStringAsFixed(2)} Minutes.'),
                                                )
                                              ],
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                            );
                                          } else if (snap.connectionState ==
                                              ConnectionState.done) {
                                            return (Text('COMPLETE!'));
                                          } else {
                                            log(snap.connectionState);
                                            return GFLoader();
                                          }
                                        }),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                              );
                            }

                            unawaited(Get.to(removalScreen(
                                _controller.stream, _icontroller.stream)));
                          },
                        )
                      : Container(),
                  Container(
                    child: Row(children: [
                      Text('Raw Account Data'),
                      IconButton(
                        icon: Icon(FontAwesomeIcons.sync),
                        onPressed: () async {
                          await updateAccount();
                          setState(() {});
                        },
                      )
                    ]),
                  ),
                  Container(
                      color: Colors.white,
                      child: JsonViewerWidget(accountTable['account']))
                ],
                shrinkWrap: true,
              ),
              alignment: Alignment.center,
              constraints: BoxConstraints.expand(),
            ),
            alignment: Alignment.center,
          ));
    }
  });
}

GlobalKey<FormState> userKey = GlobalKey<FormState>();
GlobalKey<FormState> passKey = GlobalKey<FormState>();
TextEditingController username = TextEditingController();
TextEditingController password = TextEditingController();
Widget loginPage() {
  final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  return StatefulBuilder(builder: (context, setState) {
    return Scaffold(
        key: key,
        appBar: GFAppBar(),
        body: Container(
          child: ListView(
            children: <Widget>[
              Container(
                color: Color.fromRGBO(1, 45, 85, 1),
                child: Image(
                  image: AdvancedNetworkImage(
                      'https://e621.net/apple-touch-icon.png',
                      cacheRule: CacheRule(maxAge: const Duration(days: 7))),
                ),
                width: MediaQuery.of(context).size.width,
                height: 200,
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      child: AutoSizeText(
                        'Username: ',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: getPanacheTheme().textTheme.bodyText2.color),
                      ),
                      width: MediaQuery.of(context).size.width,
                    ),
                    TextField(
                        controller: username,
                        key: userKey,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            fillColor: getPanacheTheme().cardColor,
                            filled: true)),
                  ],
                ),
                width: MediaQuery.of(context).size.width / 1.5,
              ),
              Container(
                height: 50,
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      child: AutoSizeText(
                        'API-Key: ',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: getPanacheTheme().textTheme.bodyText2.color),
                      ),
                      width: MediaQuery.of(context).size.width,
                    ),
                    TextField(
                        controller: password,
                        key: passKey,
                        obscureText: true,
                        onSubmitted: (pass) async {
                          Account result =
                              await verifyAccount(username.text, pass);
                          try {
                            if (result.name != null) {
                              log('Name: ' + result.name);
                              unawaited(getUsersFavoritesSort(context));
                              key.currentState.showSnackBar(SnackBar(
                                content: Text('Success!'),
                                duration: Duration(seconds: 2),
                              ));
                              user = result;
                              getUsersBlacklist();
                              Get.back();
                            } else {
                              await key.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    'Nope. Verify this is the correct API Key and Username please.'),
                                duration: Duration(seconds: 2),
                              ));
                            }
                          } on DioError {
                            await key.currentState.showSnackBar(SnackBar(
                              content: Text(
                                  'Nope. Verify this is the correct API Key and Username please. Also your Network Connection.'),
                              duration: Duration(seconds: 2),
                            ));
                          }
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            fillColor: getPanacheTheme().cardColor,
                            filled: true)),
                  ],
                ),
                width: MediaQuery.of(context).size.width / 1.5,
              ),
              Container(
                height: 20,
              ),
              Divider(),
              Container(
                height: 20,
              ),
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey.withOpacity(1),
                            offset: Offset(2, 4),
                            blurRadius: 5,
                            spreadRadius: 2)
                      ],
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xfffbb448), Color(0xfff7892b)])),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                onTap: () async {
                  Account result =
                      await verifyAccount(username.text, password.text);
                  if (result.name != null) {
                    log('Name: ' + result.name);
                    unawaited(getUsersFavoritesSort(context));
                    await key.currentState.showSnackBar(SnackBar(
                      content: Text('Success!'),
                      duration: Duration(seconds: 2),
                    ));
                    user = result;
                    getUsersBlacklist();
                    Get.back();
                  } else {
                    try {
                      await Get.snackbar('Invalid',
                          'Verify this is the correct API Key and Username. Hint: API-Key is not your password.',
                          duration: Duration(seconds: 5));
                    } on NoSuchMethodError {
                      log('Snackbar Error');
                    }
                    print('Failed login');
                  }
                },
              )
            ],
          ),
        ));
  });
}

bool favSwitcher(Post2 post, {bool dislikeAllowed = true}) {
  if (!faved(post)) {
    fav(post);
    return true;
  } else if (dislikeAllowed) {
    disfav(post);
    return true;
  }
  return false;
}

bool faved(Post2 post) {
  return globals.favoritesCache.keys.contains(post.id.toString());
}

bool fav(Post2 post, {bool notify = true}) {
  //setState(() => pressAttention = true);
  log(globals.favoritesCache.keys.contains(post.id));
  if (!faved(post)) {
    //setState(() => favLoader = true);
    globals.favoritesCache[post.id.toString()] = post.toJson();
    globals.saveFavoritesCache();
    if (notify) {
      try {
        Get.snackbar(
          'Favorites',
          "   Saved to favorites! ❤   ",
          icon: Icon(FontAwesomeIcons.heart),
          duration: Duration(seconds: 1),
        );
      } on NoSuchMethodError {
        log('Snackbar Error');
      }
    }
    log("Stored Favorite: " + post.id.toString());
    addFavToAccount(post.id);
    return true;
  }
  return false;
}

bool disfav(Post2 post, {bool notify = true}) {
  if (faved(post)) {
    globals.favoritesCache.remove(post.id.toString());
    globals.saveFavoritesCache();
    if (notify) {
      try {
        Get.snackbar('Favorites', "   Removed Favorite 💔    ",
            icon: Icon(FontAwesomeIcons.heartBroken),
            duration: Duration(seconds: 1));
      } on NoSuchMethodError {
        log('Snackbar Error');
      }
    }
    remFavToAccount(post.id);
    return true;
  }
  return false;
}

sync.Lock favGet = sync.Lock();
Future<bool> addFavToAccount(int id,
    {int priority = 0, CancelToken token}) async {
  if (accountTable != null) {
    //print(user.hashCode);
    Uri target = Uri(
        scheme: 'https',
        host: 'e621.net',
        path: '/favorites.json',
        queryParameters: stringify({"post_id": id.toString()}));
    var response;
    try {
      await favGet.synchronized(() async {
        response = await networkingPriority(
                priority: priority, refresh: true, token: token)
            .post(target.toString(),
                options: Options(
                    headers: {'authorization': accountTable['basicAuth']}),
                cancelToken: token);
      });
    } on DioError catch (e) {
      log(e.error);
    }
    try {
      bool noAVote = (PrefService.getBool('autoUp') == null ||
          PrefService.getBool('autoUp') == false);
      if (!noAVote) {
        log('Auto Voting');
        if (votingRecordTable['post-' + id.toString()] == null) {
          var response = await networkingPriority(refresh: true, token: token)
              .post(
                  'https://e621.net/posts/' +
                      id.toString() +
                      '/votes.json?score=1&no_unvote=true',
                  options: Options(
                      headers: {'authorization': accountTable['basicAuth']}),
                  cancelToken: token);
          votingRecordTable['post-' + id.toString()] = 1;
          unawaited(saveVotingRecord());
          log(response.data);
        }
      }
    } on Exception {
      log('Failed to Auto Like');
    }
    if (response != null && response.data['is_favorited'] == true) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Future<bool> revAddFavToAccount() async {
  sync.Lock syncLock = sync.Lock();
  List<Post2> e621Favs = await getUsersFavoritePosts2(
      BuildContext, accountTable['user'],
      owner: true);
  log(e621Favs);
  List<int> e621FavIds = [];
  for (Post2 post in e621Favs) {
    e621FavIds.add(post.id);
  }
  log(e621FavIds);
  int count = 0;
  int favLegth = globals.favoritesCache.keys.toList().length;
  log(e621FavIds.length.toString() + " | VS | " + favLegth.toString());
  for (var key in globals.favoritesCache.keys.toList().reversed.toList()) {
    Post2 tempPost = jsonToPost2(globals.favoritesCache[key]);
    bool response = false;
    //print(e621FavIds.contains(tempPost.id));
    try {
      if (!e621FavIds.contains(tempPost.id)) {
        await syncLock.synchronized(() async {
          response = await addFavToAccount(tempPost.id);
        });
      } else {
        response = true;
      }
    } catch (e) {
      log(e);
      await Future.delayed(Duration(seconds: 1));
    }
    log('ID: ' + tempPost.id.toString() + ' | Success:' + response.toString());
    count++;
    log('Synced: ' + count.toString() + '/' + favLegth.toString());
  }
  return true;
}

Future<bool> remFavToAccount(int id, {int priority = 0}) async {
  if (accountTable != null) {
//    var response = await networkingPriority(priority: priority).get(
//        'https://e621.net/user/login.json?name=' +
//            accountTable['user'] +
//            '&password=' +
//            accountTable['apiKey']);
//    print(response.data.toString());
    //log(a.hashCode);
    Uri target = Uri(
      scheme: 'https',
      host: 'e621.net',
      path: '/favorites/' + id.toString() + '.json',
    );
    var response = await networkingPriority(priority: priority, refresh: true)
        .delete(target.toString(),
            options:
                Options(headers: {'authorization': accountTable['basicAuth']}));
    log(response.data);
    globals.favoritesCache.remove(id.toString());
    if (response.data.toString().contains(accountTable['id'].toString())) {
      print('Valid removal');

      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Map<String, String> stringify(Map<String, Object> map) {
  Map<String, String> stringMap = {};
  map.forEach((k, v) {
    if (v != null) {
      stringMap[k] = v.toString();
    }
  });
  return stringMap;
}

getUsersBlacklist({CancelToken token}) async {
  if (accountTable != null && accountTable['account'] != null) {
    var response = await networkingPriority(priority: 0, refresh: true).get(
        'https://e621.net/users/' + (accountTable['id'].toString()) + '.json',
        options: Options(headers: {'authorization': accountTable['basicAuth']}),
        cancelToken: token);
    User user = User.fromJsonMap(response.data);
    if (response.statusCode == 200) {
      String novelBL = user.blacklisted_tags;
      log(novelBL.split('\n').toString());
      for (String term in novelBL.split('\n')) {
        if (!globals.blackList.contains(term.trim())) {
          globals.blackList.add(term.trim());
          globals.saveBlackList();
        }
      }
    }
  }
}

Future<List<String>> getUsersFavoritesSort(context,
    {int attempts = 0, priority = 1, CancelToken token}) async {
  log('Getting users sort pattern');
  int page = 1;
  bool results = true;
  List<String> postIdsOrder = [];
  log(accountTable['account']['per_page'], type: 'User_load_limit');
  int lastResult = 0;
  Map<int, Post2> updatedFavs = {};
  while (results) {
    String search =
        ('https://e621.net/favorites.json?' + 'page=' + page.toString());
    //log(search);
    try {
      var data = await networkingPriority(
              priority: priority, token: token, refresh: false)
          .get(search,
              options: Options(
                  headers: {'authorization': accountTable['basicAuth']}),
              cancelToken: token);
      flareDetect(context, data);
      page += 1;

      if (data.statusCode == 200) {
        var jsonData = data.data['posts'];
        globals.postLock = false;
        if (jsonData.length == 0 || jsonData.length < lastResult) {
          results = false;
        }
        lastResult = jsonData.length;
        for (var p in jsonData) {
          try {
            Post2 tempPost = Post2(
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
            updatedFavs[p['id']] = tempPost;
            globals.favoritesCache[p['id'].toString()] = tempPost.toJson();
            //log('Updated: ' + p['id'].toString(), analytics: false);
            postIdsOrder.add(p['id'].toString());
          } catch (e) {
            log(e);
            await Future.delayed(Duration(seconds: attempts));
            if (attempts < 10) {
              globals.postLock = false;
              return getUsersFavoritesSort(context,
                  attempts: attempts + 1, priority: priority);
            } else {
              rethrow;
            }
          }
        }
        log('Updated_Favs: ' + postIdsOrder.length.toString(),
            analytics: true, type: 'Favorites_Refresher');
      } else if (data.statusCode == 500) {
        results = false;
      }
    } on DioError catch (e) {
      print(e.response.statusCode);
      if (e.response.statusCode == 500) {
        results = false;
      }
    }
  }
  accountTable['idSort'] = postIdsOrder;
  await saveAccount();
  globals.saveFavoritesCache();
  log('Saved users sort pattern');
  return postIdsOrder;
}
