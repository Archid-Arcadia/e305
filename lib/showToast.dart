import 'dart:core';

import 'package:flutter/material.dart';
import 'package:getflutter/getflutter.dart';

Widget showToast(String msg, context, {int duration = 3, int gravity}) {
  return Scaffold(
      body: GFFloatingWidget(
          child: GFToast(
    text: msg,
    duration: Duration(seconds: duration),
    autoDismiss: true,
  )));
  //Toast.show(msg, context, duration: duration, gravity: gravity);
}
