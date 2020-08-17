import 'package:e305/models/file.dart';
import 'package:e305/models/flags.dart';
import 'package:e305/models/postTags.dart';
import 'package:e305/models/preview.dart';
import 'package:e305/models/relationships.dart';
import 'package:e305/models/sample.dart';
import 'package:e305/models/score.dart';

class Posts {
  int id;
  String created_at;
  String updated_at;
  File file;
  Preview preview;
  Sample sample;
  Score score;
  PostTags tags;
  List<Object> locked_tags;
  int change_seq;
  Flags flags;
  String rating;
  int fav_count;
  List<String> sources;
  List<Object> pools;
  Relationships relationships;
  Object approver_id;
  int uploader_id;
  String description;
  int comment_count;
  bool is_favorited;

  Posts.fromJsonMap(Map<String, dynamic> map)
      : id = map["id"],
        created_at = map["created_at"],
        updated_at = map["updated_at"],
        file = File.fromJsonMap(map["file"]),
        preview = Preview.fromJsonMap(map["preview"]),
        sample = Sample.fromJsonMap(map["sample"]),
        score = Score.fromJsonMap(map["score"]),
        tags = PostTags.fromJsonMap(map["tags"]),
        locked_tags = map["locked_tags"],
        change_seq = map["change_seq"],
        flags = Flags.fromJsonMap(map["flags"]),
        rating = map["rating"],
        fav_count = map["fav_count"],
        sources = List<String>.from(map["sources"]),
        pools = map["pools"],
        relationships = Relationships.fromJsonMap(map["relationships"]),
        approver_id = map["approver_id"],
        uploader_id = map["uploader_id"],
        description = map["description"],
        comment_count = map["comment_count"],
        is_favorited = map["is_favorited"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['created_at'] = created_at;
    data['updated_at'] = updated_at;
    data['file'] = file == null ? null : file.toJson();
    data['preview'] = preview == null ? null : preview.toJson();
    data['sample'] = sample == null ? null : sample.toJson();
    data['score'] = score == null ? null : score.toJson();
    data['tags'] = tags == null ? null : tags.toJson();
    data['locked_tags'] = locked_tags;
    data['change_seq'] = change_seq;
    data['flags'] = flags == null ? null : flags.toJson();
    data['rating'] = rating;
    data['fav_count'] = fav_count;
    data['sources'] = sources;
    data['pools'] = pools;
    data['relationships'] =
        relationships == null ? null : relationships.toJson();
    data['approver_id'] = approver_id;
    data['uploader_id'] = uploader_id;
    data['description'] = description;
    data['comment_count'] = comment_count;
    data['is_favorited'] = is_favorited;
    return data;
  }
}
