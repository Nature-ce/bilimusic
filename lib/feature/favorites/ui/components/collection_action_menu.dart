import 'package:bilimusic/common/components/login_required.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/ui/components/collection_name_dialog.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CollectionAction {
  multiSelect,
  rename,
  delete,
  remove,
  sync,
  uploadToRemote,
}

/// 歌单（收藏夹）操作菜单：我的页长按卡片、歌单详情页右上角都用它。
Future<void> showFavoriteCollectionActionMenu({
  required BuildContext context,
  required WidgetRef ref,
  required FavoriteCollection collection,
  required Offset globalPosition,
  VoidCallback? onMultiSelect,
}) async {
  if (collection.isSystem && !collection.isRemote && onMultiSelect == null) {
    return;
  }
  final OverlayState overlay = Overlay.of(context);
  final RenderBox overlayBox = overlay.context.findRenderObject()! as RenderBox;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(globalPosition, globalPosition.translate(1, 1)),
    Offset.zero & overlayBox.size,
  );

  HapticFeedback.lightImpact();
  final ThemeData theme = Theme.of(context);
  final ColorScheme colorScheme = theme.colorScheme;

  final CollectionAction? action = await showMenu<CollectionAction>(
    context: context,
    position: position,
    useRootNavigator: true,
    color: appCardSurfaceColor(context),
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.45),
      ),
    ),
    constraints: const BoxConstraints(minWidth: 196, maxWidth: 236),
    items: <PopupMenuEntry<CollectionAction>>[
      if (onMultiSelect != null)
        _menuItem(
          CollectionAction.multiSelect,
          Icons.checklist_rounded,
          '\u591a\u9009',
        ),
      if (!collection.isSystem)
        _menuItem(
          CollectionAction.rename,
          Icons.drive_file_rename_outline_rounded,
          '\u91cd\u547d\u540d',
        ),
      if (collection.isRemote)
        _menuItem(CollectionAction.sync, Icons.sync_rounded, '\u540c\u6b65'),
      if (collection.isRemote)
        _menuItem(
          CollectionAction.remove,
          Icons.remove_circle_outline_rounded,
          '\u89e3\u9664\u7ed1\u5b9a',
        ),
      if (!collection.isSystem && !collection.isRemote)
        _menuItem(
          CollectionAction.uploadToRemote,
          Icons.cloud_upload_outlined,
          '\u4e0a\u4f20\u5230 B \u7ad9\u5e76\u540c\u6b65',
        ),
      if (!collection.isSystem)
        _menuItem(
          CollectionAction.delete,
          Icons.delete_outline_rounded,
          '\u5220\u9664',
          danger: true,
        ),
    ],
  );

  if (action == null || !context.mounted) {
    return;
  }

  switch (action) {
    case CollectionAction.multiSelect:
      onMultiSelect?.call();
    case CollectionAction.rename:
      await _showRenameCollectionDialog(
        context: context,
        ref: ref,
        collection: collection,
      );
    case CollectionAction.sync:
      await _syncRemoteCollection(
        context: context,
        ref: ref,
        collection: collection,
      );
    case CollectionAction.uploadToRemote:
      await _uploadCollectionToRemote(
        context: context,
        ref: ref,
        collection: collection,
      );
    case CollectionAction.delete:
      await _showDeleteCollectionDialog(
        context: context,
        ref: ref,
        collection: collection,
      );
    case CollectionAction.remove:
      await _showRemoveRemoteCollectionDialog(
        context: context,
        ref: ref,
        collection: collection,
      );
  }
}

Future<void> _syncRemoteCollection({
  required BuildContext context,
  required WidgetRef ref,
  required FavoriteCollection collection,
}) async {
  ToastUtil.show('正在同步“${collection.name}”…');
  try {
    await ref
        .read(favoritesControllerProvider.notifier)
        .syncRemoteCollectionIfStale(collection.id, force: true);
    if (context.mounted) {
      ToastUtil.show('同步完成');
    }
  } on Object {
    if (context.mounted) {
      ToastUtil.show('同步失败，请稍后重试');
    }
  }
}

