import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/updater/domain/update_source.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_source_logic.g.dart';

@riverpod
class UpdateSourceLogic extends _$UpdateSourceLogic {
  @override
  UpdateSource build() {
    final String stored = ref
        .read(appSettingsStoreProvider)
        .readString(
          HiveKeys.updateSource,
          defaultValue: UpdateSource.fork.name,
        );
    return UpdateSource.fromName(stored);
  }

  Future<void> setSource(UpdateSource source) async {
    state = source;
    await ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.updateSource, source.name);
  }
}
