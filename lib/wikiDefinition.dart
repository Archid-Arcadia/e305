class Wiki {
  int id;
  String created_at;
  String updated_at;
  String title;
  String body;
  int updater_id;
  bool locked;
  int version;

  Wiki(this.id, this.created_at, this.updated_at, this.title, this.body,
      this.updater_id, this.locked, this.version);
}
