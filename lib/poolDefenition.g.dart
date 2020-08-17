// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poolDefenition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Pool2Adapter extends TypeAdapter<Pool2> {
  @override
  final typeId = 1;

  @override
  Pool2 read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pool2(
      fields[0] as int,
      fields[1] as String,
      fields[2] as int,
      fields[3] as String,
      fields[4] as bool,
      (fields[5] as List)?.cast<dynamic>(),
      fields[6] as bool,
      fields[7] as String,
      fields[8] as String,
      fields[9] as String,
      fields[10] as String,
      fields[11] as int,
      posts: (fields[12] as List)?.cast<Post2>(),
    );
  }

  @override
  void write(BinaryWriter writer, Pool2 obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.creator_id)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.is_active)
      ..writeByte(5)
      ..write(obj.post_ids)
      ..writeByte(6)
      ..write(obj.is_deleted)
      ..writeByte(7)
      ..write(obj.created_at)
      ..writeByte(8)
      ..write(obj.updated_at)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.creator_name)
      ..writeByte(11)
      ..write(obj.post_count)
      ..writeByte(12)
      ..write(obj.posts);
  }
}
