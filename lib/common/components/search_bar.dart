import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

/// 搜索条：实心浅灰填充、全圆角、无描边，左侧线性放大镜。
class CommonSearchBar extends StatelessWidget {
  const CommonSearchBar({
    super.key,
    this.onTap,
    this.hintText = '',
    this.margin,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    this.height = AppSizes.searchBarHeight,
  });

  final VoidCallback? onTap;
  final String hintText;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Ink(
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: appFillColor(context),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: appTertiaryTextColor(context),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.2,
                      color: appSecondaryTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
