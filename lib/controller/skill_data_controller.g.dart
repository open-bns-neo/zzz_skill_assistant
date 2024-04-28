// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_data_controller.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabPageController _$TabPageControllerFromJson(Map<String, dynamic> json) =>
    TabPageController(
      json['title'] as String,
      skills: (json['skills'] as List<dynamic>)
          .map((e) => SkillComboController.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TabPageControllerToJson(TabPageController instance) =>
    <String, dynamic>{
      'title': instance.title,
      'skills': instance.skills,
    };

SkillComboController _$SkillComboControllerFromJson(
        Map<String, dynamic> json) =>
    SkillComboController(
      name: json['name'] as String? ?? '未命名',
      actions: (json['actions'] as List<dynamic>?)
          ?.map((e) => SkillAction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SkillComboControllerToJson(
        SkillComboController instance) =>
    <String, dynamic>{
      'name': instance.name,
      'actions': instance.actions,
    };

SkillDataController _$SkillDataControllerFromJson(Map<String, dynamic> json) =>
    SkillDataController(
      tabs: (json['tabs'] as List<dynamic>?)
          ?.map((e) => TabPageController.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SkillDataControllerToJson(
        SkillDataController instance) =>
    <String, dynamic>{
      'tabs': instance.tabs,
    };
