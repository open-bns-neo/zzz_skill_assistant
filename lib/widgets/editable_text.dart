import 'package:flutter/material.dart';

class EditableTextWidget extends StatefulWidget {
  final Function(String)? onChanged;
  final String text;
  final bool canEdit;
  final TextInputType? keyboardType;
  const EditableTextWidget(this.text, {super.key, this.onChanged, this.canEdit = true, this.keyboardType});

  @override
  State createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isEditing = false;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;
    if (_displayText.isEmpty) {
      _isEditing = true;
    }
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _isEditing = false;
          _displayText = _textEditingController.text;
          if (_displayText.isEmpty) {
            _displayText = '未命名';
          }
          widget.onChanged?.call(_displayText);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        if (!widget.canEdit) {
          return;
        }

        setState(() {
          _isEditing = true;
          _textEditingController.text = _displayText; // 显示之前的文本
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: _isEditing
            ? TextFormField(
          focusNode: _focusNode,
          controller: _textEditingController,
          autofocus: true,
          keyboardType: widget.keyboardType,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
          ),
          onFieldSubmitted: (value) {
            setState(() {
              _displayText = value;
              _isEditing = false;
            });
          },
        )
            : Text(
          _displayText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}