class Comment {
  int id;
  String creator;
  String created_at;
  int post_id;
  String body;
  int score;

  Comment(this.id, this.creator, this.created_at, this.post_id, this.body,
      this.score);
}

class Comment2 {
  int id;
  int post_id;
  int creator_id;
  String body;
  int score;
  String created_at;
  String updated_at;
  int updater_id;
  bool do_not_bump_post;
  bool is_hidden;
  bool is_sticky;
  String creator_name;
  String updater_name;

  Comment2(
      this.id,
      this.post_id,
      this.creator_id,
      this.body,
      this.score,
      this.created_at,
      this.updated_at,
      this.updater_id,
      this.do_not_bump_post,
      this.is_hidden,
      this.is_sticky,
      this.creator_name,
      this.updater_name);
}

Comment2 commentBuilder(
    {int id,
    int post_id,
    int creator_id,
    String body,
    int score,
    String created_at,
    String updated_at,
    int updater_id,
    bool do_not_bump_post,
    bool is_hidden,
    bool is_sticky,
    String creator_name,
    String updater_name}) {
  return Comment2(
      id,
      post_id,
      creator_id,
      body,
      score,
      created_at,
      updated_at,
      updater_id,
      do_not_bump_post,
      is_hidden,
      is_sticky,
      creator_name,
      updater_name);
}
