import 'dart:core';
import 'dart:ui';

import 'package:e305/favoritesPage.dart';
import 'package:e305/getPool.dart';
import 'package:e305/getPosts.dart';
import 'package:e305/modern_home.dart';
import 'package:e305/poolBrowseExperimental.dart';
import 'package:e305/postDefinition.dart';
import 'package:e305/postDetailPage.dart';
import 'package:e305/preferencePage.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_whatsnew/flutter_whatsnew.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:getflutter/components/loader/gf_loader.dart';
import 'package:getflutter/getflutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:pedantic/pedantic.dart';
import 'package:preferences/preferences.dart';
import 'package:uni_links/uni_links.dart';

import 'globals.dart' as globals;
import 'loginManager.dart' as login;
import 'networking.dart';
import 'poolDefenition.dart';
import 'poolMain.dart';
import 'searchPage.dart';
import 'settingOptimizer.dart';
import 'themeData.dart';

PackageInfo packageInfo;
main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pass all uncaught errors from the framework to Crashlytics.

  while (window.locale == null) {
    await Future.delayed(const Duration(milliseconds: 1));
  }
  final locale = window.locale;
  Intl.systemLocale = locale.toString();
//  try {
//    Admob.initialize(AppAds.appId);
//  } catch (e) {
//    log('Failed to initialize ads');
//  }
  await PrefService.init(prefix: 'pref_');
  await Hive.initFlutter();
  await Hive.registerAdapter(Pool2Adapter());
  await Hive.registerAdapter(Post2Adapter());
  await Hive.openBox('poolThumbs');

  globals.startTagCacheHelper();
  globals.startFavoritesCache();
  globals.startBlackList();
  globals.startFollowList();
  globals.startTagPairings();
  globals.startTags();
  unawaited(login.retrieveAccount());
  setupNetLimiter();
  unawaited(globals.refreshTags());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget postLoader(context, int id) {
    return FutureBuilder(
      future: getPostByID2(context, id),
      builder: (context, snap) {
        if (snap.hasData) {
          Get.to(WillPopScope(
              child: PostDetail(snap.data),
              onWillPop: () async {
                await Get.off(MyMainPage());
                return true;
              }));
          return Container();
        } else {
          return Scaffold(
            body: GFLoader(),
          );
        }
      },
    );
  }

  Widget poolLoader(context, int id) {
    return FutureBuilder(
      future: populatePool(id, just1: true),
      builder: (context, snap) {
        if (snap.hasData) {
          Get.to(WillPopScope(
              child: PoolBrowseExp(snap.data),
              onWillPop: () async {
                await Get.off(MyMainPage());
                return true;
              }));
          return Container();
        } else {
          return Scaffold(
            body: GFLoader(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        defaultTransition: Transition.cupertino,
        navigatorKey: Get.key,
        navigatorObservers: [],
        theme: getPanacheTheme(),
        home: StreamBuilder(
            stream: getLinksStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data);
                var uri = Uri.parse(snapshot.data);
                var list = uri.pathSegments;
                print(list);
                for (var item in list) {
                  print(item);
                  print(item.runtimeType);
                }
                if (list.contains('posts') && list.length >= 2) {
                  return postLoader(context, int.parse(list[1]));
                } else if (list.contains('pools') && list.length >= 2) {
                  return poolLoader(context, int.parse(list[1]));
                }
                return MyMainPage();
              } else {
                return MyMainPage();
              }
            }));
  }
}

class MyMainPage extends StatefulWidget {
  MyMainPage();

  @override
  State<StatefulWidget> createState() {
    return _MyMainPageState();
  }
}

List<String> pagesNames = [
  'ModernHome()',
  "SearchPage()",
  "FavoritesPage()",
  "PoolPage()",
  "PreferencesPage()",
];

class _MyMainPageState extends State<MyMainPage> {
  Future<bool> change;

  _MyMainPageState();

  @override
  void initState() {
    super.initState();
    change = didChangeLogChange();
  }

