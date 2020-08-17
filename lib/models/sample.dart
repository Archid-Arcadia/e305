class Sample {
  bool has;
  int height;
  int width;
  String url;

  Sample.fromJsonMap(Map<String, dynamic> map)
      : has = map["has"],
        height = map["height"],
        width = map["width"],
        url = map["url"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['has'] = has;
    data['height'] = height;
    data['width'] = width;
    data['url'] = url;
    return data;
  }
}
