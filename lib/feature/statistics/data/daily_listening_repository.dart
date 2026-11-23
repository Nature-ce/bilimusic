import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:hive_ce/hive.dart';

const String dailyListeningBoxName = 'listening_daily';

class DailyListeningRepository {
  const DailyListeningRepository(this._box);

  final Box<Map> _box;

  DailyListening read(DateTime day) {
    final Map? value = _box.get(_key(day));
    if (value == null) {
      return const DailyListening();
    }
    return DailyListening(
      listenedMs: (value['listenedMs'] as num?)?.toInt() ?? 0,
      songs: (value['songs'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> addListenedMs(DateTime day, int deltaMs) async {
    if (deltaMs <= 0) {
      return;
    }
    final DailyListening current = read(day);
    await _write(
      day,
      current.copyWith(listenedMs: current.listenedMs + deltaMs),
    );
  }

  Future<void> addSong(DateTime day) async {
    final DailyListening current = read(day);
    await _write(day, current.copyWith(songs: current.songs + 1));
  }

  WeeklyListeningSummary summary([DateTime? now]) {
    final DateTime today = _startOfDay(now ?? DateTime.now());
    final DateTime weekStart = today.subtract(
      Duration(days: today.weekday - 1),
    );
    final List<DailyListening> days = <DailyListening>[
      for (int index = 0; index < 7; index += 1)
        read(weekStart.add(Duration(days: index))),
    ];
    int weekListenedMs = 0;
    int weekSongs = 0;
    for (final DailyListening day in days) {
      weekListenedMs += day.listenedMs;
      weekSongs += day.songs;
    }
    int lastWeekSongs = 0;
    for (int index = 0; index < 7; index += 1) {
      lastWeekSongs += read(
        weekStart.subtract(Duration(days: 7 - index)),
      ).songs;
    }
    return WeeklyListeningSummary(
      days: days,
      weekListenedMs: weekListenedMs,
      weekSongs: weekSongs,
      lastWeekSongs: lastWeekSongs,
    );
  }

  DateTime weekStartOf([DateTime? now]) {
    final DateTime today = _startOfDay(now ?? DateTime.now());
    return today.subtract(Duration(days: today.weekday - 1));
  }

  List<DailyListening> readDays(DateTime start, {int count = 7}) {
    final DateTime first = _startOfDay(start);
    return <DailyListening>[
      for (int index = 0; index < count; index += 1)
        read(first.add(Duration(days: index))),
    ];
  }

  int listenedDaysInRow([DateTime? now]) {
    final DateTime today = _startOfDay(now ?? DateTime.now());
    final bool listenedToday = read(today).listenedMs > 0;
    int days = 0;
    int offset = listenedToday ? 0 : 1;
    while (offset < 366) {
      if (read(today.subtract(Duration(days: offset))).listenedMs <= 0) {
        break;
      }
      days += 1;
      offset += 1;
    }
    return days;
  }

  Future<void> _write(DateTime day, DailyListening value) {
    return _box.put(_key(day), <String, Object?>{
      'listenedMs': value.listenedMs,
      'songs': value.songs,
    });
  }

  DateTime _startOfDay(DateTime time) {
    return DateTime(time.year, time.month, time.day);
  }

  String _key(DateTime day) {
    final String month = day.month.toString().padLeft(2, '0');
    final String date = day.day.toString().padLeft(2, '0');
    return '${day.year}-$month-$date';
  }
}
