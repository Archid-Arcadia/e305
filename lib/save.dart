import 'dart:core';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'postDefinition.dart';
import 'ui-Toolkit.dart';

void save2(Post2 post, context) async {
  PermissionStatus permission = await Permission.storage.status;
  if (permission == PermissionStatus.granted) {
    try {
      Get.snackbar("Downloader", "Downloading...",
          icon: Icon(FontAwesomeIcons.download));
    } on NoSuchMethodError {
      log('Snackbar Error');
    }
    var appDocDir = await getTemporaryDirectory();
    //print(appDocDir);
    String savePath = appDocDir.path + "/temp." + post.fileExt;
    log(await Dio().download(post.fileUrl, savePath));
    var result = await ImageGallerySaver.saveFile(savePath);
    log(result);
    try {
      Get.snackbar("Downloader", "Download Complete",
          icon: Icon(FontAwesomeIcons.download));
    } on NoSuchMethodError {
      log('Snackbar Error');
    }
  } else {
    await Permission.storage.request();
  }
}
