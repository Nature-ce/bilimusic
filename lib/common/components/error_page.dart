import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageAppBar(),
      body: StatusView(
        icon: Icons.error_outline_rounded,
        title: message ?? '页面不存在',
      ),
    );
  }
}
