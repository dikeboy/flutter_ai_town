import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/src/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mini_game/game/game/pop_main.dart';

import 'actor/action_util.dart';
import 'actor/actor_all.dart';
import 'actor/actor_animation.dart';
import 'base/screen_base.dart';
import 'game_constants.dart';
import 'image_texture.dart';

class ScreenPlay extends BaseScreen {
  @override
  double width;
  @override
  double height;
  Paint paint = BasicPalette.white.paint();
  ScoreActor? scoreActor;

  ScreenPlay(this.width, this.height) : super(width, height);
  List<StarActor> child = [];

  @override
  Future<void> onLoad() async {
    var random = Random();
    print("cellY = ${size.y}");
    var normalBean = ImageTexture.getImageBean("star_purple");
    var cellWidth = normalBean.width;
    var cellHeight = normalBean.height;
    var xNum = (size.x - 30) ~/ cellWidth;
    var yNum = (size.y - 300) ~/ cellHeight;
    var xPadding = (size.x - xNum * cellWidth.toDouble()) / 2;
    GameConstants.CELL_WIDTH = cellWidth;
    GameConstants.CELL_X_NUM = xNum;
    GameConstants.CELL_Y_NUM = yNum;
    GameConstants.SIZE_W = xNum;
    GameConstants.SIZE_H = yNum;

    for (int j = 0; j < yNum; j++) {
      for (int i = 0; i < xNum; i++) {
        var starActor = StarActor(
          random.nextInt(5) + 1,
          cellWidth.toDouble(),
          cellHeight.toDouble(),
          () {},
        );
        starActor.position = Vector2(
          (cellWidth * i).toDouble() + xPadding,
          size.y - cellHeight * j - cellHeight - 5,
        );
        child.add(starActor);
        await add(starActor);
      }
    }

    for (int i = 0; i < GameConstants.SIZE_W; i++) {
      for (int j = 0; j < GameConstants.SIZE_H; j++) {
        int pos = j * GameConstants.SIZE_W + i;
        child[pos].newX = child[pos].position.x;
        child[pos].newY = child[pos].position.y;
        child[pos].position.y =
            child[pos].position.y - GameConstants.SCREEN_HEIGHT;
        child[pos].hasAnim = true;
        child[pos].translateAnimation = TranslateAnimation(child[pos])
          ..setDuration(1000)
          ..delayAnim(j * 50 + i % 2 * 50)
          ..setOnFinish(() {
            scoreActor?.isVisible = true;
          })
          ..translateTo(child[pos].newX, child[pos].newY)
          ..startAnimation();
        child[pos].hasAnim = false;
      }
    }

    ImageBean scoreBg = ImageTexture.getImageBean("back2");
    scoreActor = ScoreActor(
      scoreBg.width.toDouble(),
      scoreBg.height.toDouble(),
      () {},
    );
    scoreActor!.x = (size.x - scoreBg.width.toDouble()) / 2.toDouble();
    scoreActor!.y = 100;
    await add(scoreActor!);
  }

  Future<void> changeItemSelect() async {
    var winBean = ImageTexture.getImageBean("win");
    var winActor = TextureImageActor(ImageTexture.baseImage, winBean, () {});
    winActor.x =
        (GameConstants.SCREEN_WIDTH - winBean.width.toDouble()) / 2.toDouble();
    winActor.y = 200;
    add(winActor);

    var exitGame = ImageTexture.getImageBean("exit");
    var exitActor = TextureImageActor(ImageTexture.baseImage, exitGame, () {
      (parent as MyGame).finishGame();
    });
    exitActor.x =
        (GameConstants.SCREEN_WIDTH - exitGame.width.toDouble()) / 2.toDouble();
    exitActor.y = 300;
    await add(exitActor);
  }

  void checkIsWin() {
    if (ActionUtils.checkIsWin(child)) {
      changeItemSelect();
      for (int i = 0; i < child.length; i++) {
        if (child[i].isVisible) {
          child[i].isVisible = false;
          ActionUtils.createStarPraticle(child[i].state, child[i]);
        }
      }
    }
  }

  void onScoreAdd(int score) {
    scoreActor?.valueAnimation = ValueAnimation()
      ..setDuration(300)
      ..translateTo(GameConstants.TOTLE_SCOLE, score)
      ..setValueChange((value) {
        scoreActor?.changeText("$value");
      })
      ..startAnimation();
    GameConstants.TOTLE_SCOLE = score;
  }
}
