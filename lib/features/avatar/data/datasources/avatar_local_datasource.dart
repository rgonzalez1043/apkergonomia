import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/models/user_profile_model.dart';

abstract class AvatarLocalDataSource {
  Future<AvatarConfig?> loadAvatarConfig();
  Future<void> saveAvatarConfig(AvatarConfig config);
}

class AvatarLocalDataSourceImpl implements AvatarLocalDataSource {
  static const _avatarConfigKey = 'avatar_config';

  @override
  Future<AvatarConfig?> loadAvatarConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_avatarConfigKey);
    if (raw == null) return null;
    try {
      final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
      return AvatarConfig.fromJson(jsonMap);
    } catch (_) {
      await prefs.remove(_avatarConfigKey);
      return null;
    }
  }

  @override
  Future<void> saveAvatarConfig(AvatarConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(config.toJson());
    await prefs.setString(_avatarConfigKey, jsonString);
  }
}
