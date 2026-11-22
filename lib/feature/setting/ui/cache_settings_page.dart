import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/feature/setting/ui/components/settings_tiles.dart';
import 'package:flutter/material.dart';

class CacheSettingsPage extends StatefulWidget {
  const CacheSettingsPage({super.key});

  @override
  State<CacheSettingsPage> createState() => _CacheSettingsPageState();
}

class _CacheSettingsPageState extends State<CacheSettingsPage> {
  int _imageCacheBytes = 0;
  int _audioCacheBytes = 0;
  int _lyricsCacheBytes = 0;
  int _metadataCacheBytes = 0;
  bool _imageSelected = true;
  bool _audioSelected = true;
  bool _lyricsSelected = true;
  bool _metadataSelected = true;
  bool _isLoading = true;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _loadCacheSizes();
  }

  int get _totalCacheBytes =>
      _imageCacheBytes +
      _audioCacheBytes +
      _lyricsCacheBytes +
      _metadataCacheBytes;

  int get _selectedCacheBytes {
    int total = 0;
    if (_imageSelected) {
      total += _imageCacheBytes;
    }
    if (_audioSelected) {
      total += _audioCacheBytes;
    }
    if (_lyricsSelected) {
      total += _lyricsCacheBytes;
    }
    if (_metadataSelected) {
      total += _metadataCacheBytes;
    }
    return total;
  }

  bool get _hasSelectedCache => _selectedCacheBytes > 0;

  bool get _allSelected =>
      _imageSelected && _audioSelected && _lyricsSelected && _metadataSelected;

  Future<void> _loadCacheSizes() async {
    final List<int> sizes = await Future.wait<int>(<Future<int>>[
      CacheUtil.getImageCacheSizeBytes(),
      CacheUtil.getAudioCacheSizeBytes(),
      CacheUtil.getLyricsCacheSizeBytes(),
      CacheUtil.getMetadataCacheSizeBytes(),
    ]);

    if (!mounted) {
      return;
    }

    setState(() {
      _imageCacheBytes = sizes[0];
      _audioCacheBytes = sizes[1];
      _lyricsCacheBytes = sizes[2];
      _metadataCacheBytes = sizes[3];
      _isLoading = false;
    });
  }

  Future<void> _toggleAndClearSelected() async {
    if (!_hasSelectedCache || _isClearing) {
      return;
    }

    final bool shouldClear =
        await _showClearCacheDialog(
          context,
          cacheSizeLabel: formatBytes(_selectedCacheBytes),
        ) ??
        false;
    if (!shouldClear) {
      return;
    }

    setState(() {
      _isClearing = true;
    });

    try {
      final List<Future<void>> tasks = <Future<void>>[];
      if (_imageSelected) {
        tasks.add(CacheUtil.clearImageCache());
      }
      if (_audioSelected) {
        tasks.add(CacheUtil.clearAudioCache());
      }
      if (_lyricsSelected) {
        tasks.add(CacheUtil.clearLyricsCache());
      }
      if (_metadataSelected) {
        tasks.add(CacheUtil.clearMetadataCache());
      }

      await Future.wait<void>(tasks);
      await _loadCacheSizes();

      if (!mounted) {
        return;
      }

      ToastUtil.show('所选缓存已清理');
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }

  void _toggleAllSelected() {
    if (_isLoading || _isClearing) {
      return;
    }

    final bool nextSelected = !_allSelected;
    setState(() {
      _imageSelected = nextSelected;
      _audioSelected = nextSelected;
      _lyricsSelected = nextSelected;
      _metadataSelected = nextSelected;
    });
  }

  void _toggleImageSelected() {
    setState(() {
      _imageSelected = !_imageSelected;
    });
  }

  void _toggleAudioSelected() {
    setState(() {
      _audioSelected = !_audioSelected;
    });
  }

  void _toggleLyricsSelected() {
    setState(() {
      _lyricsSelected = !_lyricsSelected;
    });
  }

  void _toggleMetadataSelected() {
    setState(() {
      _metadataSelected = !_metadataSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool interactive = !_isLoading && !_isClearing;

    return Scaffold(
      appBar: AppBar(title: const Text('缓存管理')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: <Widget>[
          SettingsHighlightCard(
            title: '共占用',
            titleTrailing: InkWell(
              onTap: _toggleAllSelected,
              child: Text(
                _allSelected ? '取消全选' : '全选',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            value: formatBytes(_totalCacheBytes),
            footnote: '可随时清理，不影响收藏与歌单',
          ),
          SettingsGroup(
            title: '分类',
            children: <Widget>[
              SettingsCheckTile(
                title: '图片缓存',
                icon: Icons.image_outlined,
                tint: SettingsTint.blue,
                value: formatBytes(_imageCacheBytes),
                selected: _imageSelected,
                enabled: interactive,
                onTap: _toggleImageSelected,
              ),
              SettingsCheckTile(
                title: '音频缓存',
                icon: Icons.audiotrack_outlined,
                tint: SettingsTint.green,
                value: formatBytes(_audioCacheBytes),
                selected: _audioSelected,
                enabled: interactive,
                onTap: _toggleAudioSelected,
              ),
              SettingsCheckTile(
                title: '歌词缓存',
                icon: Icons.lyrics_outlined,
                tint: SettingsTint.amber,
                value: formatBytes(_lyricsCacheBytes),
                selected: _lyricsSelected,
                enabled: interactive,
                onTap: _toggleLyricsSelected,
              ),
              SettingsCheckTile(
                title: '元信息缓存',
                icon: Icons.info_outline_rounded,
                tint: SettingsTint.violet,
                value: formatBytes(_metadataCacheBytes),
                selected: _metadataSelected,
                enabled: interactive,
                onTap: _toggleMetadataSelected,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SettingsPrimaryButton(
              label: '清空所选缓存 · ${formatBytes(_selectedCacheBytes)}',
              onPressed: _hasSelectedCache && interactive
                  ? _toggleAndClearSelected
                  : null,
              busy: _isClearing,
            ),
          ),
          const SettingsInfoNote(text: '清理后不会删除收藏与歌单；音频会在下次播放时重新缓存，歌词会重新匹配。'),
        ],
      ),
    );
  }
}

Future<bool?> _showClearCacheDialog(
  BuildContext context, {
  required String cacheSizeLabel,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('确认清空所选缓存吗？'),
        content: Text('将清理 $cacheSizeLabel 的图片、音频、歌词与元信息缓存，后续使用时会重新下载或重新拉取。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      );
    },
  );
}
