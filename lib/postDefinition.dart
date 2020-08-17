//int time;
//int id;
//String tags;
//String author;
//int score;
//int favCount;
//String description;
//String fileUrl;
//String fileExt;
//String previewUrl;
//int previewWidth;
//int previewHeight;
//String sampleUrl;
//int sampleWidth;
//int sampleHeight;
//String rating;
//bool hasComments;
//String source;
//String artist;
//bool hasChildren;
//String children;
//int parent_id;
//bool isConditionalDnp;
//bool hasSoundWarning;
//bool hasEpilepsyWarning;

import 'package:e305/getPosts.dart';
import 'package:e305/theGreatFilter.dart';
import 'package:hive/hive.dart';

part 'postDefinition.g.dart';

@HiveType(typeId: 2, adapterName: 'Post2Adapter')
class Post2 {
  @override
  final typeId = 0;
  @HiveField(0)
  int id;
  @HiveField(1)
  String created_at;
  @HiveField(2)
  String updated_at;
  @HiveField(3)
  int fileWidth;
  @HiveField(4)
  int fileHeight;
  @HiveField(5)
  String fileExt;
  @HiveField(6)
  int fileSize;
  @HiveField(7)
  String fileMd5;
  @HiveField(8)
  String fileUrl;
  @HiveField(9)
  int previewWidth;
  @HiveField(10)
  int previewHeight;
  @HiveField(11)
  String previewUrl;
  @HiveField(12)
  bool sampleHas;
  @HiveField(13)
  int sampleHeight;
  @HiveField(14)
  int sampleWidth;
  @HiveField(15)
  String sampleUrl;
  @HiveField(16)
  int scoreUp;
  @HiveField(17)
  int scoreDown;
  @HiveField(18)
  int scoreTotal;
  @HiveField(19)
  Map<String, dynamic> tags;
  @HiveField(20)
  List<dynamic> locked_tags;
  @HiveField(21)
  int change_seq;
  @HiveField(22)
  Map<String, dynamic> flags;
  @HiveField(23)
  String rating;
  @HiveField(24)
  int fav_count;
  @HiveField(25)
  List<dynamic> sources;
  @HiveField(26)
  List<dynamic> pools;
  @HiveField(27)
  int parent_id;
  @HiveField(28)
  bool has_children;
  @HiveField(29)
  bool has_active_children;
  @HiveField(30)
  List<dynamic> children;
  @HiveField(31)
  int approver_id;
  @HiveField(32)
  int uploader_id;
  @HiveField(33)
  String description;
  @HiveField(34)
  int comment_count;
  @HiveField(35)
  bool is_favorited;

  Post2(
      {this.id,
      this.created_at,
      this.updated_at,
      this.fileWidth,
      this.fileHeight,
      this.fileExt,
      this.fileSize,
      this.fileMd5,
      this.fileUrl,
      this.previewWidth,
      this.previewHeight,
      this.previewUrl,
      this.sampleHas,
      this.sampleHeight,
      this.sampleWidth,
      this.sampleUrl,
      this.scoreUp,
      this.scoreDown,
      this.scoreTotal,
      this.tags,
      this.locked_tags,
      this.change_seq,
      this.flags,
      this.rating,
      this.fav_count,
      this.sources,
      this.pools,
      this.parent_id,
      this.has_children,
      this.has_active_children,
      this.children,
      this.approver_id,
      this.uploader_id,
      this.description,
      this.comment_count,
      this.is_favorited});

  @override
  toString() {
    return toJson().toString();
  }

  Post2 from(Map<String, dynamic> instance) => jsonToPost2(instance);

  // Get the URL for the HTML version of the desired post.
  Map<String, dynamic> toJson() => _itemToJson2(this);

  Uri url(String host) =>
      Uri(scheme: 'https', host: host, path: '/post/show/$id');
}

