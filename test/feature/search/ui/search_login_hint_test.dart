import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/search/ui/components/search_login_hint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSession extends BiliSessionController {
  _FakeSession(this._session);

  final BiliSession? _session;

  @override
  BiliSession? build() => _session;
}

const BiliSession _loggedIn = BiliSession(
  sessData: 'sess',
  biliJct: 'jct',
  dedeUserId: '123',
  refreshToken: '',
  cookie: 'SESSDATA=sess; bili_jct=jct; DedeUserID=123',
);

Future<void> _pump(WidgetTester tester, BiliSession? session) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        biliSessionControllerProvider.overrideWith(() => _FakeSession(session)),
      ],
      child: const MaterialApp(home: Scaffold(body: SearchLoginHint())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('游客搜索页显示登录提示', (WidgetTester tester) async {
    await _pump(tester, null);

    expect(find.textContaining('游客更容易被限流'), findsOneWidget);
    expect(find.byKey(const Key('searchLoginHintAction')), findsOneWidget);
  });

  testWidgets('已登录时不显示提示', (WidgetTester tester) async {
    await _pump(tester, _loggedIn);

    expect(find.textContaining('游客更容易被限流'), findsNothing);
    expect(find.byKey(const Key('searchLoginHintAction')), findsNothing);
  });
}
