import 'package:bns_skill_assistant/controller/color_library_controller.dart';
import 'package:bns_skill_assistant/widgets/slide_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../tools/screen_color_picker.dart';
import '../widgets/delete_widget.dart';
import '../widgets/editable_text.dart';
import '../widgets/hover_animated_container.dart';
import '../widgets/slide_route.dart';
import '../widgets/util/notification.dart';

class ColorLibraryPage extends GetView<ColorLibraryController> {
  final Function(ColorData?)? onSelect;

  const ColorLibraryPage({super.key, this.onSelect});

  static void show(BuildContext context, {Function(ColorData?)? onSelect}) {
    showSlideRouteDialog(
      context: context,
      slideTransitionFrom: SlideTransitionFrom.right,
      builder: (context, padding) {
        return ColorLibraryPage(onSelect: onSelect,);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideDialog(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('取色库'),
        ),
        body: Obx(
          () => Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                       crossAxisCount: 2,
                       mainAxisSpacing: 10,
                       crossAxisSpacing: 10,
                       childAspectRatio: 4,
                    ),
                    itemCount: controller.colors.length,
                    itemBuilder: (context, index) {
                      final color = controller.colors[index];
                      return ColorItem(
                        key: ValueKey(color),
                        data: color,
                        onSelect: onSelect,
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.colors.add(ColorData(Pixel(0, 0, 0), '新颜色'));
                  },
                  child: const Text('新增颜色'),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ColorItem extends StatefulWidget {
  final Function(ColorData?)? onSelect;
  final ColorData data;

  const ColorItem({super.key, required this.data, this.onSelect});

  @override
  State<StatefulWidget> createState() => _ColorItemState();

}

class _ColorItemState extends State<ColorItem> {
  @override
  Widget build(BuildContext context) {
    return _buildColorItem(context);
  }

  @override
  void dispose() {
    super.dispose();
    Get.find<ColorLibraryController>().save();
  }

  Widget _buildColorItem(BuildContext context) {
    return Obx(
          () {
        Widget child = Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).primaryColorLight,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 150,
                child: EditableTextWidget(
                  canEdit: widget.onSelect == null,
                  widget.data.name.value,
                  onChanged: (value) {
                    widget.data.name.value = value;
                  },
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              _buildColorBody(),
              const Spacer(),
              if (widget.onSelect == null)
                _buildEditButton(context),
            ],
          ),
        );

        if (widget.onSelect != null) {
          child = HoverAnimatedContainer(
            child: GestureDetector(
              child: child,
              onTap: () {
                widget.onSelect?.call(widget.data);
                Navigator.of(context).pop();
              },
            ),
          );
        }
        return child;
      },
    );
  }

  Widget _buildColorBody() {
    final r = widget.data.pixel.value.color & 0xFF;
    final g = (widget.data.pixel.value.color >> 8) & 0xFF;
    final b = (widget.data.pixel.value.color >> 16) & 0xFF;

    return widget.data.isEditing.value ? const Row(
      children: [
        Icon(Icons.color_lens),
        Text("取色中..."),
      ],
    ) : Row(
      children: [
        Text("取色 x: ${widget.data.pixel.value.x} y: ${widget.data.pixel.value.y}"),
        const SizedBox(width: 5,),
        Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(r, g, b, 1),
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          width: 18,
          height: 18,
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return widget.data.isEditing.value ?
    IconButton(
      icon: const Icon(Icons.save),
      onPressed: () {
        widget.data.isEditing.value = false;
        _save();
      },
      tooltip: "保存",
    ) :
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.edit,
            size: 15,
          ),
          tooltip: "编辑",
          onPressed: () {
            widget.data.isEditing.value = true;
            _edit(context);
          },
        ),
        DeleteWidget(
          size: 15,
          onDelete: () {
            Get.find<ColorLibraryController>().removeData(widget.data);
          },
        ),
      ],
    );
  }

  void _onColorPicked() {
    final color = ScreenColorPicker.pickColorNotifier.value;
    if (color != null) {
      widget.data.pixel.value = color;
      _save();
    }
  }

  void _edit(BuildContext context) {
    ScreenColorPicker.pickColorNotifier.addListener(_onColorPicked);
    notify.info('按下 CTRL + P 进行取色', context);
  }

  void _save() {
    widget.data.isEditing.value = false;
    ScreenColorPicker.pickColorNotifier.removeListener(_onColorPicked);
  }
}
