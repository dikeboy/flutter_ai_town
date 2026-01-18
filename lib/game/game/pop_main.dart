import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_game/game/game/actor/actor_house.dart';
import 'package:mini_game/game/game/base/screen_base.dart';
import 'package:mini_game/game/game/viewmodel/ollama_utils.dart';
import 'package:mini_game/game/game/viewmodel/share_utils.dart';

import 'actor/actor_all.dart';
import 'game_constants.dart';
import 'image_texture.dart';
import 'monit/pop_screen_monit.dart';
import 'pop_screen_play.dart';
import 'pop_screen_start.dart';

class MyGame extends FlameGame with TapCallbacks,KeyboardEvents {

  MyGame();

  Paint paint = BasicPalette.white.paint();
  int screenState = 0;
  late ScreenStart screenStart;
  late ScreenPlay screenPlay;
  late CommonTextActor tipTextActor;
  late ScreenMonit screenMonit;
  BaseScreen? lastScreen;
  List<String> options = [];

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    GameConstants.SCREEN_WIDTH = size.x;
    GameConstants.SCREEN_HEIGHT = size.y;
    await ImageTexture.init();
    var backBean = ImageBean();
    backBean.x = 0;
    backBean.y = 0;
    backBean.width = ImageTexture.imageBg.width;
    backBean.height = ImageTexture.imageBg.height;
    backBean.destWidth = size.x.toInt();
    backBean.destHeight = size.y.toInt();
    await add(TextureImageActor(ImageTexture.imageBg, backBean, null));
    screenStart = ScreenStart(size.x, size.y);
    screenPlay = ScreenPlay(size.x, size.y);
    screenMonit = ScreenMonit(size.x, size.y);
    await add(screenStart);
    lastScreen = screenStart;
    screenState = 1;

    tipTextActor = CommonTextActor(size.x-40,30);
    tipTextActor.x = 20;
    changeTipText(OllamaUtils.defaultModel);
    await add(tipTextActor);
    initAllModels();
  }

  Future<void> initAllModels() async{
    var lastModel = await ShareUtils.getStringData("chooseModel");
    if(lastModel!=null&&lastModel.length>0){
      changeTipText(lastModel);
      OllamaUtils.defaultModel = lastModel;
    }
    var ollama = OllamaUtils();
    options.clear();
    var models =await ollama.listModel();
    options.addAll(models);

}

void changeTipText(String model){
    var str = "当前选择大模型:${model},切换大模型需要重启应用,wasd角色走路，走到别的角色旁边按k可以聊天";
    tipTextActor.texts = str;
}

  @override
  void render(Canvas canvas) {
    if (screenState == 1) {
      super.render(canvas);
    }
  }

  void changeScreen(int state) {
    if (state == 2) {
      remove(screenStart);
      remove(tipTextActor);
      add(screenMonit);
      lastScreen = screenMonit;
    }
  }

  void finishGame() {

  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
  }

  @override
  void onTapUp(TapUpEvent event) {
    // TODO: implement onTapUp
    super.onTapUp(event);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    lastScreen?.onKeyEvent(event, keysPressed);
    return super.onKeyEvent(event, keysPressed);
  }
  void showSelection() {
    overlays.add('ChoiceMenu');
  }
}

class MyCrate extends SpriteComponent {
  MyCrate() : super(size: Vector2.all(16));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('crate.png');
  }
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    await add(MyCrate());
  }
}
