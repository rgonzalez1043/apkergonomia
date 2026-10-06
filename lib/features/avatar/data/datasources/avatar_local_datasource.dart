import 'dart:convert';

import '../../../../core/storage/user_local_storage.dart';
import '../../../../shared/models/user_profile_model.dart';

abstract class AvatarLocalDataSource {
  Future<AvatarConfig?> loadAvatarConfig();
  Future<void> saveAvatarConfig(AvatarConfig config);
}

class AvatarLocalDataSourceImpl implements AvatarLocalDataSource {
  final UserLocalStorage storage;

  AvatarLocalDataSourceImpl(this.storage);

  @override
  Future<AvatarConfig?> loadAvatarConfig() async {
    final key = storage.keyFor('avatar_config');
    final prefs = storage.preferences;
    final raw = prefs.get(key);
    if (raw == null) return null;
    try {
      final jsonMap = jsonDecode(raw as String) as Map<String, dynamic>;
      return AvatarConfig.fromJson(jsonMap);
    } catch (_) {
      await prefs.remove(key);
      return null;
    }
  }

  @override
  Future<void> saveAvatarConfig(AvatarConfig config) async {
    final key = storage.keyFor('avatar_config');
    final jsonString = jsonEncode(config.toJson());
    await storage.writeString(key, jsonString);
  }
}