Post2 jsonToPost2(Map<String, dynamic> instance) {
  if (instance != null) {
    if (instance['time'] != null) {
      favoritesUpgrader(instance);
      try {
        if (instance['tags'].runtimeType == String) {
          List<String> tagList = instance['tags'].split(' ');
          instance['tags'] = {'General': tagList};
        }
      } catch (e) {
        //print(e);
      }
      instance['created_at'] =
          DateTime.fromMillisecondsSinceEpoch(instance['time'])
              .toIso8601String();
      instance['updated_at'] = null;
      instance['sources'] = [instance['source']];
      instance['fav_count'] = instance['favCount'];
      instance['children'] = null;
      instance['scoreTotal'] = instance['score'];
      //print('ran adapt');
    }
    //print(instance['id']);
    Post2 post = Post2(
        id: instance['id'],
        created_at: instance['created_at'],
        updated_at: instance['updated_at'],
        fileWidth: instance['fileWidth'],
        fileHeight: instance['fileHeight'],
        fileExt: instance['fileExt'],
        fileSize: instance['fileSize'],
        fileMd5: instance['fileMd5'],
        fileUrl: instance['fileUrl'],
        previewWidth: instance['previewWidth'],
        previewHeight: instance['previewHeight'],
        previewUrl: instance['previewUrl'],
        sampleHas: instance['sampleHas'],
        sampleWidth: instance['sampleWidth'],
        sampleHeight: instance['sampleHeight'],
        sampleUrl: instance['sampleUrl'],
        scoreUp: instance['scoreUp'],
        scoreDown: instance['scoreDown'],
        scoreTotal: instance['scoreTotal'],
        tags: instance['tags'],
        locked_tags: instance['locked_tags'],
        change_seq: instance['change_seq'],
        flags: instance['flags'],
        rating: instance['rating'],
        fav_count: instance['fav_count'],
        sources: instance['sources'],
        pools: instance['pools'],
        parent_id: instance['parent_id'],
        has_children: instance['has_children'],
        has_active_children: instance['has_active_children'],
        children: instance['children'],
        approver_id: instance['approver_id'],
        uploader_id: instance['uploader_id'],
        description: instance['description'],
        comment_count: instance['comment_count'],
        is_favorited: instance['is_favorited']);
    //print('Made it here');
    post = defaultFilterFixer(post);
    return post;
  }
  return null;
}

Map<String, dynamic> _itemToJson2(Post2 instance) {
  return <String, dynamic>{
    'id': instance.id,
    'created_at': instance.created_at,
    'updated_at': instance.updated_at,
    'fileWidth': instance.fileWidth,
    'fileHeight': instance.fileHeight,
    'fileExt': instance.fileExt,
    'fileSize': instance.fileSize,
    'fileMd5': instance.fileMd5,
    'fileUrl': instance.fileUrl,
    'previewWidth': instance.previewWidth,
    'previewHeight': instance.previewHeight,
    'previewUrl': instance.previewUrl,
    'sampleHas': instance.sampleHas,
    'sampleWidth': instance.sampleWidth,
    'sampleHeight': instance.sampleHeight,
    'sampleUrl': instance.sampleUrl,
    'scoreUp': instance.scoreUp,
    'scoreDown': instance.scoreDown,
    'scoreTotal': instance.scoreTotal,
    'tags': instance.tags,
    'locked_tags': instance.locked_tags,
    'change_seq': instance.change_seq,
    'flags': instance.flags,
    'rating': instance.rating,
    'fav_count': instance.fav_count,
    'sources': instance.sources,
    'pools': instance.pools,
    'parent_id': instance.parent_id,
    'has_children': instance.has_children,
    'has_active_children': instance.has_active_children,
    'children': instance.children,
    'approver_id': instance.approver_id,
    'uploader_id': instance.uploader_id,
    'description': instance.description,
    'comment_count': instance.comment_count,
    'is_favorited': instance.is_favorited
  };
}
