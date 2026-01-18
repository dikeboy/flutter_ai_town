import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flame/src/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mini_game/game/game/actor/actor_progress.dart';
import 'package:mini_game/game/game/pop_main.dart';
import 'package:mini_game/game/game/viewmodel/ollama_utils.dart';
import 'actor/actor_all.dart';
import 'base/screen_base.dart';
import 'image_texture.dart';
import 'dart:math' as Math;

class ScreenStart extends BaseScreen {
  @override
  double width;
  @override
  double height;
  ProgressActor? progressActor;
  Paint paint = BasicPalette.white.paint();
  var ollama = OllamaUtils();

  ScreenStart(this.width, this.height) : super(width, height);

  @override
  Future<void> onLoad() async {
     progressActor = ProgressActor(width,height, () {});
    progressActor?.x = 100;
    progressActor?.y = 60;
    progressActor?.width = width-200;
    progressActor?.height = 20;
     progressActor?.resetProgress();
    await add(progressActor!);

    var newGame = ImageTexture.getImageBean("new_game");
    var exitGame = ImageTexture.getImageBean("rate");
    var playActor = TextureImageActor(ImageTexture.baseImage, newGame, () {
      (parent as MyGame).changeScreen(2);
    });
    playActor.x = (size.x - newGame.width.toDouble()) / 2.toDouble();
    playActor.y = 200;
    //
    // final effect = SequenceEffect([
    //   MoveEffect.by(Vector2(30, -50), EffectController(duration: 0.5)),
    // MoveAlongPathEffect(
    // Path()..quadraticBezierTo(100, 0, 50, -50),
    // EffectController(duration: 1.5),
    // ),
    //   RemoveEffect(),
    // ]);

    var exitActor = TextureImageActor(ImageTexture.baseImage, exitGame, () {
      (parent as MyGame).showSelection();
    });
    exitActor.x = (size.x - newGame.width.toDouble()) / 2.toDouble();
    exitActor.y = 300;

    await add(playActor);
    await add(exitActor);

    loadPlan();
  }

  Future<void> loadPlan() async{
    await ImageTexture.loadUsers();
    ollama.createUsers();
    ImageTexture.loadPosition();
    var loadNum = Math.min(4, ImageTexture.userInfos.length);
    progressActor?.setProgress(20);
    for(int i=1;i<=loadNum;i++){
      String? planStr = ImageTexture.userInfos[i].life;
      if(planStr!=null){
        var plan = await ollama.makePlan(planStr);
        if(plan!=null&&plan.startsWith("[")){
          List<dynamic> data = jsonDecode(plan);
          for(int j=0;j<data.length;j++){
            var planBean = UserPlan();
            planBean.time = data[j]["time"];
            planBean.pos = data[j]["pos"];
            planBean.plan = data[j]["plan"];
            ImageTexture.userInfos[i].plans.add(planBean);

          }
        }
      }
      progressActor?.setProgress(((i+1)*80/loadNum).toInt()+20);
    }
  }
}
