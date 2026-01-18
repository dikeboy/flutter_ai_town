
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:mini_game/game/game/actor/actor_all.dart';
import 'dart:ui' as Painting;
import 'dart:ui';
import 'package:flame/components.dart';

class ProgressActor extends BaseActor{
  int progress = 0;
  int maxProgress = 100;
  bool isFinish = false;
  late final bgPaint = Paint();
  late final progressPaint =  Paint();
  String renderText = "角色性格初始化中...";
  late final _textPaint = TextPaint(style: TextStyle(color: Color(0xff666666)));

  ProgressActor(width,height, callBack)
      : super(width.toDouble(), height.toDouble(), callBack){
    bgPaint.color = Color(0x30000000);
    progressPaint.color= Color(0x9900ff00);
  }

  void resetProgress(){
    this.progress = 0;
    this.maxProgress = 100;
    isFinish = false;
  }

  void setProgress(int progress){
    if(progress>=maxProgress){
      progress = maxProgress;
    }
    this.progress = progress;
  }
  var raids = Radius.circular(10);

  @override
  void render(Painting.Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(RRect.fromLTRBAndCorners(0, 0, width, height, topLeft: raids,topRight: raids,
        bottomLeft: raids,bottomRight:raids), bgPaint);

    canvas.drawRRect(RRect.fromLTRBAndCorners(0, 0, progress*width/maxProgress, height, topLeft: raids,topRight: raids,
        bottomLeft: raids,bottomRight:raids), progressPaint);
    _textPaint.render(canvas, renderText, Vector2(0,0));
  }
}