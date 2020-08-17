import 'package:e305/ui-Toolkit.dart';
import 'package:preferences/preference_service.dart';
import 'package:preferences/preferences.dart';

import 'globals.dart' as globals;
import 'postDefinition.dart';

String lastFault = '';
List<String> faults = [];
//bool investigate = true;
bool setToDetonate = false;

Post2 defaultFilterFixer(Post2 onePost) {
  String part1 = onePost.fileMd5.substring(0, 2);
  String part2 = onePost.fileMd5.substring(2, 4);
  String sampleTarget = onePost.sampleUrl;
  String fileTarget = onePost.fileUrl;
  String previewTarget = onePost.previewUrl;
  String sampleExt = '.jpg';
  String sampleMod = 'sample/';
  if (onePost != null) {
    if (onePost.fileExt == 'png') {
      sampleExt = '.png';
      sampleMod = '';
    }

    if (sampleTarget == null) {
      //log('DefaultFilterFixer: ' + onePost.id.toString());
      sampleTarget = 'https://static1.e621.net/data/' +
          sampleMod +
          part1 +
          '/' +
          part2 +
          '/' +
          onePost.fileMd5 +
          sampleExt;
      //log(sampleTarget);
    }
    if (fileTarget == null) {
      fileTarget = 'https://static1.e621.net/data/' +
          part1 +
          '/' +
          part2 +
          '/' +
          onePost.fileMd5 +
          '.' +
          onePost.fileExt;
      //log(fileTarget);
    }
    if (previewTarget == null) {
      previewTarget = 'https://static1.e621.net/data/preview/' +
          part1 +
          '/' +
          part2 +
          '/' +
          onePost.fileMd5 +
          '.jpg';
      //log(previewTarget);
    }
    if (onePost.fileExt == 'gif' || onePost.sampleHas == false) {
      sampleTarget = fileTarget;
    }
    onePost.previewUrl = previewTarget;
    onePost.fileUrl = fileTarget;
    onePost.sampleUrl = sampleTarget;
    return onePost;
  }
  return null;
}

timedFaultKiller() async {
  if (!setToDetonate) {
    setToDetonate = true;
    await Future.delayed(Duration(seconds: 10));
    faults = [];
    setToDetonate = false;
  }
}

bool theGreatFilter2(Post2 post,
    {bool reason = false, bool blacklist = true, bool investigate = false}) {
  if (reason) {
    lastFault =
        'All posts have been deleted! Possible policy violation... probably.';
  } else {
    lastFault = '';
  }
  bool safe = (PrefService.getString('safe_choice') == 'SFW' ||
      PrefService.getString('safe_choice') == null);
  bool safeQ = (PrefService.getString('safe_choice') == 'KSFW');
  bool blacklisted = false;
  String fault = '';
  if (blacklist) {
    try {
      Map<String, dynamic> tags = post.tags;

      for (String bTag in globals.blackList) {
        for (String key in tags.keys) {
          if (tags[key].contains(bTag)) {
            blacklisted = true;
            fault = bTag;
          }
        }
      }
    } catch (e) {
      log(e);
      try {
        String tags = post.tags as String;
        List<String> tagList = tags.split(' ');
        for (String bTag in globals.blackList) {
          if (tagList.contains(bTag)) {
            blacklisted = true;
            fault = bTag;
          }
        }
      } catch (e) {
        log(e);
      }
    }
  }
  if (blacklisted) {
    if (reason) {
      faults.add(fault.toString());
      //log('Failed due to Blacklisted Image Tag: ' + fault);
      lastFault = 'Blacklisted Term Detected: "' + fault.toString() + '"';
    }
    timedFaultKiller();
    return false;
  } else if (post.fileExt == 'swf') {
    //log('Failed due to SWF Image');
    if (reason) {
      lastFault = "SWF is restricted on all platforms";
    }
    return false;
  } else if (safe && (post.rating == 'e')) {
    //log('Failed due to safe mode and explicit image');
    if (reason) {
      lastFault = "SFW mode, but Explicit (NSFW) Rating on Post(s)";
    }
    return false;
  } else if ((safe) && post.rating == 'q') {
    //log('Failed due to non-KSFW but Questionable image');
    if (reason) {
      lastFault = "SFW mode, but Questionable (KSFW) Rating on Post(s)";
    }
    return false;
  } else if (safeQ && post.rating == 'e') {
    //log('Failed due to kinda-safe mode and explicit image');
    if (reason) {
      lastFault = "KSFW mode, but Explicit (NSFW) Rating on Post(s)";
    }
    return false;
  } else {
    if (reason) {
      investigate = true;
    }
    return true;
  }
}