Future<void> _uploadCollectionToRemote({
  required BuildContext context,
  required WidgetRef ref,
  required FavoriteCollection collection,
}) async {
  final bool isLoggedIn =
      ref.read(biliSessionControllerProvider)?.isLoggedIn ?? false;
  if (!isLoggedIn) {
    LoginPrompt.show(context, reason: '上传到 B 站需要登录 B 站账号');
    return;
  }
  ToastUtil.show('正在上传“${collection.name}”到 B 站…');
  try {
    final FavoriteCollection? uploaded = await ref
        .read(favoritesControllerProvider.notifier)
        .uploadLocalCollectionToRemote(collection.id);
    if (context.mounted) {
      ToastUtil.show(uploaded == null ? '上传失败，请稍后重试' : '已上传到 B 站，之后增删会双向同步');
    }
  } on Object catch (error) {
    if (context.mounted) {
      ToastUtil.show('上传失败：$error');
    }
  }
}

Future<void> _showRenameCollectionDialog({
  required BuildContext context,
  required WidgetRef ref,
  required FavoriteCollection collection,
}) async {
  final String? result = await showDialog<String>(
    context: context,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return CollectionNameDialog(
        title: '重命名歌单',
        hintText: '请输入歌单名称',
        confirmText: '保存',
        initialValue: collection.name,
      );
    },
  );
  if (result == null || !context.mounted) {
    return;
  }

  final String trimmedName = result.trim();
  if (trimmedName.isEmpty) {
    ToastUtil.show('歌单名称不能为空');
    return;
  }
  if (trimmedName == collection.name.trim()) {
    return;
  }

  final bool renamed = await ref
      .read(favoritesControllerProvider.notifier)
      .renameCollection(collectionId: collection.id, name: trimmedName);
  if (context.mounted) {
    ToastUtil.show(renamed ? '已重命名歌单' : '歌单名称已存在');
  }
}

Future<void> _showDeleteCollectionDialog({
  required BuildContext context,
  required WidgetRef ref,
  required FavoriteCollection collection,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('删除歌单'),
        content: Text(
          collection.isRemote
              ? '确认删除“${collection.name}”？这会同时删除 B 站收藏夹，无法恢复。'
              : '确认删除“${collection.name}”？删除后无法恢复。',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      );
    },
  );
  if (confirmed != true) {
    return;
  }

  final bool deleted = await ref
      .read(favoritesControllerProvider.notifier)
      .deleteCollection(collection.id);
  if (context.mounted) {
    ToastUtil.show(deleted ? '已删除歌单' : '删除失败');
  }
}

Future<void> _showRemoveRemoteCollectionDialog({
  required BuildContext context,
  required WidgetRef ref,
  required FavoriteCollection collection,
}) async {
  if (!collection.isRemote) {
    return;
  }
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('解除绑定'),
        content: Text('确认解除“${collection.name}”与 App 的绑定？只会从列表移除，不会删除 B 站收藏夹。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('解除绑定'),
          ),
        ],
      );
    },
  );
  if (confirmed != true) {
    return;
  }

  final bool removed = await ref
      .read(favoritesControllerProvider.notifier)
      .removeRemoteCollection(collection.id);
  if (context.mounted) {
    ToastUtil.show(removed ? '已解除绑定' : '解除绑定失败');
  }
}

PopupMenuItem<CollectionAction> _menuItem(
  CollectionAction action,
  IconData icon,
  String label, {
  bool danger = false,
}) {
  return PopupMenuItem<CollectionAction>(
    value: action,
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: _MenuRow(icon: icon, label: label, danger: danger),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color foreground = danger ? colorScheme.error : colorScheme.primary;
    return Row(
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: foreground.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Icon(icon, size: 17, color: foreground),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: danger ? colorScheme.error : colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
