import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:flutter/material.dart';

class MusicPlatformBadge extends StatelessWidget {
  const MusicPlatformBadge({super.key, required this.platform, this.size = 14});

  final MusicChartPlatform platform;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (Color color, String glyph) = switch (platform) {
      MusicChartPlatform.netease => (const Color(0xFFE60026), '云'),
      MusicChartPlatform.tencent => (const Color(0xFF31C27C), 'Q'),
      MusicChartPlatform.kugou => (const Color(0xFF0FB7F3), '酷'),
    };

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text(
        glyph,
        style: TextStyle(
          fontSize: size * 0.58,
          height: 1,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
