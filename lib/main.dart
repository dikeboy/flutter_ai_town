import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/game/fview/native_view.dart';
import 'game/game/pop_main.dart';

void main() {
  var myGame = MyGame();
  runApp(
    GameWidget(
      game: myGame,
      // 注册所有可能的弹窗
      overlayBuilderMap: {
        'ChoiceMenu': (context, game) => SelectionDialog(game: myGame),
      },
    ),
  );
}
