import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/common/domain/paged_state.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_state.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/comment/logic/comment_controller.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/comment/ui/comment_page.dart';
import 'package:bilimusic/feature/comment/ui/components/comment_card.dart';
import 'package:bilimusic/feature/player/ui/components/player_dynamic_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

const CommentTarget _target = CommentTarget(
  oid: 1,
  type: 1,
  bvid: 'BV1test',
  title: '测试视频',
  coverUrl: '',
);

class _FakePlayerController extends PlayerController {
  @override
  PlayerState build() => const PlayerState();
}

class _EmptyCommentController extends CommentController {
  @override
  CommentState build(CommentTarget target) => CommentState(target: target);

  @override
  Future<void> loadInitial() async {}

  @override
  Future<void> loadNextPage() async {}

  @override
  Future<void> refresh() async {}
}

CommentItem _comment() {
  return CommentItem(
    rpid: 1,
    oid: _target.oid,
    type: _target.type,
    root: 0,
    parent: 0,
    replyCount: 0,
    likeCount: 3,
    action: 0,
    publishedAt: DateTime(2026),
    message: '第一条评论',
    memberName: '观众',
    memberAvatarUrl: '',
  );
}

CommentItem _pinnedComment() {
  return CommentItem(
    rpid: 99,
    oid: _target.oid,
    type: _target.type,
    root: 0,
    parent: 0,
    replyCount: 0,
    likeCount: 12,
    action: 0,
    publishedAt: DateTime(2026, 1, 2),
    message: 'Pinned lyric info',
    memberName: 'Pinned author',
    memberAvatarUrl: '',
    isTop: true,
  );
}

class _PinnedCommentController extends _EmptyCommentController {
  @override
  CommentState build(CommentTarget target) => CommentState(
    target: target,
    mainComments: PagedState<CommentItem>(items: <CommentItem>[_comment()]),
    topItem: _pinnedComment(),
  );
}

class _OneCommentController extends _EmptyCommentController {
  @override
  CommentState build(CommentTarget target) => CommentState(
    target: target,
    mainComments: PagedState<CommentItem>(items: <CommentItem>[_comment()]),
  );
}

Future<void> _pumpCommentPage(
  WidgetTester tester, {
  bool withComment = false,
  CommentTarget target = _target,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
        commentControllerProvider(target).overrideWith(
          withComment ? _OneCommentController.new : _EmptyCommentController.new,
        ),
      ],
      child: MaterialApp(home: CommentPage(target: target)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pinned comment sits at the top of all comments', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerControllerProvider.overrideWith(_FakePlayerController.new),
          commentControllerProvider(
            _target,
          ).overrideWith(_PinnedCommentController.new),
        ],
        child: MaterialApp(home: CommentPage(target: _target)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pinned lyric info'), findsOneWidget);
    expect(find.byType(CommentCard), findsNWidgets(2));
    // 置顶角标出现，且不再有独立的置顶评论分段标题（只有「全部评论」一个标题）。
    expect(find.text('置顶'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('评论页顶部标题会把装饰字体还原成普通字符', (WidgetTester tester) async {
    const CommentTarget stylized = CommentTarget(
      oid: 2,
      type: 1,
      bvid: 'BV1test',
      title: '𝐇𝐢-𝐑𝐞𝐬无损音质 | 《背对背》',
      coverUrl: '',
    );

    await _pumpCommentPage(tester, target: stylized);

    expect(find.text('Hi-Res无损音质 | 《背对背》'), findsOneWidget);
    expect(find.textContaining('𝐇𝐢'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('评论页改成深色玻璃风：深色主题 + 模糊封面背景', (WidgetTester tester) async {
    await _pumpCommentPage(tester);

    expect(find.byType(PlayerDynamicBackdrop), findsOneWidget);
    final ThemeData theme = Theme.of(tester.element(find.text('全部评论')));
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, Colors.transparent);
  });

  testWidgets('空态与评论卡片是烟熏玻璃面板', (WidgetTester tester) async {
    await _pumpCommentPage(tester);

    expect(find.text('还没有评论'), findsOneWidget);
    final Finder panel = find.byType(GlassPanel);
    expect(panel, findsWidgets);
    for (final GlassPanel glass in tester.widgetList<GlassPanel>(panel)) {
      expect(glass.tone, GlassTone.smoke);
    }
    final GlassContainer container = tester.widget<GlassContainer>(
      find.byType(GlassContainer).first,
    );
    expect(container.settings?.glassColor, GlassTone.smoke.settings.glassColor);
    expect(tester.takeException(), isNull);
  });

  testWidgets('评论页文字是白色系', (WidgetTester tester) async {
    await _pumpCommentPage(tester);

    final Text empty = tester.widget<Text>(find.text('还没有评论'));
    expect(empty.style?.color, GlassTone.smoke.primaryText);

    final Text title = tester.widget<Text>(find.text('全部评论'));
    expect(title.style?.color?.computeLuminance(), greaterThan(0.5));
  });

  testWidgets('每条评论外面也是一块烟熏玻璃面板', (WidgetTester tester) async {
    await _pumpCommentPage(tester, withComment: true);

    expect(find.text('第一条评论'), findsOneWidget);
    final Finder panel = find.ancestor(
      of: find.text('第一条评论'),
      matching: find.byType(GlassPanel),
    );
    expect(panel, findsOneWidget);
    expect(tester.widget<GlassPanel>(panel).tone, GlassTone.smoke);
    expect(
      tester.widget<Text>(find.text('第一条评论')).style?.color?.computeLuminance(),
      greaterThan(0.5),
    );
  });
  testWidgets('排序按钮点一下就在最新和最热之间切换', (WidgetTester tester) async {
    await _pumpCommentPage(tester, withComment: true);

    expect(find.text('最新'), findsOneWidget);
    expect(find.byType(GlassPanel), findsWidgets);

    await tester.tap(find.byKey(const Key('commentSortToggle')));
    await tester.pumpAndSettle();

    // 只有两种排序：点一下就换成另一种，不再弹菜单。
    expect(find.text('最热'), findsOneWidget);
    expect(find.text('最新'), findsNothing);

    await tester.tap(find.byKey(const Key('commentSortToggle')));
    await tester.pumpAndSettle();

    expect(find.text('最新'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
