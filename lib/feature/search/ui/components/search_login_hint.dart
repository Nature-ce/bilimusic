import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 游客搜索更容易被 B 站风控，这里提示登录（登录后配额更高）。
class SearchLoginHint extends ConsumerWidget {
  const SearchLoginHint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BiliSession? session = ref.watch(biliSessionControllerProvider);
    if (session?.isLoggedIn ?? false) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '登录 B 站账号后搜索更稳定，游客更容易被限流',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            key: const Key('searchLoginHintAction'),
            onPressed: () => context.push('/auth'),
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }
}
