# 技术原理

使用 [Flutter windows](https://flutter.cn/docs/get-started/install/windows/desktop?tab=download) + [win32 dart api](https://pub.dev/packages/win32) 开发。

## 基础原理

首先，我们需要了解一些基础原理：卡刀的本质是监听键盘、鼠标输入，然后触发一系列的动作逻辑，比如模拟鼠标点击、键盘输入等。

所有核心就是如何监听键盘、鼠标输入，以及如何模拟键盘、鼠标输入。

### 1. 输入监听

使用win32 api的`SetWindowsHookEx`函数监听鼠标、键盘输入。

### 2. 输入模拟

使用win32 api的`SendInput`函数模拟鼠标、键盘输入。

### 3. 取色

使用win32 api的`GetPixel`函数获取屏幕上某个点的颜色，用来判断当前某个位置颜色是否匹配（技能是否可用）。

分为两个部分：

- 取色：触发快捷键，会进行全屏截图，要求用户开始取色，然后点击屏幕上的某个点，记录下这个点的颜色。
- 判断：在技能连招过程中，进行取色，然后判断当前技能是否可用。

## 核心概念

### 1. Action

Action是一个抽象类，代表一个动作，比如鼠标点击、键盘输入、等待输入、取色等。每个Action都有一个`execute`方法，用来执行这个动作。

```dart
abstract class Action {
  Future<bool> execute();
}
```

返回值是一个`Future<bool>`，表示这个动作是否执行成功。

目前用户侧支持的Action有：

- `WaitForKeyAction`：等待鼠标点击（可以作为卡刀触发器）
- `PressKeyAction`: 模拟键盘/键盘输入
- `WaitAction`: 等待一段时间，可以作为技能连招之间的间隔
- `ColorTestAction`: 取色，可以判断当前技能是否可用

### 2. SkillCombo

SkillCombo是一个抽象类，代表一个技能连招，由多个Action组成。有`start`和`stop`方法，分别用来开始和停止这个技能连招。

```dart
abstract class SkillCombo {
  void start();
  void stop();
  
  List<Action> get actions;
}
```

连招开始后，会依次执行每个Action的`execute`方法，直到连招停止，或者某个Action执行失败。

### 3. SkillPageController

代表一个技能页面，由多个SkillCombo组成，可以一次性开始、停止所有技能连招。

### 用户交互

有了上面的核心概念，我们可以很容易的实现一个简单的技能连招助手，但是这样还不够，我们还需要用户交互，比如配置技能连招、配置技能页面、配置技能连招的快捷键等。

这里没有使用很复杂的技术原理，都是flutter开发的基本操作，可以看源码 `pages/home.dart`。

当然还有一些细节，比如快捷键实现、缓存、编辑技能连招等，这里就不一一展开了。
