class User {
  int wiki_page_version_count;
  int artist_version_count;
  int pool_version_count;
  int forum_post_count;
  int comment_count;
  int appeal_count;
  int flag_count;
  int positive_feedback_count;
  int neutral_feedback_count;
  int negative_feedback_count;
  int upload_limit;
  int id;
  String created_at;
  String name;
  int level;
  int base_upload_limit;
  int post_upload_count;
  int post_update_count;
  int note_update_count;
  bool is_banned;
  bool can_approve_posts;
  bool can_upload_free;
  String level_string;
  bool show_avatars;
  bool blacklist_avatars;
  bool blacklist_users;
  bool description_collapsed_initially;
  bool hide_comments;
  bool show_hidden_comments;
  bool show_post_statistics;
  bool has_mail;
  bool receive_email_notifications;
  bool enable_keyboard_navigation;
  bool enable_privacy_mode;
  bool style_usernames;
  bool enable_auto_complete;
  bool has_saved_searches;
  bool disable_cropped_thumbnails;
  bool disable_mobile_gestures;
  bool enable_safe_mode;
  bool disable_responsive_mode;
  bool disable_post_tooltips;
  bool no_flagging;
  bool no_feedback;
  bool disable_user_dmails;
  bool enable_compact_uploader;
  String updated_at;
  String email;
  String last_logged_in_at;
  String last_forum_read_at;
  String recent_tags;
  int comment_threshold;
  String default_image_size;
  String favorite_tags;
  String blacklisted_tags;
  String time_zone;
  int per_page;
  Object custom_style;
  int favorite_count;
  int api_regen_multiplier;
  int api_burst_limit;
  int remaining_api_limit;
  int statement_timeout;
  int favorite_limit;
  int tag_query_limit;

