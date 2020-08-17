import 'package:e305/models/posts.dart';

class PostsSearch {
  List<Posts> posts;

  PostsSearch.fromJsonMap(Map<String, dynamic> map)
      : posts =
            List<Posts>.from(map["posts"].map((it) => Posts.fromJsonMap(it)));

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['posts'] =
        posts != null ? this.posts.map((v) => v.toJson()).toList() : null;
    return data;
  }
}
