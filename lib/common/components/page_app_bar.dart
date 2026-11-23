import 'package:bilimusic/common/components/app_back_button.dart';
import 'package:flutter/material.dart';

class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PageAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.leadingWidth,
    this.automaticallyImplyLeading = true,
    this.centerTitle,
    this.titleSpacing,
    this.toolbarHeight,
    this.backgroundColor,
    this.foregroundColor,
    this.flexibleSpace,
    this.titleTextStyle,
    this.elevation,
    this.shape,
    this.iconTheme,
    this.scrolledUnderElevation,
  });

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final double? leadingWidth;
  final bool automaticallyImplyLeading;
  final bool? centerTitle;
  final double? titleSpacing;
  final double? toolbarHeight;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? flexibleSpace;
  final TextStyle? titleTextStyle;
  final double? elevation;
  final ShapeBorder? shape;
  final IconThemeData? iconTheme;
  final double? scrolledUnderElevation;

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final bool routeCanPop =
        ModalRoute.of(context)?.canPop ?? Navigator.of(context).canPop();
    final bool canPop =
        automaticallyImplyLeading && leading == null && routeCanPop;
    final Widget? resolvedLeading =
        leading ?? (canPop ? const AppBackButton() : null);
    final double? resolvedTitleSpacing = titleSpacing ?? (canPop ? 2 : null);
    final double? resolvedLeadingWidth = leadingWidth ?? (canPop ? 44 : null);

    return AppBar(
      title: title,
      actions: actions,
      bottom: bottom,
      leading: resolvedLeading,
      leadingWidth: resolvedLeadingWidth,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      titleSpacing: resolvedTitleSpacing,
      toolbarHeight: toolbarHeight,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      flexibleSpace: flexibleSpace,
      titleTextStyle: titleTextStyle,
      elevation: elevation,
      shape: shape,
      iconTheme: iconTheme,
      scrolledUnderElevation: scrolledUnderElevation,
    );
  }
}
