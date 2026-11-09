import 'package:bilimusic/common/components/sequence_play_icon.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

Widget queueModeIcon(PlayerQueueMode mode) {
  return switch (mode) {
    PlayerQueueMode.sequence => HugeIcon(
      icon: HugeIcons.strokeRoundedRepeat,
      size: 22,
    ),
    PlayerQueueMode.singleRepeat => HugeIcon(
      icon: HugeIcons.strokeRoundedRepeatOne01,
      size: 22,
    ),
    PlayerQueueMode.shuffle => HugeIcon(
      icon: HugeIcons.strokeRoundedShuffle,
      size: 22,
    ),
    PlayerQueueMode.sequenceOnce => const SequencePlayIcon(size: 22),
  };
}
