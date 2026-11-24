import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:flutter/material.dart';

class CollectionNameDialog extends StatefulWidget {
  const CollectionNameDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.confirmText,
    this.initialValue = '',
    this.glass = false,
  });

  final String title;
  final String hintText;
  final String confirmText;
  final String initialValue;

  /// 玻璃开关打开时用白雾玻璃对话框。
  final bool glass;

  @override
  State<CollectionNameDialog> createState() => _CollectionNameDialogState();
}

class _CollectionNameDialogState extends State<CollectionNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildField(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _controller,
      maxLength: 24,
      autofocus: true,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: widget.glass,
        fillColor: widget.glass
            ? colorScheme.surface.withValues(alpha: 0.55)
            : null,
        border: widget.glass
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.24),
                ),
              )
            : null,
      ),
      onSubmitted: (String value) {
        Navigator.of(context).pop(value);
      },
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('取消'),
      ),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(_controller.text),
        child: Text(widget.confirmText),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.glass) {
      return AlertDialog(
        title: Text(widget.title),
        content: _buildField(context),
        actions: _buildActions(context),
      );
    }
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return AppGlassDialogShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 14),
            _buildField(context),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActions(context),
            ),
          ],
        ),
      ),
    );
  }
}
