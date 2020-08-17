import 'dart:math';

import 'package:dio/dio.dart';
import 'package:e305/cloudFlareDetector.dart';
import 'package:e305/networking.dart';

Future<List<String>> getSetNamesWithID(context, int id,
    {CancelToken token}) async {
  var dataQ = await network.get(
      'https://e621.net/set/index.json?post_id=' + id.toString(),
      cancelToken: token);
  flareDetect(context, dataQ);
  var jsonData = dataQ.data;
  List<String> results = [];
  for (var set in jsonData) {
    results.add(set['shortname']);
  }
  return results;
}

Future<String> getSetNameWithIDRandom(context, int id,
    {CancelToken token}) async {
  var dataQ = await network.get(
      'https://e621.net/set/index.json?post_id=' + id.toString(),
      cancelToken: token);
  flareDetect(context, dataQ);
  var jsonData = dataQ.data;
  List<String> results = [];
  for (var set in jsonData) {
    results.add(set['shortname']);
  }
  Random rnd = Random();
  int r = rnd.nextInt(results.length - 1);
  return (results[r]);
}
