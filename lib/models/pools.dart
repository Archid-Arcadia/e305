class pools {
  int id;
  String name;
  String createdAt;
  String updatedAt;
  int creatorId;
  String description;
  bool isActive;
  String category;
  bool isDeleted;
  List<int> postIds;
  String creatorName;
  int postCount;

  pools(
      {this.id,
      this.name,
      this.createdAt,
      this.updatedAt,
      this.creatorId,
      this.description,
      this.isActive,
      this.category,
      this.isDeleted,
      this.postIds,
      this.creatorName,
      this.postCount});

  pools.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    creatorId = json['creator_id'];
    description = json['description'];
    isActive = json['is_active'];
    category = json['category'];
    isDeleted = json['is_deleted'];
    postIds = json['post_ids'].cast<int>();
    creatorName = json['creator_name'];
    postCount = json['post_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['creator_id'] = this.creatorId;
    data['description'] = this.description;
    data['is_active'] = this.isActive;
    data['category'] = this.category;
    data['is_deleted'] = this.isDeleted;
    data['post_ids'] = this.postIds;
    data['creator_name'] = this.creatorName;
    data['post_count'] = this.postCount;
    return data;
  }
}
