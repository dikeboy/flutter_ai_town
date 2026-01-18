import 'dart:ui';
import 'dart:ui' as Painting;

import 'package:flutter/material.dart';

import '../image_texture.dart';
import 'actor_all.dart';
import 'package:flame/components.dart';


class MMImageActor extends BaseActor {
  final Painting.Image spriteImage;
  final ImageBean imageBean;

  MMImageActor(this.spriteImage, this.imageBean, callBack)
      : super(imageBean.destWidth.toDouble(), imageBean.destHeight.toDouble(), callBack);

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
  }
}
class MMHouseActor extends BaseActor {
  final Painting.Image spriteImage;
  final ImageBean imageBean;

  MMHouseActor(this.spriteImage, this.imageBean, callBack)
    : super(imageBean.destWidth.toDouble(), imageBean.destHeight.toDouble(), callBack);

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
  }
}


class CommonTextActor extends PositionComponent {
  @override
  double width = 0;
  @override
  double height = 0;
  late final _textPaint = TextPaint(style: TextStyle(color: Colors.red));
  String texts ="";
  bool isWriting = false;
  bool isTimeRender = true;

  CommonTextActor(this.width, this.height) : super(position:Vector2(0,0),size: Vector2(width, height)) {}

  Future<void> writeText(String text,{bool systemData=false}) async {
      this.texts = text;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _textPaint.render(canvas, texts, Vector2(0,0));
  }
}


class MMTextActor extends PositionComponent {
  @override
  double width = 0;
  @override
  double height = 0;
   TimeCallBack callBack;
  late final _textPaint = TextPaint(style: TextStyle(color: Colors.red));
  List<String> texts =[];
  bool isWriting = false;
  bool isTimeRender = true;
  String timeText = "";
  int currentHour = 0;

  MMTextActor(this.width, this.height,this.callBack) : super(position:Vector2(30,10),size: Vector2(width-60, height-60)) {}

  Future<void> writeText(String text,{bool systemData=false}) async {
    texts.add(text);
    if(texts.length>4){
      texts.removeAt(0);
    }
    await Future.delayed(Duration(seconds: 12));
    if(texts.length>0){
      texts.removeAt(0);
    }
  }

  Future<void> renderTime() async{
    DateTime time = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      8,  // hour
      0,  // minute
    );

    while(isTimeRender){
      String hour = time.hour.toString().padLeft(2, '0');
      String minute = time.minute.toString().padLeft(2, '0');
      timeText =  '$hour:$minute';
      // 格式化时间
      await Future.delayed(Duration(milliseconds: 100));
      String formattedTime = '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';
      time = time.add(const Duration(minutes: 1));
      if(currentHour!=time.hour){
         currentHour = time.hour;
         callBack.call(currentHour);
      }
    }
  }
  @override
  void onRemove() {
    // TODO: implement onRemove
    super.onRemove();
    isTimeRender = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _textPaint.render(canvas, timeText, Vector2(width/2-40,0));
    if (texts.isNotEmpty) {
      for(int i=0;i<texts.length;i++){
        _textPaint.render(canvas, texts[i], Vector2(0, i*25));
      }
    }
  }
}
