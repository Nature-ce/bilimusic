import 'dart:ui' as ui;

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:flutter/material.dart';

enum PlayerBackdropVariant { mobile, desktop }

/// 播放页背景：封面放大 + 高斯模糊 + 自上而下加深的深色蒙层。
///
/// 与刷歌页共用同一套视觉，播放页统一深色底 + 白字。
class PlayerDynamicBackdrop extends StatelessWidget {
  const PlayerDynamicBackdrop({
    super.key,
    required this.baseColor,
    this.coverUrl,
    this.variant = PlayerBackdropVariant.mobile,
  });

  final Color? baseColor;
  final String? coverUrl;
  final PlayerBackdropVariant variant;

  static const Duration _colorTransitionDuration = Duration(milliseconds: 1000);
  static const double _blurSigma = 36;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color resolvedBaseColor = baseColor ?? colorScheme.primary;
    final _BackdropColors colors = _BackdropColors.from(
      baseColor: resolvedBaseColor,
      colorScheme: colorScheme,
    );

    return IgnorePointer(
      child: RepaintBoundary(
        child: TweenAnimationBuilder<_BackdropColors>(
          tween: _BackdropColorsTween(end: colors),
          duration: _colorTransitionDuration,
          curve: Curves.easeOutCubic,
          builder:
              (
                BuildContext context,
                _BackdropColors animatedColors,
                Widget? child,
              ) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const ColoredBox(color: Color(0xFF15100E)),
                    _buildBlurredCover(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            animatedColors.top,
                            animatedColors.center,
                            animatedColors.bottom,
                          ],
                          stops: const <double>[0, 0.55, 1],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    _BackdropGlow(
                      alignment: variant == PlayerBackdropVariant.desktop
                          ? const Alignment(-0.42, -0.08)
                          : const Alignment(-0.34, -0.28),
                      color: animatedColors.glow,
                      widthFactor: variant == PlayerBackdropVariant.desktop
                          ? 0.52
                          : 0.64,
                      heightFactor: variant == PlayerBackdropVariant.desktop
                          ? 0.72
                          : 0.42,
                      opacity: variant == PlayerBackdropVariant.desktop
                          ? 0.24
                          : 0.20,
                    ),
                  ],
                );
              },
        ),
      ),
    );
  }

  Widget _buildBlurredCover() {
    final String? coverUrl = this.coverUrl;
    if (coverUrl == null || coverUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: _blurSigma,
        sigmaY: _blurSigma,
        tileMode: TileMode.decal,
      ),
      child: CommonCachedImage(
        imageUrl: coverUrl,
        fit: BoxFit.cover,
        backgroundColor: Colors.transparent,
        fallbackIcon: Icons.music_note_rounded,
        iconColor: const Color(0x33FFFFFF),
      ),
    );
  }
}

class _BackdropColorsTween extends Tween<_BackdropColors> {
  _BackdropColorsTween({required _BackdropColors end}) : super(end: end);

  @override
  _BackdropColors lerp(double t) {
    final _BackdropColors? beginColors = begin;
    final _BackdropColors? endColors = end;

    if (beginColors == null || endColors == null) {
      return endColors ?? beginColors!;
    }

    return _BackdropColors.lerp(beginColors, endColors, t);
  }
}

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow({
    required this.alignment,
    required this.color,
    required this.widthFactor,
    required this.heightFactor,
    required this.opacity,
  });

  final Alignment alignment;
  final Color color;
  final double widthFactor;
  final double heightFactor;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Align(
          alignment: alignment,
          child: Container(
            width: constraints.maxWidth * widthFactor,
            height: constraints.maxHeight * heightFactor,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: <Color>[
                  color.withValues(alpha: opacity),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BackdropColors {
  const _BackdropColors({
    required this.top,
    required this.center,
    required this.bottom,
    required this.glow,
    required this.accent,
  });

  final Color top;
  final Color center;
  final Color bottom;
  final Color glow;
  final Color accent;

  @override
  int get hashCode => Object.hash(top, center, bottom, glow, accent);

  @override
  bool operator ==(Object other) {
    return other is _BackdropColors &&
        other.top == top &&
        other.center == center &&
        other.bottom == bottom &&
        other.glow == glow &&
        other.accent == accent;
  }

  static _BackdropColors lerp(_BackdropColors a, _BackdropColors b, double t) {
    return _BackdropColors(
      top: Color.lerp(a.top, b.top, t) ?? b.top,
      center: Color.lerp(a.center, b.center, t) ?? b.center,
      bottom: Color.lerp(a.bottom, b.bottom, t) ?? b.bottom,
      glow: Color.lerp(a.glow, b.glow, t) ?? b.glow,
      accent: Color.lerp(a.accent, b.accent, t) ?? b.accent,
    );
  }

  factory _BackdropColors.from({
    required Color baseColor,
    required ColorScheme colorScheme,
  }) {
    // 播放页统一深色底，只取封面主色的暗调，保证白字始终可读。
    final HSLColor hsl = HSLColor.fromColor(baseColor);
    final Color top = _blend(
      hsl
          .withSaturation(_clampSaturation(hsl.saturation, 0.32))
          .withLightness(0.30)
          .toColor(),
      colorScheme.surface,
      0.14,
    );
    final Color center = _blend(
      hsl
          .withSaturation(_clampSaturation(hsl.saturation, 0.28))
          .withLightness(0.24)
          .toColor(),
      colorScheme.surface,
      0.20,
    );
    final Color bottom = _blend(
      hsl
          .withSaturation(_clampSaturation(hsl.saturation, 0.18))
          .withLightness(0.12)
          .toColor(),
      colorScheme.surface,
      0.32,
    );
    final Color glow = hsl
        .withSaturation(_clampSaturation(hsl.saturation, 0.45))
        .withLightness(0.28)
        .toColor();
    final Color accent = hsl
        .withSaturation(_clampSaturation(hsl.saturation, 0.58))
        .withLightness(0.54)
        .toColor();

    return _BackdropColors(
      top: top,
      center: center,
      bottom: bottom,
      glow: glow,
      accent: accent,
    );
  }

  static double _clampSaturation(double value, double target) {
    return value.clamp(0.18, target).toDouble();
  }

  static Color _blend(Color color, Color surface, double surfaceOpacity) {
    return Color.lerp(color, surface, surfaceOpacity) ?? color;
  }
}
