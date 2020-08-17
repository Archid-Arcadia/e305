class Comment {
  int id;
  String createdAt;
  int postId;
  int creatorId;
  String body;
  int score;
  String updatedAt;
  int updaterId;
  bool doNotBumpPost;
  bool isHidden;
  bool isSticky;
  String creatorName;
  String updaterName;

  Comment(
      {this.id,
      this.createdAt,
      this.postId,
      this.creatorId,
      this.body,
      this.score,
      this.updatedAt,
      this.updaterId,
      this.doNotBumpPost,
      this.isHidden,
      this.isSticky,
      this.creatorName,
      this.updaterName});

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    postId = json['post_id'];
    creatorId = json['creator_id'];
    body = json['body'];
    score = json['score'];
    updatedAt = json['updated_at'];
    updaterId = json['updater_id'];
    doNotBumpPost = json['do_not_bump_post'];
    isHidden = json['is_hidden'];
    isSticky = json['is_sticky'];
    creatorName = json['creator_name'];
    updaterName = json['updater_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['created_at'] = this.createdAt;
    data['post_id'] = this.postId;
    data['creator_id'] = this.creatorId;
    data['body'] = this.body;
    data['score'] = this.score;
    data['updated_at'] = this.updatedAt;
    data['updater_id'] = this.updaterId;
    data['do_not_bump_post'] = this.doNotBumpPost;
    data['is_hidden'] = this.isHidden;
    data['is_sticky'] = this.isSticky;
    data['creator_name'] = this.creatorName;
    data['updater_name'] = this.updaterName;
    return data;
  }
}
