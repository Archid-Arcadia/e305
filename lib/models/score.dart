class Score {
  int up;
  int down;
  int total;

  Score.fromJsonMap(Map<String, dynamic> map)
      : up = map["up"],
        down = map["down"],
        total = map["total"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['up'] = up;
    data['down'] = down;
    data['total'] = total;
    return data;
  }
}
