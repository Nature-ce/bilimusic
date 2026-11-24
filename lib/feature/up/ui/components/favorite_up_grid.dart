import 'package:bilimusic/common/components/user_avatar.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/domain/favorite_up_update.dart';
import 'package:flutter/material.dart';

const String favoriteUpUnknownUpdateLabel = '—';

enum FavoriteUpFilter { all, today, mostListened }

extension FavoriteUpFilterLabel on FavoriteUpFilter {
  String get label {
    return switch (this) {
      FavoriteUpFilter.all => '全部',
      FavoriteUpFilter.today => '今日更新',
      FavoriteUpFilter.mostListened => '常听',
    };
  }
}

String favoriteUpUpdateLabel(FavoriteUpUpdate? update, {DateTime? now}) {
  if (update == null || update.failed) {
    return favoriteUpUnknownUpdateLabel;
  }
  if (update.todayVideoCount > 0) {
    return '今日 ${update.todayVideoCount} 首更新';
  }
  final int? latestPublishAtEpochMs = update.latestPublishAtEpochMs;
  if (latestPublishAtEpochMs == null || latestPublishAtEpochMs <= 0) {
    return favoriteUpUnknownUpdateLabel;
  }
  final int days = _localDayDifference(
    latestPublishAtEpochMs,
    now ?? DateTime.now(),
  );
  if (days <= 0) {
    return '今天更新';
  }
  if (days == 1) {
    return '昨天更新';
  }
  if (days < 7) {
    return '$days 天前';
  }
  if (days < 30) {
    return '${days ~/ 7} 周前';
  }
  return '${days ~/ 30} 个月前';
}

List<FavoriteUp> filterFavoriteUps({
  required List<FavoriteUp> ups,
  required FavoriteUpFilter filter,
  required Map<int, FavoriteUpUpdate> updates,
  required Map<String, int> playedMsByAuthor,
  DateTime? now,
}) {
  switch (filter) {
    case FavoriteUpFilter.all:
      return List<FavoriteUp>.of(ups);
    case FavoriteUpFilter.today:
      final DateTime current = now ?? DateTime.now();
      return ups
          .where((FavoriteUp up) => _hasTodayUpdate(updates[up.mid], current))
          .toList(growable: false);
    case FavoriteUpFilter.mostListened:
      final List<FavoriteUp> sorted = List<FavoriteUp>.of(ups);
      sorted.sort((FavoriteUp left, FavoriteUp right) {
        final int leftMs = playedMsByAuthor[left.name.trim()] ?? 0;
        final int rightMs = playedMsByAuthor[right.name.trim()] ?? 0;
        if (leftMs != rightMs) {
          return rightMs.compareTo(leftMs);
        }
        return right.favoritedAtEpochMs.compareTo(left.favoritedAtEpochMs);
      });
      return sorted;
  }
}

bool _hasTodayUpdate(FavoriteUpUpdate? update, DateTime now) {
  if (update == null || update.failed || update.todayVideoCount <= 0) {
    return false;
  }
  return _localDayDifference(update.fetchedAtEpochMs, now) <= 0;
}

int _localDayDifference(int epochMs, DateTime now) {
  final DateTime time = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final DateTime today = DateTime.utc(now.year, now.month, now.day);
  final DateTime day = DateTime.utc(time.year, time.month, time.day);
  return today.difference(day).inDays;
}

class FavoriteUpGrid extends StatelessWidget {
  const FavoriteUpGrid({
    super.key,
    required this.ups,
    required this.updates,
    required this.onTap,
    this.onLongPress,
    this.now,
  });

  static const double _spacing = 12;
  static const double _horizontalPadding = 16;
  static const double _topPadding = 12;
  static const double _bottomPadding = 24;
  static const double _avatarDiameter = 64;
  static const double _verticalPadding = 18;
  static const double _nameGap = 8;
  static const double _metaGap = 4;
  static const double _nameHeight = 14.5 * 1.2;
  static const double _metaHeight = 11.5 * 1.2;
  static const double _extentSlack = 2;

  final List<FavoriteUp> ups;
  final Map<int, FavoriteUpUpdate> updates;
  final ValueChanged<FavoriteUp> onTap;
  final ValueChanged<FavoriteUp>? onLongPress;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final double tileExtent =
        _verticalPadding * 2 +
        _avatarDiameter +
        _nameGap +
        textScaler.scale(_nameHeight) +
        _metaGap +
        textScaler.scale(_metaHeight) +
        _extentSlack;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        _topPadding,
        _horizontalPadding,
        _bottomPadding,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: _spacing,
        crossAxisSpacing: _spacing,
        mainAxisExtent: tileExtent,
      ),
      itemCount: ups.length,
      itemBuilder: (BuildContext context, int index) {
        final FavoriteUp up = ups[index];
        return FavoriteUpGridTile(
          up: up,
          update: updates[up.mid],
          now: now,
          onTap: () => onTap(up),
          onLongPress: onLongPress == null ? null : () => onLongPress!(up),
        );
      },
    );
  }
}

class FavoriteUpGridTile extends StatelessWidget {
  const FavoriteUpGridTile({
    super.key,
    required this.up,
    this.update,
    this.onTap,
    this.onLongPress,
    this.now,
  });

  static const double radius = 18;
  static const double avatarRadius = 32;
  static const double _horizontalPadding = 12;
  static const double _verticalPadding = 18;
  static const double _nameGap = 8;
  static const double _metaGap = 4;

  final FavoriteUp up;
  final FavoriteUpUpdate? update;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: appCardSurfaceColor(context),
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: _verticalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _FavoriteUpAvatar(up: up),
              const SizedBox(height: _nameGap),
              Text(
                up.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: _metaGap),
              Text(
                favoriteUpUpdateLabel(update, now: now),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteUpAvatar extends StatelessWidget {
  const _FavoriteUpAvatar({required this.up});

  final FavoriteUp up;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (up.avatarUrl.isEmpty) {
      return Container(
        width: FavoriteUpGridTile.avatarRadius * 2,
        height: FavoriteUpGridTile.avatarRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary.withValues(alpha: 0.12),
        ),
        child: Icon(
          Icons.person_rounded,
          size: FavoriteUpGridTile.avatarRadius,
          color: colorScheme.primary,
        ),
      );
    }
    return UserAvatar(
      avatarUrl: up.avatarUrl,
      officialType: up.officialType,
      useCache: true,
      radius: FavoriteUpGridTile.avatarRadius,
    );
  }
}

class FavoriteUpFilterChip extends StatelessWidget {
  const FavoriteUpFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const double height = 32;
  static const double _horizontalPadding = 14;

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color backgroundColor = selected
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final Color foregroundColor = selected
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          selected: selected,
          button: true,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
