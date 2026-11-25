/// 倍速播放的可选档位：0.5x ~ 3.0x，0.05x 一档（共 51 档）。
///
/// 用整数换算避免浮点累加误差（50 + index * 5）/ 100。
final List<double> kPlayerPlaybackSpeeds = List<double>.unmodifiable(<double>[
  for (int index = 0; index <= 50; index += 1) (50 + index * 5) / 100,
]);

/// 桌面端菜单这类空间有限的地方用粗一点的常用档位。
const List<double> kPlayerPlaybackSpeedPresets = <double>[
  0.75,
  1.0,
  1.25,
  1.5,
  1.75,
  2.0,
  2.5,
  3.0,
];

/// 1.35x 这种两位小数原样显示，1.0 / 1.5 这类只留一位。
String formatPlaybackSpeed(double speed) {
  final int hundredths = (speed * 100).round();
  final String value = hundredths % 10 == 0
      ? (hundredths / 100).toStringAsFixed(1)
      : (hundredths / 100).toStringAsFixed(2);
  return '${value}x';
}
