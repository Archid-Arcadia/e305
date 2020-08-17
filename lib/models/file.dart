class File {
  int width;
  int height;
  String ext;
  int size;
  String md5;
  String url;

  File.fromJsonMap(Map<String, dynamic> map)
      : width = map["width"],
        height = map["height"],
        ext = map["ext"],
        size = map["size"],
        md5 = map["md5"],
        url = map["url"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['width'] = width;
    data['height'] = height;
    data['ext'] = ext;
    data['size'] = size;
    data['md5'] = md5;
    data['url'] = url;
    return data;
  }
}
