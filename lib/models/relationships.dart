class Relationships {
  Object parent_id;
  bool has_children;
  bool has_active_children;
  List<Object> children;

  Relationships.fromJsonMap(Map<String, dynamic> map)
      : parent_id = map["parent_id"],
        has_children = map["has_children"],
        has_active_children = map["has_active_children"],
        children = map["children"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['parent_id'] = parent_id;
    data['has_children'] = has_children;
    data['has_active_children'] = has_active_children;
    data['children'] = children;
    return data;
  }
}
