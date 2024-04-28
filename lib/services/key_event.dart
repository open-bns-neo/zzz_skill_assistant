import 'package:json_annotation/json_annotation.dart';
import 'package:win32/win32.dart';

part 'key_event.g.dart';

enum EventType { keyDown, keyUp }

const mouseLButton = 1000;
const mouseRButton = 1001;
const mouseXButton = 1003;

@JsonSerializable()
class KeyEvent {
  static final _keyCodeNameMap = <int, String>{
    mouseXButton : "MouseX",
    mouseLButton : "MouseLeft",
    mouseRButton : "MouseRight",
    VIRTUAL_KEY.VK_0 : "0",
    VIRTUAL_KEY.VK_1 : "1",
    VIRTUAL_KEY.VK_2 : "2",
    VIRTUAL_KEY.VK_3 : "3",
    VIRTUAL_KEY.VK_4 : "4",
    VIRTUAL_KEY.VK_5 : "5",
    VIRTUAL_KEY.VK_6 : "6",
    VIRTUAL_KEY.VK_7 : "7",
    VIRTUAL_KEY.VK_8 : "8",
    VIRTUAL_KEY.VK_9 : "9",
    VIRTUAL_KEY.VK_A : "A",
    VIRTUAL_KEY.VK_B : "B",
    VIRTUAL_KEY.VK_C : "C",
    VIRTUAL_KEY.VK_D : "D",
    VIRTUAL_KEY.VK_E : "E",
    VIRTUAL_KEY.VK_F : "F",
    VIRTUAL_KEY.VK_G : "G",
    VIRTUAL_KEY.VK_H : "H",
    VIRTUAL_KEY.VK_I : "I",
    VIRTUAL_KEY.VK_J : "J",
    VIRTUAL_KEY.VK_K : "K",
    VIRTUAL_KEY.VK_L : "L",
    VIRTUAL_KEY.VK_M : "M",
    VIRTUAL_KEY.VK_N : "N",
    VIRTUAL_KEY.VK_O : "O",
    VIRTUAL_KEY.VK_P : "P",
    VIRTUAL_KEY.VK_Q : "Q",
    VIRTUAL_KEY.VK_R : "R",
    VIRTUAL_KEY.VK_S : "S",
    VIRTUAL_KEY.VK_T : "T",
    VIRTUAL_KEY.VK_U : "U",
    VIRTUAL_KEY.VK_V : "V",
    VIRTUAL_KEY.VK_W : "W",
    VIRTUAL_KEY.VK_X : "X",
    VIRTUAL_KEY.VK_Y : "Y",
    VIRTUAL_KEY.VK_Z : "Z",
    VIRTUAL_KEY.VK_LCONTROL : "LCtrl",
  };

  int keyCode = 0;
  EventType type = EventType.keyDown;

  KeyEvent({this.keyCode = 0, this.type = EventType.keyDown});

  @override
  bool operator == (Object other) {
    return other is KeyEvent && keyCode == other.keyCode && type == other.type;
  }

  @override
  String toString() {
    return 'KeyEvent{code: $keyCode, keyName: ${_keyCodeNameMap[keyCode] ?? 'unknown'}, type: $type}';
  }

  @override
  int get hashCode => keyCode.hashCode ^ type.hashCode;

  factory KeyEvent.fromJson(Map<String, dynamic> json) => _$KeyEventFromJson(json);

  Map<String, dynamic> toJson() => _$KeyEventToJson(this);
}