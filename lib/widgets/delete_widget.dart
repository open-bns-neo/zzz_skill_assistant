import 'package:flutter/material.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class DeleteWidget extends StatelessWidget {
  final String title;
  final String content;
  final Function? onDelete;
  final Function? onCancel;
  final double? size;
  final bool enable;

  const DeleteWidget({
    super.key,
    this.title = '执行确认',
    this.content = '是否确定执行？',
    this.onDelete,
    this.onCancel,
    this.size,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        size: size,
        Icons.delete_forever,
      ),
      color: Theme.of(context).colorScheme.error,
      onPressed: enable ? () async  {
        if (await confirm(
          context,
          title: Text(title),
          content: Text(content),
          textOK: const Text('确定'),
          textCancel: const Text('取消'),
        )) {
          onDelete?.call();
        }
        onCancel?.call();
      } : null,
    );
  }
}