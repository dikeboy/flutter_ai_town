import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/animation.dart';

import '../game_constants.dart';
import '../image_texture.dart';
import '../pop_screen_play.dart';
import 'actor_all.dart';
import 'actor_animation.dart';

class ActionUtils {
  static List<int> isTest = [];
  static List<StarActor> selStars = [];
  static int EVERY_SIZE = 48;

  static void calculate(
    List<StarActor> arrays,
    StarActor mCurrentActor,
    bool isSelect,
  ) {
    selStars.clear();
    selStars.add(mCurrentActor);
    int l = arrays.length;
    isTest = List<int>.filled(l, 0);
    int mCurrentNum = 0;
    for (int i = 0; i < l; i++) {
      if (mCurrentActor == arrays[i]) {
        mCurrentNum = i;
        break;
      }
    }
    isTest[mCurrentNum] = 1;
    calEdge(arrays, mCurrentNum, l, isSelect);
  }

  static void calEdge(List<StarActor> arrays, int m, int l, bool isSelect) {
    int top = m - GameConstants.SIZE_W;
    int left = m - 1;
    int right = m + 1;
    int bottom = m + GameConstants.SIZE_W;
    int state = arrays[m].state;
    if (top >= 0) {
      if (arrays[top].isVisible &&
          arrays[top].state == state &&
          isTest[top] == 0) {
        isTest[top] = 1;
        arrays[top].select = isSelect;
        selStars.add(arrays[top]);
        calEdge(arrays, top, l, isSelect);
      }
    }
    if (left >= 0 &&
        left % GameConstants.SIZE_W != (GameConstants.SIZE_W - 1)) {
      if (arrays[left].isVisible &&
          arrays[left].state == state &&
          isTest[left] == 0) {
        isTest[left] = 1;
        arrays[left].select = isSelect;
        selStars.add(arrays[left]);
        calEdge(arrays, left, l, isSelect);
      }
    }
    if (right < GameConstants.SIZE_W * GameConstants.SIZE_H &&
        right % GameConstants.SIZE_W != 0) {
      if (arrays[right].isVisible &&
          arrays[right].state == state &&
          isTest[right] == 0) {
        isTest[right] = 1;
        arrays[right].select = isSelect;
        selStars.add(arrays[right]);
        calEdge(arrays, right, l, isSelect);
      }
    }
    if (bottom < GameConstants.SIZE_W * GameConstants.SIZE_H) {
      if (arrays[bottom].isVisible &&
          arrays[bottom].state == state &&
          isTest[bottom] == 0) {
        isTest[bottom] = 1;
        arrays[bottom].select = isSelect;
        selStars.add(arrays[bottom]);
        calEdge(arrays, bottom, l, isSelect);
      }
    }
  }

  static void changeArrayPosition(List<StarActor> arrays) {
    print("${GameConstants.CELL_X_NUM};${GameConstants.CELL_Y_NUM}");
    for (int i = 0; i < arrays.length; i++) {
      arrays[i].newX = arrays[i].x;
      arrays[i].newY = arrays[i].y;
    }
    for (int i = 0; i < GameConstants.SIZE_W; i++) {
      int empty = 0;
      for (int j = 0; j < GameConstants.SIZE_H; j++) {
        int pos = j * GameConstants.SIZE_W + i;
        if (arrays[pos].isVisible) {
          if (empty > 0) {
            arrays[j * GameConstants.SIZE_W + i].hasAnim = true;
            changePostion(
              arrays,
              j * GameConstants.SIZE_W + i,
              j * GameConstants.SIZE_W + i - empty * GameConstants.SIZE_W,
            );
            changeMovePostion(
              arrays,
              j * GameConstants.SIZE_W + i - empty * GameConstants.SIZE_W,
              j * GameConstants.SIZE_W + i,
            );
          }
        } else {
          empty++;
        }
      }
    }
    int horEmpty = 0;
    for (int i = 0; i < GameConstants.SIZE_W; i++) {
      bool hasEmptyRow = true;
      for (int j = 0; j < GameConstants.SIZE_H; j++) {
        int pos = j * GameConstants.SIZE_W + i;
        if (arrays[pos].isVisible) {
          hasEmptyRow = false;
          if (horEmpty > 0) {
            arrays[j * GameConstants.SIZE_W + i].hasAnim = true;
            changePostion(
              arrays,
              j * GameConstants.SIZE_W + i,
              j * GameConstants.SIZE_W + i - horEmpty,
            );
            changeMovePostion(
              arrays,
              j * GameConstants.SIZE_W + i - horEmpty,
              j * GameConstants.SIZE_W + i,
            );
          }
        }
      }
      if (hasEmptyRow) {
        horEmpty++;
      }
    }
    for (int i = 0; i < arrays.length; i++) {
      if (arrays[i].isVisible && arrays[i].hasAnim) {
        arrays[i].translateAnimation = TranslateAnimation(arrays[i])
          ..setDuration(300)
          ..translateTo(arrays[i].newX, arrays[i].newY)
          ..startAnimation();
        arrays[i].hasAnim = false;
      }
    }
  }

