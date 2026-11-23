import 'package:flutter/material.dart';

class CollectionNameDialog extends StatefulWidget {
  const CollectionNameDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.confirmText,
    this.initialValue = '',
  });

  final String title;
  final String hintText;
  final String confirmText;
  final String initialValue;

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLength: 24,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hintText),
        onSubmitted: (String value) {
          Navigator.of(context).pop(value);
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
