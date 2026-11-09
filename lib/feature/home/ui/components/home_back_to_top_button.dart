import 'package:bilimusic/feature/home/logic/home_back_to_top.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeBackToTopButton extends ConsumerWidget {
  const HomeBackToTopButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.small(
      tooltip: '回到顶部',
      heroTag: 'home_back_to_top',
      onPressed: () {
        final ScrollController controller = ref.read(
          homeScrollControllerProvider,
        );
        if (!controller.hasClients) {
          return;
        }
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      },
      child: const Icon(Icons.arrow_upward_rounded),
    );
  }
}
