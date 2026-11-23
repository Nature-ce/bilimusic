import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;

    return IconButton(
      tooltip: '返回',
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      color: iconColor,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      onPressed: () => Navigator.maybePop(context),
    );
  }
}
