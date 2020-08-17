// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'postDefinition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Post2Adapter extends TypeAdapter<Post2> {
  @override
  final typeId = 2;

  @override
  Post2 read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Post2(
      id: fields[0] as int,
      created_at: fields[1] as String,
      updated_at: fields[2] as String,
      fileWidth: fields[3] as int,
      fileHeight: fields[4] as int,
      fileExt: fields[5] as String,
      fileSize: fields[6] as int,
      fileMd5: fields[7] as String,
      fileUrl: fields[8] as String,
      previewWidth: fields[9] as int,
      previewHeight: fields[10] as int,
      previewUrl: fields[11] as String,
      sampleHas: fields[12] as bool,
      sampleHeight: fields[13] as int,
      sampleWidth: fields[14] as int,
      sampleUrl: fields[15] as String,
      scoreUp: fields[16] as int,
      scoreDown: fields[17] as int,
      scoreTotal: fields[18] as int,
      tags: (fields[19] as Map)?.cast<String, dynamic>(),
      locked_tags: (fields[20] as List)?.cast<dynamic>(),
      change_seq: fields[21] as int,
      flags: (fields[22] as Map)?.cast<String, dynamic>(),
      rating: fields[23] as String,
      fav_count: fields[24] as int,
      sources: (fields[25] as List)?.cast<dynamic>(),
      pools: (fields[26] as List)?.cast<dynamic>(),
      parent_id: fields[27] as int,
      has_children: fields[28] as bool,
      has_active_children: fields[29] as bool,
      children: (fields[30] as List)?.cast<dynamic>(),
      approver_id: fields[31] as int,
      uploader_id: fields[32] as int,
      description: fields[33] as String,
      comment_count: fields[34] as int,
      is_favorited: fields[35] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Post2 obj) {
    writer
      ..writeByte(36)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.created_at)
      ..writeByte(2)
      ..write(obj.updated_at)
      ..writeByte(3)
      ..write(obj.fileWidth)
      ..writeByte(4)
      ..write(obj.fileHeight)
      ..writeByte(5)
      ..write(obj.fileExt)
      ..writeByte(6)
      ..write(obj.fileSize)
      ..writeByte(7)
      ..write(obj.fileMd5)
      ..writeByte(8)
      ..write(obj.fileUrl)
      ..writeByte(9)
      ..write(obj.previewWidth)
      ..writeByte(10)
      ..write(obj.previewHeight)
      ..writeByte(11)
      ..write(obj.previewUrl)
      ..writeByte(12)
      ..write(obj.sampleHas)
      ..writeByte(13)
      ..write(obj.sampleHeight)
      ..writeByte(14)
      ..write(obj.sampleWidth)
      ..writeByte(15)
      ..write(obj.sampleUrl)
      ..writeByte(16)
      ..write(obj.scoreUp)
      ..writeByte(17)
      ..write(obj.scoreDown)
      ..writeByte(18)
      ..write(obj.scoreTotal)
      ..writeByte(19)
      ..write(obj.tags)
      ..writeByte(20)
      ..write(obj.locked_tags)
      ..writeByte(21)
      ..write(obj.change_seq)
      ..writeByte(22)
      ..write(obj.flags)
      ..writeByte(23)
      ..write(obj.rating)
      ..writeByte(24)
      ..write(obj.fav_count)
      ..writeByte(25)
      ..write(obj.sources)
      ..writeByte(26)
      ..write(obj.pools)
      ..writeByte(27)
      ..write(obj.parent_id)
      ..writeByte(28)
      ..write(obj.has_children)
      ..writeByte(29)
      ..write(obj.has_active_children)
      ..writeByte(30)
      ..write(obj.children)
      ..writeByte(31)
      ..write(obj.approver_id)
      ..writeByte(32)
      ..write(obj.uploader_id)
      ..writeByte(33)
      ..write(obj.description)
      ..writeByte(34)
      ..write(obj.comment_count)
      ..writeByte(35)
      ..write(obj.is_favorited);
  }
}
