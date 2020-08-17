import 'package:hive/hive.dart';

import 'postDefinition.dart';

part 'poolDefenition.g.dart';

@HiveType(typeId: 1, adapterName: 'Pool2Adapter')
class Pool2 {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  int creator_id;
  @HiveField(3)
  String description;
  @HiveField(4)
  bool is_active;
  @HiveField(5)
  List<dynamic> post_ids;
  @HiveField(6)
  bool is_deleted;
  @HiveField(7)
  String created_at;
  @HiveField(8)
  String updated_at;
  @HiveField(9)
  String category;
  @HiveField(10)
  String creator_name;
  @HiveField(11)
  int post_count;
  @HiveField(12)
  List<Post2> posts;

  Pool2(
      this.id,
      this.name,
      this.creator_id,
      this.description,
      this.is_active,
      this.post_ids,
      this.is_deleted,
      this.created_at,
      this.updated_at,
      this.category,
      this.creator_name,
      this.post_count,
      {this.posts});
}
