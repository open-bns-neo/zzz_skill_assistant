// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_combo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaitForKeyAction _$WaitForKeyActionFromJson(Map<String, dynamic> json) =>
    WaitForKeyAction(
      KeyEvent.fromJson(json['event'] as Map<String, dynamic>),
      timeout: (json['timeout'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WaitForKeyActionToJson(WaitForKeyAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'event': instance.event,
      'timeout': instance.timeout,
    };

const _$ActionTypeEnumMap = {
  ActionType.waitForKey: 'waitForKey',
  ActionType.waitForClick: 'waitForClick',
  ActionType.waitForDoubleClick: 'waitForDoubleClick',
  ActionType.pressKey: 'pressKey',
  ActionType.wait: 'wait',
  ActionType.screenColorPicker: 'screenColorPicker',
  ActionType.waitComposeKey: 'waitComposeKey',
  ActionType.colorTest: 'colorTest',
};

WaitForClickAction _$WaitForClickActionFromJson(Map<String, dynamic> json) =>
    WaitForClickAction(
      KeyEvent.fromJson(json['event'] as Map<String, dynamic>),
      timeout: (json['timeout'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WaitForClickActionToJson(WaitForClickAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'event': instance.event,
      'timeout': instance.timeout,
    };

WaitForDoubleClickAction _$WaitForDoubleClickActionFromJson(
        Map<String, dynamic> json) =>
    WaitForDoubleClickAction(
      KeyEvent.fromJson(json['event'] as Map<String, dynamic>),
      timeout: (json['timeout'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WaitForDoubleClickActionToJson(
        WaitForDoubleClickAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'event': instance.event,
      'timeout': instance.timeout,
    };

PressKeyAction _$PressKeyActionFromJson(Map<String, dynamic> json) =>
    PressKeyAction(
      KeyEvent.fromJson(json['event'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PressKeyActionToJson(PressKeyAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'event': instance.event,
    };

WaitAction _$WaitActionFromJson(Map<String, dynamic> json) => WaitAction(
      (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$WaitActionToJson(WaitAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'duration': instance.duration,
    };

ScreenColorPickerAction _$ScreenColorPickerActionFromJson(
        Map<String, dynamic> json) =>
    ScreenColorPickerAction()
      ..color = json['color'] == null
          ? null
          : Pixel.fromJson(json['color'] as Map<String, dynamic>);

Map<String, dynamic> _$ScreenColorPickerActionToJson(
        ScreenColorPickerAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'color': instance.color,
    };

WaitComposeKeyAction _$WaitComposeKeyActionFromJson(
        Map<String, dynamic> json) =>
    WaitComposeKeyAction(
      (json['events'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    );

Map<String, dynamic> _$WaitComposeKeyActionToJson(
        WaitComposeKeyAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'events': instance.events,
    };

ColorTestAction _$ColorTestActionFromJson(Map<String, dynamic> json) =>
    ColorTestAction(
      Pixel.fromJson(json['pixel'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ColorTestActionToJson(ColorTestAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'pixel': instance.pixel,
    };
