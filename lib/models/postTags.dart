class PostTags {
  List<String> general;
  List<String> species;
  List<Object> character;
  List<String> copyright;
  List<String> artist;
  List<Object> invalid;
  List<Object> lore;
  List<Object> meta;

  PostTags.fromJsonMap(Map<String, dynamic> map)
      : general = List<String>.from(map["general"]),
        species = List<String>.from(map["species"]),
        character = map["character"],
        copyright = List<String>.from(map["copyright"]),
        artist = List<String>.from(map["artist"]),
        invalid = map["invalid"],
        lore = map["lore"],
        meta = map["meta"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['general'] = general;
    data['species'] = species;
    data['character'] = character;
    data['copyright'] = copyright;
    data['artist'] = artist;
    data['invalid'] = invalid;
    data['lore'] = lore;
    data['meta'] = meta;
    return data;
  }
}
