class Flags {
  bool pending;
  bool flagged;
  bool note_locked;
  bool status_locked;
  bool rating_locked;
  bool deleted;

  Flags.fromJsonMap(Map<String, dynamic> map)
      : pending = map["pending"],
        flagged = map["flagged"],
        note_locked = map["note_locked"],
        status_locked = map["status_locked"],
        rating_locked = map["rating_locked"],
        deleted = map["deleted"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['pending'] = pending;
    data['flagged'] = flagged;
    data['note_locked'] = note_locked;
    data['status_locked'] = status_locked;
    data['rating_locked'] = rating_locked;
    data['deleted'] = deleted;
    return data;
  }
}
