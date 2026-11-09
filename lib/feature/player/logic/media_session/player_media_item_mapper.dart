import 'package:audio_service/audio_service.dart';
import 'package:bilimusic/common/util/display_text.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_metadata.dart';

MediaItem buildPlayerMediaItem(
  PlayableItem item, {
  required AudioStreamInfo audioStream,
  required String? queueSourceLabel,
  Duration? duration,
  PlayerDisplayInfo? display,
}) {
  final String pageTitle = normalizeDisplayTextOrEmpty(audioStream.pageTitle);
  final String qualityLabel = audioStream.qualityLabel?.trim() ?? '';
  final List<String> descriptionParts = <String>[
    if (pageTitle.isNotEmpty) pageTitle,
    if (qualityLabel.isNotEmpty) qualityLabel,
  ];

  return buildPlayerQueueMediaItem(
    item,
    queueSourceLabel: queueSourceLabel,
    duration: duration ?? audioStream.duration,
    display: display,
  ).copyWith(displayDescription: descriptionParts.join(' · '));
}

MediaItem buildPlayerQueueMediaItem(
  PlayableItem item, {
  required String? queueSourceLabel,
  Duration? duration,
  PlayerDisplayInfo? display,
}) {
  final PlayerDisplayInfo info =
      !item.isSpoken && display?.stableId == item.stableId
      ? display!
      : resolvePlayerDisplayInfo(
          item: item,
          metadata: null,
          source: PlayerDisplaySource.bilibili,
        );
  final String album = normalizeDisplayTextOrEmpty(queueSourceLabel);
  final String fallbackTitle = normalizeDisplayTextOrEmpty(item.title);
  final String fallbackArtist = normalizeDisplayTextOrEmpty(item.author);

  return MediaItem(
    id: item.stableId,
    album: album.isEmpty ? 'Bilibili' : album,
    title: info.title ?? fallbackTitle,
    artist: info.artist ?? fallbackArtist,
    artUri: info.coverUrl == null ? null : Uri.tryParse(info.coverUrl!),
    duration: duration,
    displayTitle: info.title ?? fallbackTitle,
    displaySubtitle: info.artist ?? fallbackArtist,
    displayDescription: normalizeDisplayTextOrEmpty(item.pageTitle),
  );
}