  User.fromJsonMap(Map<String, dynamic> map)
      : wiki_page_version_count = map["wiki_page_version_count"],
        artist_version_count = map["artist_version_count"],
        pool_version_count = map["pool_version_count"],
        forum_post_count = map["forum_post_count"],
        comment_count = map["comment_count"],
        appeal_count = map["appeal_count"],
        flag_count = map["flag_count"],
        positive_feedback_count = map["positive_feedback_count"],
        neutral_feedback_count = map["neutral_feedback_count"],
        negative_feedback_count = map["negative_feedback_count"],
        upload_limit = map["upload_limit"],
        id = map["id"],
        created_at = map["created_at"],
        name = map["name"],
        level = map["level"],
        base_upload_limit = map["base_upload_limit"],
        post_upload_count = map["post_upload_count"],
        post_update_count = map["post_update_count"],
        note_update_count = map["note_update_count"],
        is_banned = map["is_banned"],
        can_approve_posts = map["can_approve_posts"],
        can_upload_free = map["can_upload_free"],
        level_string = map["level_string"],
        show_avatars = map["show_avatars"],
        blacklist_avatars = map["blacklist_avatars"],
        blacklist_users = map["blacklist_users"],
        description_collapsed_initially =
            map["description_collapsed_initially"],
        hide_comments = map["hide_comments"],
        show_hidden_comments = map["show_hidden_comments"],
        show_post_statistics = map["show_post_statistics"],
        has_mail = map["has_mail"],
        receive_email_notifications = map["receive_email_notifications"],
        enable_keyboard_navigation = map["enable_keyboard_navigation"],
        enable_privacy_mode = map["enable_privacy_mode"],
        style_usernames = map["style_usernames"],
        enable_auto_complete = map["enable_auto_complete"],
        has_saved_searches = map["has_saved_searches"],
        disable_cropped_thumbnails = map["disable_cropped_thumbnails"],
        disable_mobile_gestures = map["disable_mobile_gestures"],
        enable_safe_mode = map["enable_safe_mode"],
        disable_responsive_mode = map["disable_responsive_mode"],
        disable_post_tooltips = map["disable_post_tooltips"],
        no_flagging = map["no_flagging"],
        no_feedback = map["no_feedback"],
        disable_user_dmails = map["disable_user_dmails"],
        enable_compact_uploader = map["enable_compact_uploader"],
        updated_at = map["updated_at"],
        email = map["email"],
        last_logged_in_at = map["last_logged_in_at"],
        last_forum_read_at = map["last_forum_read_at"],
        recent_tags = map["recent_tags"],
        comment_threshold = map["comment_threshold"],
        default_image_size = map["default_image_size"],
        favorite_tags = map["favorite_tags"],
        blacklisted_tags = map["blacklisted_tags"],
        time_zone = map["time_zone"],
        per_page = map["per_page"],
        custom_style = map["custom_style"],
        favorite_count = map["favorite_count"],
        api_regen_multiplier = map["api_regen_multiplier"],
        api_burst_limit = map["api_burst_limit"],
        remaining_api_limit = map["remaining_api_limit"],
        statement_timeout = map["statement_timeout"],
        favorite_limit = map["favorite_limit"],
        tag_query_limit = map["tag_query_limit"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['wiki_page_version_count'] = wiki_page_version_count;
    data['artist_version_count'] = artist_version_count;
    data['pool_version_count'] = pool_version_count;
    data['forum_post_count'] = forum_post_count;
    data['comment_count'] = comment_count;
    data['appeal_count'] = appeal_count;
    data['flag_count'] = flag_count;
    data['positive_feedback_count'] = positive_feedback_count;
    data['neutral_feedback_count'] = neutral_feedback_count;
    data['negative_feedback_count'] = negative_feedback_count;
    data['upload_limit'] = upload_limit;
    data['id'] = id;
    data['created_at'] = created_at;
    data['name'] = name;
    data['level'] = level;
    data['base_upload_limit'] = base_upload_limit;
    data['post_upload_count'] = post_upload_count;
    data['post_update_count'] = post_update_count;
    data['note_update_count'] = note_update_count;
    data['is_banned'] = is_banned;
    data['can_approve_posts'] = can_approve_posts;
    data['can_upload_free'] = can_upload_free;
    data['level_string'] = level_string;
    data['show_avatars'] = show_avatars;
    data['blacklist_avatars'] = blacklist_avatars;
    data['blacklist_users'] = blacklist_users;
    data['description_collapsed_initially'] = description_collapsed_initially;
    data['hide_comments'] = hide_comments;
    data['show_hidden_comments'] = show_hidden_comments;
    data['show_post_statistics'] = show_post_statistics;
    data['has_mail'] = has_mail;
    data['receive_email_notifications'] = receive_email_notifications;
    data['enable_keyboard_navigation'] = enable_keyboard_navigation;
    data['enable_privacy_mode'] = enable_privacy_mode;
    data['style_usernames'] = style_usernames;
    data['enable_auto_complete'] = enable_auto_complete;
    data['has_saved_searches'] = has_saved_searches;
    data['disable_cropped_thumbnails'] = disable_cropped_thumbnails;
    data['disable_mobile_gestures'] = disable_mobile_gestures;
    data['enable_safe_mode'] = enable_safe_mode;
    data['disable_responsive_mode'] = disable_responsive_mode;
    data['disable_post_tooltips'] = disable_post_tooltips;
    data['no_flagging'] = no_flagging;
    data['no_feedback'] = no_feedback;
    data['disable_user_dmails'] = disable_user_dmails;
    data['enable_compact_uploader'] = enable_compact_uploader;
    data['updated_at'] = updated_at;
    data['email'] = email;
    data['last_logged_in_at'] = last_logged_in_at;
    data['last_forum_read_at'] = last_forum_read_at;
    data['recent_tags'] = recent_tags;
    data['comment_threshold'] = comment_threshold;
    data['default_image_size'] = default_image_size;
    data['favorite_tags'] = favorite_tags;
    data['blacklisted_tags'] = blacklisted_tags;
    data['time_zone'] = time_zone;
    data['per_page'] = per_page;
    data['custom_style'] = custom_style;
    data['favorite_count'] = favorite_count;
    data['api_regen_multiplier'] = api_regen_multiplier;
    data['api_burst_limit'] = api_burst_limit;
    data['remaining_api_limit'] = remaining_api_limit;
    data['statement_timeout'] = statement_timeout;
    data['favorite_limit'] = favorite_limit;
    data['tag_query_limit'] = tag_query_limit;
    return data;
  }
}
