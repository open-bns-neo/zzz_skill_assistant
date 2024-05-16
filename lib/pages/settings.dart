import 'package:bns_skill_assistant/controller/setting_controller.dart';
import 'package:bns_skill_assistant/widgets/util/notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends GetView<SettingController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('设置'),
      ),
      body: Obx(
        () => ListView(
          children: [
            ListTile(
              title: const Text('仅在剑灵中生效'),
              trailing: Switch(
                value: controller.onlyActiveOnSpecificPrograms.value,
                onChanged: (bool value) {
                  controller.setOnlyActiveOnSpecificPrograms(value);
                  notify.info('已更改，需要重新激活才能生效。', context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}