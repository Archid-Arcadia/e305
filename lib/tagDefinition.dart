import 'package:dio/dio.dart';
import 'package:e305/networking.dart';

Future<Tag> getTag(String tagName, {CancelToken token}) async {
  Response fResult = await network.get(
      'https://e621.net/tag/show.json?name=' + tagName.toString(),
      cancelToken: token);
  Tag result = Tag(
      id: fResult.data["id"],
      name: fResult.data["name"],
      type: fResult.data["type"],
      count: fResult.data["count"]);
  return result;
}

class Tag {
  int id;
  String name;
  int count;
  int type;

  Tag({this.id, this.name, this.type, this.count = 0});
}
