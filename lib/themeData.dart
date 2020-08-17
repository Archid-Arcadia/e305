import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'theme.dart' as panache;

Map<int, Color> color = {
  50: Color.fromRGBO(242, 100, 48, .1),
  100: Color.fromRGBO(242, 100, 48, .2),
  200: Color.fromRGBO(242, 100, 48, .3),
  300: Color.fromRGBO(242, 100, 48, .4),
  400: Color.fromRGBO(242, 100, 48, .5),
  500: Color.fromRGBO(242, 100, 48, .6),
  600: Color.fromRGBO(242, 100, 48, .7),
  700: Color.fromRGBO(242, 100, 48, .8),
  800: Color.fromRGBO(242, 100, 48, .9),
  900: Color.fromRGBO(242, 100, 48, 1),
};

MaterialColor colorCustom = MaterialColor(0xFF880E4F, color);

ThemeData getPanacheTheme() {
//  String light = PrefService.getString('ui_theme');
//  bool dark = ((light) == 'dark' || (light) == null);
  return panache.darkTheme;
}

ThemeData getTheme() {
  //String light = PrefService.getString('ui_theme');

  //log('ui_theme: ' + light);
  return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: colorCustom,
      backgroundColor: colorCustom,
      fontFamily: 'Lexend Deca');
}
