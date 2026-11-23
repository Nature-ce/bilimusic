import 'package:bilimusic/common/components/user_avatar.dart';
import 'package:bilimusic/feature/search/domain/search_user_item.dart';
import 'package:flutter/material.dart';

class SearchRelatedUsers extends StatelessWidget {
  const SearchRelatedUsers({
    super.key,
    required this.users,
    required this.onTapUser,
  });

  final List<SearchUserItem> users;
  final ValueChanged<SearchUserItem> onTapUser;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '相关 UP 主',
            style: TextStyle(
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final SearchUserItem user in users)
                  _SearchRelatedUserCard(
                    user: user,
                    onTap: () => onTapUser(user),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRelatedUserCard extends StatelessWidget {
  const _SearchRelatedUserCard({required this.user, required this.onTap});

  final SearchUserItem user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String subtitle = user.fansText.isEmpty
        ? user.sign
        : '粉丝 ${user.fansText}';

    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 76,
            child: Column(
              children: <Widget>[
                UserAvatar(
                  avatarUrl: user.avatarUrl,
                  officialType: user.officialType,
                  radius: 28,
                  tipSize: 14,
                ),
                const SizedBox(height: 8),
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (subtitle.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
