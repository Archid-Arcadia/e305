import 'dart:core';

import 'package:flutter/cupertino.dart';

String fancyDate(int time) {
  return DateTime.fromMillisecondsSinceEpoch(time * 1000)
      .toString()
      .split(' ')[0];
}

String fancyDateAndTime(int time) {
  return DateTime.fromMillisecondsSinceEpoch(time * 1000).toString();
}

String fancyTimeDifference(BuildContext context, int time) {
  Duration diff = DateTime.fromMillisecondsSinceEpoch(time * 1000)
      .difference(DateTime.now());
  if (diff.inDays.abs() / 365 > 1) {
    return ((diff.inDays.abs() ~/ 365)).toString() + 'y ago';
  } else if ((diff.inDays.abs() ~/ 30.42) > 0) {
    return ('~' + ((diff.inDays.abs() ~/ 30.42).toString() + 'mo ago'));
  } else if (diff.inDays.abs() > 0) {
    return diff.inDays.abs().toString() + 'd ago';
  } else if (diff.inHours.abs() > 0) {
    return diff.inHours.abs().toString() + 'h ago';
  } else if (diff.inMinutes.abs() > 0) {
    return diff.inMinutes.abs().toString() + 'm ago';
  } else if (diff.inSeconds.abs() > 0) {
    return diff.inSeconds.abs().toString() + 's ago';
  }
  return DateTime.fromMillisecondsSinceEpoch(time * 1000).toString();
}

String fancyTimeDifferenceFromString(BuildContext context, String dateString) {
  if (dateString != null) {
    var parsedDate = DateTime.parse(dateString);
    //log(parsedDate);
    Duration diff = parsedDate.difference(DateTime.now());
    if (diff.inDays.abs() / 365 > 1) {
      return ((diff.inDays.abs() ~/ 365)).toString() + 'y ago';
    } else if ((diff.inDays.abs() ~/ 30.42) > 0) {
      return ('~' + ((diff.inDays.abs() ~/ 30.42).toString() + 'mo ago'));
    } else if (diff.inDays.abs() > 0) {
      return diff.inDays.abs().toString() + 'd ago';
    } else if (diff.inHours.abs() > 0) {
      return diff.inHours.abs().toString() + 'h ago';
    } else if (diff.inMinutes.abs() > 0) {
      return diff.inMinutes.abs().toString() + 'm ago';
    } else if (diff.inSeconds.abs() > 0) {
      return diff.inSeconds.abs().toString() + 's ago';
    }
    return parsedDate.toString();
  }
  return '';
}
