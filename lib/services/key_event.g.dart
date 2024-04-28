// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyEvent _$KeyEventFromJson(Map<String, dynamic> json) => KeyEvent(
      keyCode: (json['keyCode'] as num?)?.toInt() ?? 0,
      type: $enumDecodeNullable(_$EventTypeEnumMap, json['type']) ??
          EventType.keyDown,
    );

Map<String, dynamic> _$KeyEventToJson(KeyEvent instance) => <String, dynamic>{
      'keyCode': instance.keyCode,
      'type': _$EventTypeEnumMap[instance.type]!,
    };

const _$EventTypeEnumMap = {
  EventType.keyDown: 'keyDown',
  EventType.keyUp: 'keyUp',
};
