import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_settings_store.g.dart';

@riverpod
AppSettingsStore appSettingsStore(Ref ref) {
  return AppSettingsStore(Hive.box<String>(HiveBoxNames.prefs));
}

class AppSettingsStore {
  const AppSettingsStore(this._prefsBox);

  final Box<String> _prefsBox;

  String readString(String key, {required String defaultValue}) {
    return _prefsBox.get(key, defaultValue: defaultValue) ?? defaultValue;
  }

  Future<void> writeString(String key, String value) {
    return _prefsBox.put(key, value);
  }

  bool readBool(String key, {required bool defaultValue}) {
    final String defaultRawValue = defaultValue ? 'true' : 'false';
    final String rawValue =
        _prefsBox.get(key, defaultValue: defaultRawValue) ?? defaultRawValue;
    return rawValue == 'true';
  }

  Future<void> writeBool(String key, bool value) {
    return _prefsBox.put(key, value ? 'true' : 'false');
  }

  double readDouble(String key, {required double defaultValue}) {
    final String defaultRawValue = defaultValue.toString();
    final String rawValue =
        _prefsBox.get(key, defaultValue: defaultRawValue) ?? defaultRawValue;
    return double.tryParse(rawValue) ?? defaultValue;
  }

  Future<void> writeDouble(String key, double value) {
    return _prefsBox.put(key, value.toString());
  }

  Future<void> remove(String key) {
    return _prefsBox.delete(key);
  }
}