  final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final List<GlobalKey<NavigatorState>> tabKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];
  DateTime currentBackPressTime;

  int _currentIndex = 0;

  List<Widget> pages = <Widget>[
    ModernHome(),
    SearchPage('', globals.postPageKey),
    FavoritesPage(),
    PoolPage(),
    PreferencesPage(),
  ];

  Future<bool> didChangeLogChange() async {
    DateTime start = DateTime.now();
    packageInfo = await PackageInfo.fromPlatform();
    String buildNumber = packageInfo.buildNumber;
    log('Version: ' + buildNumber);
    log('ChangeLog Save: ' + (await buildNumber != null).toString());
    log('Change: ' +
        (await PrefService.getString('appVersion') != buildNumber).toString());
    bool changed = (await PrefService.getString('appVersion') != null)
        ? (await PrefService.getString('appVersion') != buildNumber)
        : true;
    if (changed) {
      PrefService.setString('appVersion', buildNumber);
    }
    DateTime end = DateTime.now();
    print('Boot Time: ' + end.difference(start).toString());
    return changed;
  }

  Widget newChanges(BuildContext context, Widget mainApp) {
    return FutureBuilder(
      future: change,
      builder: (innerContext, snap) {
        if (snap.connectionState == ConnectionState.done) {
          //print(snap.data);
          if (snap.data) {
            return WhatsNewPage.changelog(
              title: Text(
                "What's New",
                textScaleFactor: 2,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexendDeca(
                  // Text Style Needed to Look like iOS 11
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              buttonText: Text(
                'Continue',
                textScaleFactor: 2,
                style: GoogleFonts.lexendDeca(color: Colors.white),
              ),
              onButtonPressed: () {
                change = didChangeLogChange();
                runApp(MyApp());
              },
            );
          }
          return mainApp;
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: GFLoader(),
        );
      },
    );
  }

  void onTabTapped(int index) {
    if (_currentIndex == index) {
      //log('Rebuild Ordered for: ' + index.toString());
      if (index == 4) {
        tabKeys[index].currentState.popUntil((r) => r.isFirst);
      }
      tabKeys[index].currentState.pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => AnimatedContainer(
                  duration: Duration(seconds: 1),
                  key: Key(index.toString()),
                  child: pages[index]),
              settings: RouteSettings(name: 'Open Tab: ' + pagesNames[index])),
          (Route<dynamic> route) => false);

      //tabKeys[index].currentState.popUntil((r) => r.isFirst);
    }
    _currentIndex = index;
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      key.currentState.showSnackBar(
        SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      currentBackPressTime = now;
      //showToast('Press back again to exit', context);
      return Future.value(false);
    }
    return Future.value(true);
  }

  Widget build(BuildContext context) {
    Optimizer(context);

    log('Rebuild');
    return newChanges(
      context,
      WillPopScope(
          child: Scaffold(
            key: key,
            body: CupertinoTabScaffold(
              tabBuilder: (BuildContext context, int index) {
                return CupertinoTabView(
                    navigatorKey: tabKeys[index],
                    builder: (BuildContext context) {
                      return pages[index];
                    });
              },
              tabBar: CupertinoTabBar(
                key: globals.globalBarKey,
                activeColor: getPanacheTheme().accentColor,
                backgroundColor:
                    (getPanacheTheme().brightness == Brightness.dark)
                        ? Colors.black87
                        : Colors.white70,
                onTap: onTabTapped,
                currentIndex: _currentIndex,
                items: [
                  BottomNavigationBarItem(
                    icon: Container(child: Icon(FontAwesomeIcons.home)),
                    activeIcon: Container(
                        child: Icon(
                      FontAwesomeIcons.home,
                      color: Colors.orange,
                    )),
                    title: Text('Home',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexendDeca(
                            color: (getPanacheTheme().brightness ==
                                    Brightness.dark)
                                ? Colors.white70
                                : Colors.black87)),
                  ),
                  BottomNavigationBarItem(
                    icon: Container(child: Icon(FontAwesomeIcons.search)),
                    activeIcon: Container(
                        child: Icon(
                      FontAwesomeIcons.search,
                      color: Colors.green,
                    )),
                    title: Text('Search',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexendDeca(
                            color: (getPanacheTheme().brightness ==
                                    Brightness.dark)
                                ? Colors.white70
                                : Colors.black87)),
                  ),
                  BottomNavigationBarItem(
                      icon: Container(child: Icon(FontAwesomeIcons.heart)),
                      activeIcon: Container(
                          child: Icon(
                        FontAwesomeIcons.heart,
                        color: Colors.pink,
                      )),
                      title: Text("Favorites",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexendDeca(
                              color: (getPanacheTheme().brightness ==
                                      Brightness.dark)
                                  ? Colors.white70
                                  : Colors.black87))),
                  BottomNavigationBarItem(
                      icon:
                          Container(child: Icon(FontAwesomeIcons.swimmingPool)),
                      activeIcon: Container(
                          child: Icon(
                        FontAwesomeIcons.swimmingPool,
                        color: Colors.blue,
                      )),
                      title: Text("Pools",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexendDeca(
                              color: (getPanacheTheme().brightness ==
                                      Brightness.dark)
                                  ? Colors.white70
                                  : Colors.black87))),
                  BottomNavigationBarItem(
                      icon: Container(child: Icon(FontAwesomeIcons.userCog)),
                      activeIcon: Container(
                          child: Icon(
                        FontAwesomeIcons.userCog,
                        color: Colors.blueGrey,
                      )),
                      title: Text("Settings",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexendDeca(
                              color: (getPanacheTheme().brightness ==
                                      Brightness.dark)
                                  ? Colors.white70
                                  : Colors.black87)))
                ],
              ),
            ),
          ),
          onWillPop: onWillPop),
    );
  }
}
