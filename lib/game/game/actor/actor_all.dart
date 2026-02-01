import "dart:ui" as Painting;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';

import '../game_constants.dart';
import '../image_texture.dart';
import '../pop_screen_play.dart';
import 'action_util.dart';
import 'actor_animation.dart';
import 'package:flame/events.dart';
typedef ActorCallBack = void Function();

typedef TimeCallBack = void Function(int hour);

class BaseActor extends PositionComponent with TapCallbacks {
  @override
  double width = 0;
  @override
  double height = 0;
  double newX = 0;
  double newY = 0;
  bool hasAnim = false;
  final ActorCallBack? callBack;
  Paint paint = BasicPalette.white.paint();
  TranslateAnimation? translateAnimation;
  ValueAnimation? valueAnimation;
  bool isVisible = false;

  BaseActor(this.width, this.height, this.callBack)
    : super(size: Vector2(width, height));

  @override
  void update(double dt) {
    super.update(dt);
    translateAnimation?.onAnimation(dt);
    valueAnimation?.onAnimation(dt);
  }
}

class StarActor extends BaseActor {
  int state = 0;
  bool select = false;
  ImageBean? selBean;
  ImageBean? normalBean;
  @override
  var isVisible = true;

  StarActor(this.state, width, height, callBack)
    : super(width, height, callBack);

  @override
  @override
  Future<void> onLoad() async {
    switch (state) {
      case 1:
        {
          selBean = ImageTexture.getImageBean("star_s_purple");
          normalBean = ImageTexture.getImageBean("star_purple");
        }
        break;
      case 2:
        {
          selBean = ImageTexture.getImageBean("star_s_blue");
          normalBean = ImageTexture.getImageBean("star_blue");
        }
        break;
      case 3:
        {
          selBean = ImageTexture.getImageBean("star_s_green");
          normalBean = ImageTexture.getImageBean("star_green");
        }
        break;
      case 4:
        {
          selBean = ImageTexture.getImageBean("star_s_yellow");
          normalBean = ImageTexture.getImageBean("star_yellow");
        }
        break;
      case 5:
        {
          selBean = ImageTexture.getImageBean("star_s_red");
          normalBean = ImageTexture.getImageBean("star_red");
        }
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!isVisible) {
      return;
    }
    var image = select ? normalBean : selBean;
    if (image != null) {
      canvas.drawImageRect(
        ImageTexture.baseImage,
        Rect.fromLTWH(
          image.x.toDouble(),
          image.y.toDouble(),
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        Rect.fromLTWH(0, 0, width, height),
        paint,
      );
    }

    // canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  }

  @override
  void onTapUp(TapUpEvent event) {
    // TODO: implement onTapUp
    if (ActionUtils.selStars.length == 1) {
      ActionUtils.selStars[0].select = false;
      ActionUtils.selStars.clear();
      select = false;
    }
    if (ActionUtils.selStars.contains(this)) {
      for (var element in ActionUtils.selStars) {
        element.isVisible = false;
        ActionUtils.createStarPraticle(state, element);
      }

      ActionUtils.changeArrayPosition((parent as ScreenPlay).child);

      (parent as ScreenPlay).onScoreAdd(
        GameConstants.TOTLE_SCOLE +
            ActionUtils.selStars.length * ActionUtils.selStars.length,
      );
      ActionUtils.selStars.clear();
      (parent as ScreenPlay).checkIsWin();
      // GameUtils.playSound(GameUtils.SOUND_BROKEN);
    } else {
      for (var element in ActionUtils.selStars) {
        element.select = false;
      }
    }
    select = !select;
    ActionUtils.calculate((parent as ScreenPlay).child, this, select);
  }
}

class ScoreActor extends BaseActor {
  String text = "";
  ImageBean? bgBean;
  TextComponent? textComponent;

  ScoreActor(width, height, callback) : super(width, height, callback);

  @override
  Future<void> onLoad() async {
    bgBean = ImageTexture.getImageBean("back2");
    textComponent = TextComponent(text: '${GameConstants.TOTLE_SCOLE}')
      ..anchor = Anchor.topCenter
      ..x = width / 2;
    await add(textComponent!);
  }

  void changeText(String text) {
    textComponent?.text = text;
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) {
      return;
    }
    super.render(canvas);
    if (bgBean != null) {
      canvas.drawImageRect(
        ImageTexture.baseImage,
        Rect.fromLTWH(
          bgBean!.x.toDouble(),
          bgBean!.y.toDouble(),
          bgBean!.width.toDouble(),
          bgBean!.height.toDouble(),
        ),
        Rect.fromLTWH(0, 0, width, height),
        paint,
      );
    }

    // canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  }
}

class TextureImageActor extends BaseActor {
  final Painting.Image spriteImage;
  final ImageBean imageBean;

  TextureImageActor(this.spriteImage, this.imageBean, callBack)
    : super(
        imageBean.destWidth.toDouble(),
        imageBean.destHeight.toDouble(),
        callBack,
      );

  @override
  Future<void> onLoad() async {}

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawImageRect(
      spriteImage,
      Rect.fromLTWH(
        imageBean.x.toDouble(),
        imageBean.y.toDouble(),
        imageBean.width.toDouble(),
        imageBean.height.toDouble(),
      ),
      Rect.fromLTWH(0, 0, width, height),
      paint,
    );
    // canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (callBack != null) {
      callBack!.call();
    }
  }
}
