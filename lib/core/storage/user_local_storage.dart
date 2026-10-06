import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../errors/exceptions.dart';

/// Local profile separation, not a substitute for authenticated secure storage.
class UserLocalStorage {
  final SharedPreferences preferences;
  String? _userId;

  UserLocalStorage(this.preferences);

  String? get userId => _userId;

  String keyFor(String name) {
    final userId = _userId;
    if (userId == null) throw const CacheException('No hay una sesión activa');
    return 'user_${base64Url.encode(utf8.encode(userId))}_$name';
  }

  Future<void> activate(String userId, {bool migrateLegacy = false}) async {
    // Only a session that existed before the migration may claim old global data.
    if (!preferences.containsKey('legacy_data_owner')) {
      await writeString(
          'legacy_data_owner', migrateLegacy ? userId : 'unassigned');
    }
    if (migrateLegacy && preferences.getString('legacy_data_owner') == userId) {
      final prefix = 'user_${base64Url.encode(utf8.encode(userId))}_';
      final pain = preferences.get('pain_records');
      if (pain is List<String> &&
          !preferences.containsKey('${prefix}pain_records')) {
        await writeStringList('${prefix}pain_records', pain);
      }
      final avatar = preferences.get('avatar_config');
      if (avatar is String &&
          !preferences.containsKey('${prefix}avatar_config')) {
        await writeString('${prefix}avatar_config', avatar);
      }
    }
    _userId = userId;
  }

  void clearSession() => _userId = null;

  Future<void> writeString(String key, String value) async {
    if (!await preferences.setString(key, value)) {
      throw const CacheException('No se pudieron guardar los datos locales');
    }
  }

  Future<void> writeStringList(String key, List<String> value) async {
    if (!await preferences.setStringList(key, value)) {
      throw const CacheException('No se pudieron guardar los datos locales');
    }
  }
}
