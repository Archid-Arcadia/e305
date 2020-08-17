import 'package:about/about.dart';
import 'package:e305/advancedSettingPage.dart';
import 'package:e305/loginManager.dart';
import 'package:e305/main.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getflutter/components/appbar/gf_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preferences/preferences.dart';

import 'blackList.dart';
import 'loginManager.dart';

class PreferencesPage extends StatefulWidget {
  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage>
    with AutomaticKeepAliveClientMixin<PreferencesPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: GFAppBar(
        title: Text(
          "\uD83E\uDDF0 Settings",
          style: TextStyle(fontSize: 14),
        ),
      ),
      body: PreferencePage([
        PreferenceTitle("General"),
        InkWell(
          onTap: () {
            //TextEditingController _controller = TextEditingController();
            Get.to(accountManager());
          },
          child: Center(
              child: Text(
                  !loggedIn() ? 'Login to e621 [Beta]' : 'Manage E621 Account',
                  style: GoogleFonts.lexendDeca(fontSize: 20))),
        ),
        DropdownPreference(
          "Content Rating:",
          'safe_choice',
          defaultVal: 'SFW',
          onChange: (choice) async {
            log(choice, type: 'change_safety');
          },
          values: ['SFW', 'KSFW', 'NSFW'],
        ),
        Divider(
          thickness: 1,
        ),
        InkWell(
          onTap: () {
            Get.to(BlackListView());
          },
          child: Center(
              child: Text("Black List",
                  style: GoogleFonts.lexendDeca(fontSize: 20))),
        ),
        Divider(
          thickness: 1,
        ),
        PreferenceTitle("Personalization \uD83D\uDD8C️"),
        SwitchPreference(
          "Use Gradient Backgrounds: ",
          'gradientBackgrounds',
          defaultVal: false,
        ),
        DropdownPreference(
          'Image Scaling Type',
          'image_scale',
          defaultVal: 'Cover',
          values: [
            'Contain',
            'Cover',
            'Fill',
            'Fit Height',
            'Fit Width',
            'None',
            'Scale Down'
          ],
        ),
//        RadioPreference(
//          "Light Theme",
//          'light',
//          'ui_theme',
//        ),
//        RadioPreference(
//          "Dark Theme",
//          'dark',
//          'ui_theme',
//          isDefault: true,
//        ),
        SwitchPreference(
          "Show I've favorited a post while browsing:",
          'likedThis',
          defaultVal: true,
        ),
        loggedIn()
            ? SwitchPreference(
                'Auto Upvote Posts You Favorite:',
                'autoUp',
                defaultVal: false,
              )
            : Container(),
        loggedIn()
            ? SwitchPreference(
                'Sync Favorites On Startup:',
                'startupSync',
                defaultVal: true,
              )
            : Container(),
        SwitchPreference(
          "Show Favorite Count on Search Page:",
          'favCountChoice',
          defaultVal: true,
        ),
        PreferenceTitle("Performance \uD83D\uDEE0️"),
        TextFieldPreference(
          "Minimum Number of Trending on Homescreen:",
          'minTrend',
          defaultVal: '10',
          keyboardType: TextInputType.number,
          autofocus: false,
        ),
//        SwitchPreference(
//          "Fancy Home Trending Carousel [Very High]",
//          'homeCarousel',
//          defaultVal: false,
//        ),
        SwitchPreference(
          "Enable Suggestion Bar [High]:",
          'suggestBar',
          defaultVal: false,
        ),
        SwitchPreference(
          "High Resolution Previews [Medium]:",
          'hiresChoice',
          defaultVal: true,
        ),
        SwitchPreference(
          "Display full sized images when viewing [Medium]:",
          'fullImage',
          defaultVal: false,
        ),
        SwitchPreference(
          "Autoplay/Animate Homescreen carousel [Medium]:",
          'animateCarousel',
          defaultVal: false,
        ),
        SwitchPreference(
          "Animate Previews [Medium]:",
          'animateChoice',
          defaultVal: true,
        ),
//        PreferenceTitle(AppLocalizations.of(context).translate('experiments')),
////        Divider(
////          thickness: 1,
////        ),
////        InkWell(
////          onTap: () {
////            //TextEditingController _controller = TextEditingController();
////            Navigator.push(
////              context,
////              MaterialPageRoute(
////                builder: (context) => syncPage(),
////              ),
////            );
////          },
////          child: Center(
////              child: Text(AppLocalizations.of(context).translate('syncWuser'),
////                  style: TextStyle(fontSize: 20))),
////        ),
//        Divider(
//          thickness: 1,
//        ),
//        InkWell(
//          onTap: () {
//            //TextEditingController _controller = TextEditingController();
//            Navigator.push(
//              context,
//              MaterialPageRoute(
//                builder: (context) => accountManager(),
//              ),
//            );
//          },
//          child: Center(
//              child:
//                  Text('Login to e621 [Beta]', style: TextStyle(fontSize: 20))),
//        ),
//        Divider(
//          thickness: 1,
//        ),
//        SwitchPreference(
//          'Show personalized reccomendation score for posts',
//          'predictLike',
//          defaultVal: false,
//        ),
//        IconButton(
//          icon: Icon(FontAwesomeIcons.cog),
//          onPressed: () {
//            _settingModalBottomSheet(context);
//          },
//        ),
//        Divider(
//          thickness: 1,
//        ),
//        SwitchPreference(
//          AppLocalizations.of(context).translate('transUI'),
//          'transUI',
//          defaultVal: false,
//        ),
        Divider(
          thickness: 1,
        ),
        PreferenceTitle("Information \uD83D\uDCD3"),
        Divider(
          thickness: 1,
        ),
        InkWell(
          onTap: () {
            Get.to(AdvancedSettingPage());
          },
          child: Center(
              child: Text("Stats for Nerds",
                  style: GoogleFonts.lexendDeca(fontSize: 20))),
        ),
//        Divider(
//          thickness: 1,
//        ),
//        InkWell(
//          onTap: () {
//            //https://e621.net/forum/show/280927
//            launch('https://e621.net/forum_topics/25785');
//          },
//          child:
//              Center(child: Text("Changelog", style: TextStyle(fontSize: 20))),
//        ),
        Divider(
          thickness: 1,
        ),
        InkWell(
          onTap: () {
            showAboutDialog(
              applicationName: '${packageInfo.appName}',
              context: context,
              applicationVersion:
                  'Version ${packageInfo.version}, build ${packageInfo.buildNumber}',
              applicationIcon: Image(
                image: AssetImage('assets/E305_Logo2.png'),
                height: 50,
                alignment: Alignment.center,
                fit: BoxFit.contain,
              ),
              applicationLegalese:
                  '© [Insert User Name Here], ${DateTime.now().year}',
              children: <Widget>[
                Text(
                  'E305: The unofficial E621 mobile browser. Made by the Community.',
                  textAlign: TextAlign.justify,
                ),
                MarkdownPageListTile(
                  filename: 'CHANGELOG.md',
                  title: Text('View Changelog'),
                  icon: Icon(Icons.description),
                ),
              ],
            );
          },
          child: Center(
              child: Text('About Page',
                  style: GoogleFonts.lexendDeca(fontSize: 20))),
        ),
        Divider(
          thickness: 1,
        ),
//        Container(
//          child: bannerAd(context),
//        ),
      ]),
    );
  }
}
