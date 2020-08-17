class tags {
  int id;
  String name;
  int postCount;
  String relatedTags;
  String relatedTagsUpdatedAt;
  int category;
  bool isLocked;
  String createdAt;
  String updatedAt;

  tags(
      {this.id,
      this.name,
      this.postCount,
      this.relatedTags,
      this.relatedTagsUpdatedAt,
      this.category,
      this.isLocked,
      this.createdAt,
      this.updatedAt});

  tags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    postCount = json['post_count'];
    relatedTags = json['related_tags'];
    relatedTagsUpdatedAt = json['related_tags_updated_at'];
    category = json['category'];
    isLocked = json['is_locked'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['post_count'] = this.postCount;
    data['related_tags'] = this.relatedTags;
    data['related_tags_updated_at'] = this.relatedTagsUpdatedAt;
    data['category'] = this.category;
    data['is_locked'] = this.isLocked;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
