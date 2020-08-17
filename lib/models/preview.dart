class Preview {
  int width;
  int height;
  String url;

  Preview.fromJsonMap(Map<String, dynamic> map)
      : width = map["width"],
        height = map["height"],
        url = map["url"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['width'] = width;
    data['height'] = height;
    data['url'] = url;
    return data;
  }
}
