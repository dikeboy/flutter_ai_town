import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
class BaseScreen extends PositionComponent{
  BaseScreen(width, height) : super(size: Vector2(width, height));

  void onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  }
}