  static void changePostion(List<StarActor> arrays, int i, int j) {
    StarActor temp = arrays[i];
    arrays[i] = arrays[j];
    arrays[j] = temp;
  }

  static void changeMovePostion(List<StarActor> arrays, int i, int j) {
    // print("change pos= i=$i  j=$j  ax=${arrays[i].newX} ay=${arrays[i].newY}  bx=${arrays[j].newX} by=${arrays[j].newY}");
    var px = arrays[i].newX;
    var py = arrays[i].newY;
    arrays[i].newX = arrays[j].newX;
    arrays[i].newY = arrays[j].newY;
    arrays[j].position.x = px;
    arrays[j].position.y = py;
    arrays[j].newX = px;
    arrays[j].newY = py;
  }

  static Future<void> createStarPraticle(int state, StarActor starActor) async {
    Image? image;
    switch (state) {
      case 1:
        {
          image = ImageTexture.purpleImage;
        }
        break;
      case 2:
        {
          image = ImageTexture.blueImage;
        }
        break;
      case 3:
        {
          image = ImageTexture.greenImage;
        }
        break;
      case 4:
        {
          image = ImageTexture.yellowImage;
        }
        break;
      case 5:
        {
          image = ImageTexture.redImage;
        }
        break;
    }
    Particle particle = ActionUtils.createClickPraticle(image!);
    // 创建 ParticleSystemComponent 构件
    final ParticleSystemComponent psc = ParticleSystemComponent(
      particle: particle,
      position: Vector2(starActor.x, starActor.y),
    );
    createClickPraticle(image);
    (starActor.parent as ScreenPlay).add(psc);
  }

  static Particle createClickPraticle(Image image) {
    final List<Vector2> starPos = [
      Vector2(10, 20),
      Vector2(10, 10),
      Vector2(30, 10),
      Vector2(30, 20),
    ];
    final List<Vector2> endPos = [
      Vector2(200, GameConstants.SCREEN_HEIGHT + 20),
      Vector2(-100, GameConstants.SCREEN_HEIGHT + 20),
      Vector2(50, GameConstants.SCREEN_HEIGHT + 20),
      Vector2(50, GameConstants.SCREEN_HEIGHT + 20),
    ];

    Particle particle = Particle.generate(
      count: 4,
      lifespan: 1,
      generator: (i) => PaintParticle(
        bounds: Rect.fromLTRB(
          -GameConstants.SCREEN_WIDTH.toDouble(),
          -GameConstants.SCREEN_HEIGHT.toDouble(),
          GameConstants.SCREEN_WIDTH.toDouble(),
          GameConstants.SCREEN_HEIGHT.toDouble(),
        ),
        paint: Paint()..blendMode = BlendMode.difference,
        child: MovingParticle(
          curve: Curves.easeIn,
          from: starPos[i],
          to: endPos[i],
          child: ImageParticle(size: Vector2.all(20), image: image),
        ),
      ),
    );
    return particle;
  }

  static bool checkIsWin(List<StarActor> arrays) {
    int l = arrays.length;
    for (int i = 0; i < l; i++) {
      if (arrays[i].isVisible) {
        int top = (i / GameConstants.SIZE_W > GameConstants.SIZE_H - 1
            ? -1
            : i + GameConstants.SIZE_W);
        int left = (i % GameConstants.SIZE_W == 0 ? -1 : i - 1);
        int right = (i % GameConstants.SIZE_W == GameConstants.SIZE_W - 1
            ? -1
            : i + 1);
        int bottom = (i < GameConstants.SIZE_W ? -1 : i - GameConstants.SIZE_W);
        if (top >= 0 &&
            top < l &&
            arrays[top].isVisible &&
            arrays[top].state == arrays[i].state)
          return false;
        if (left >= 0 &&
            arrays[left].isVisible &&
            arrays[left].state == arrays[i].state)
          return false;
        if (right >= 0 &&
            right < l &&
            arrays[right].isVisible &&
            arrays[right].state == arrays[i].state)
          return false;
        if (bottom >= 0 &&
            arrays[bottom].isVisible &&
            arrays[bottom].state == arrays[i].state)
          return false;
      }
    }
    return true;
  }
}
