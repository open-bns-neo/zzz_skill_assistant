import 'package:bns_skill_assistant/controller/color_library_controller.dart';
import 'package:bns_skill_assistant/widgets/slide_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../tools/screen_color_picker.dart';
import '../widgets/delete_widget.dart';
import '../widgets/editable_text.dart';
import '../widgets/util/notification.dart';


class ColorLibraryPage extends GetView<ColorLibraryController> {
  const ColorLibraryPage({super.key});

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
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemCount: controller.colors.length,
                    itemBuilder: (context, index) {
                      final color = controller.colors[index];
                      return ColorItem(
                        key: ValueKey(color),
                        data: color,
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

class ColorItem extends StatelessWidget {
  final ColorData data;

  const ColorItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return _buildColorItem(context);
  }

  Widget _buildColorItem(BuildContext context) {
    return Obx(
      () => Container(
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
                data.name.value,
                onChanged: (value) {
                  data.name.value = value;
                },
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            _buildColorBody(),
            const Spacer(),
            _buildEditButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildColorBody() {
    final r = data.pixel.value.color & 0xFF;
    final g = (data.pixel.value.color >> 8) & 0xFF;
    final b = (data.pixel.value.color >> 16) & 0xFF;

    return data.isEditing.value ? const Row(
      children: [
        Icon(Icons.color_lens),
        Text("取色中..."),
      ],
    ) : Row(
      children: [
        Text("取色 x: ${data.pixel.value.x} y: ${data.pixel.value.y}"),
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
    return data.isEditing.value ?
    IconButton(
      icon: const Icon(Icons.save),
      onPressed: () {
        data.isEditing.value = false;
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
            data.isEditing.value = true;
            _edit(context);
          },
        ),
        DeleteWidget(
          size: 15,
          onDelete: () {
            Get.find<ColorLibraryController>().removeData(data);
          },
        ),
      ],
    );
  }

  void _onColorPicked() {
    final color = ScreenColorPicker.pickColorNotifier.value;
    if (color != null) {
      data.pixel.value = color;
      _save();
    }
  }

  void _edit(BuildContext context) {
    ScreenColorPicker.pickColorNotifier.addListener(_onColorPicked);
    notify.info('按下 CTRL + P 进行取色', context);
  }

  void _save() {
    data.isEditing.value = false;
  }

}
