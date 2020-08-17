class forums {
  int id;
  int creatorId;
  int updaterId;
  String title;
  int responseCount;
  bool isSticky;
  bool isLocked;
  bool isHidden;
  String createdAt;
  String updatedAt;
  int categoryId;

  forums(
      {this.id,
      this.creatorId,
      this.updaterId,
      this.title,
      this.responseCount,
      this.isSticky,
      this.isLocked,
      this.isHidden,
      this.createdAt,
      this.updatedAt,
      this.categoryId});

  forums.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    creatorId = json['creator_id'];
    updaterId = json['updater_id'];
    title = json['title'];
    responseCount = json['response_count'];
    isSticky = json['is_sticky'];
    isLocked = json['is_locked'];
    isHidden = json['is_hidden'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    categoryId = json['category_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['creator_id'] = this.creatorId;
    data['updater_id'] = this.updaterId;
    data['title'] = this.title;
    data['response_count'] = this.responseCount;
    data['is_sticky'] = this.isSticky;
    data['is_locked'] = this.isLocked;
    data['is_hidden'] = this.isHidden;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['category_id'] = this.categoryId;
    return data;
  }
}
