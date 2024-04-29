import 'package:flutter/cupertino.dart';
import 'package:win32/win32.dart';

import '../../services/key_event.dart';

class KeyImageLoader {
  static const _keyMap = <int, String>{
    mouseLButton : "left-click",
    mouseRButton : "right-click",
    mouseXButton : "mouse-side",
    VIRTUAL_KEY.VK_0 : "0-key",
    VIRTUAL_KEY.VK_1 : "1-key",
    VIRTUAL_KEY.VK_2 : "2-key",
    VIRTUAL_KEY.VK_3 : "3-key",
    VIRTUAL_KEY.VK_4 : "4-key",
    VIRTUAL_KEY.VK_5 : "5-key",
    VIRTUAL_KEY.VK_6 : "6-key",
    VIRTUAL_KEY.VK_7 : "7-key",
    VIRTUAL_KEY.VK_8 : "8-key",
    VIRTUAL_KEY.VK_9 : "9-key",
    VIRTUAL_KEY.VK_A : "a-key",
    VIRTUAL_KEY.VK_B : "b-key",
    VIRTUAL_KEY.VK_C : "c-key",
    VIRTUAL_KEY.VK_D : "d-key",
    VIRTUAL_KEY.VK_E : "e-key",
    VIRTUAL_KEY.VK_F : "f-key",
    VIRTUAL_KEY.VK_G : "g-key",
    VIRTUAL_KEY.VK_H : "h-key",
    VIRTUAL_KEY.VK_I : "i-key",
    VIRTUAL_KEY.VK_J : "j-key",
    VIRTUAL_KEY.VK_K : "k-key",
    VIRTUAL_KEY.VK_L : "l-key",
    VIRTUAL_KEY.VK_M : "m-key",
    VIRTUAL_KEY.VK_N : "n-key",
    VIRTUAL_KEY.VK_O : "o-key",
    VIRTUAL_KEY.VK_P : "p-key",
    VIRTUAL_KEY.VK_Q : "q-key",
    VIRTUAL_KEY.VK_R : "r-key",
    VIRTUAL_KEY.VK_S : "s-key",
    VIRTUAL_KEY.VK_T : "t-key",
    VIRTUAL_KEY.VK_U : "u-key",
    VIRTUAL_KEY.VK_V : "v-key",
    VIRTUAL_KEY.VK_W : "w-key",
    VIRTUAL_KEY.VK_X : "x-key",
    VIRTUAL_KEY.VK_Y : "y-key",
    VIRTUAL_KEY.VK_Z : "z-key",
    VIRTUAL_KEY.VK_LCONTROL : "ctrl",
  };

  static AssetImage load(int keyCode) {
    var key = _keyMap[keyCode];
    key ??= "ecology";
    return AssetImage('assets/images/keys/icons8-$key-100.png');
  }
}