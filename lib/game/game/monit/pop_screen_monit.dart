import 'dart:math';
import 'dart:ui' as Painting;

import 'package:flame/components.dart';
import 'package:flame/src/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:mini_game/game/game/actor/actor_house.dart';
import 'package:mini_game/game/game/actor/actor_role.dart';
import 'package:mini_game/game/game/base/screen_base.dart';
import 'package:mini_game/game/game/pop_main.dart';
import 'package:mini_game/game/game/viewmodel/ollama_utils.dart';
import 'dart:math' as Math;
import '../actor/actor_all.dart';
import '../image_texture.dart';

class ScreenMonit extends BaseScreen {
  @override
  double width;
  @override
  double height;
  Paint paint = BasicPalette.white.paint();
  BaseRoleActor? roleActor;
  MMTextActor? mmTextActor;
  List<MMHouseActor> houseList = [];
  List<BaseRoleActor> roleActors = [];
  double step = 12;

  ScreenMonit(this.width, this.height) : super(width, height);
  var ollama = OllamaUtils();

  @override
  Future<void> onLoad() async {
    double hheight = 190;
    double hwidth  = width/5;
    var houseActor = createHouseActor(0, height - hheight, hwidth, hheight);
    houseList.add(houseActor);
    houseActor = createHouseActor(hwidth, height - hheight, hwidth, hheight);
    houseList.add(houseActor);
    houseActor = createHouseActor(hwidth*2, height - hheight, hwidth, hheight);
    houseList.add(houseActor);
    houseActor = createHouseActor(hwidth*3, height - hheight, hwidth, hheight);
    houseList.add(houseActor);
    houseActor = createHouseActor(hwidth*4, height - hheight, hwidth, hheight);
    houseList.add(houseActor);
    for (int i = 0; i < houseList.length; i++) {
      await add(houseList[i]);
    }
    var gardenActor = createImageActor(ImageTexture.gardenImage,0, 0, 300, 270);
    await add(gardenActor);

    var chitangActor = createImageActor(ImageTexture.chitangImage,width-300,-100,400,400);
    await add(chitangActor);

    mmTextActor = MMTextActor(width, height,(hour){
      changeRolePlan(hour);
    });
    add(mmTextActor!);

    houseActor = createHouseActor(550, height - hheight, width - 550, hheight);
    houseList.add(houseActor);


    roleActor = BaseRoleActor(ImageTexture.roleImage, ImageBean.createImageBean(6, 2, 23, 31), () {});
    roleActor?.setUserInfo(ImageTexture.userInfos[0]);
    roleActor!.x = size.x / 2.toDouble();
    roleActor!.y = size.y / 2;
    roleActor?.changeRoleDirection(RoleDirection.UP);
    await add(roleActor!);

    createOtherRoles();

    mmTextActor?.renderTime();
    // roleActors[0].walk(500, 300);
  }

  Future<void> createOtherRoles() async {
    for (int i = 0; i < ImageTexture.otherRoles.length; i++) {
      var role = BaseRoleActor(ImageTexture.otherRoles[i], ImageBean.createImageBean(6, 2, 23, 31), () {});
      role?.setUserInfo(ImageTexture.userInfos[i + 1]);
      role?.initPos(i * 150.toDouble() + 100,height-100);
      role?.changeRoleDirection(RoleDirection.DOWN);
      roleActors.add(role);
      await add(role!);
    }
  }

  MMHouseActor createHouseActor(double x, double y, double width, double height) {
    var houseActor = MMHouseActor(
      ImageTexture.houseImage,
      ImageBean.createImageBean(0, 0, ImageTexture.houseImage.width, ImageTexture.houseImage.height),
      () {},
    );
    houseActor.width = width;
    houseActor.height = height;
    houseActor.x = x;
    houseActor.y = y;
    return houseActor;
  }

  MMImageActor createImageActor( Painting.Image gardenImage,double x, double y, double width, double height) {
    var houseActor = MMImageActor(
      gardenImage,
      ImageBean.createImageBean(0, 0, gardenImage.width, gardenImage.height),
          () {},
    );
    houseActor.width = width;
    houseActor.height = height;
    houseActor.x = x;
    houseActor.y = y;
    return houseActor;
  }

  @override
  void onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    if (roleActor != null) {
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        roleMove(RoleDirection.UP, roleActor!, step);
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        roleMove(RoleDirection.DOWN, roleActor!, step);
      } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
        roleMove(RoleDirection.LEFT, roleActor!, step);
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        roleMove(RoleDirection.RIGHT, roleActor!, step);
      }
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.keyK) {
          var closeRole = findClosestRole(roleActor!);
          if (closeRole != null) {
            print(closeRole.user.name);
            doMeet(roleActor!.user, closeRole.user);
          }
        }
      }
    }
  }
  Future<void> doMeet(UserInfoBean from,UserInfoBean to) async{
    var res = await ollama.meetContent(from, to);
    mmTextActor?.writeText("${res}");
    if(res!=null){
       res = await ollama.resMeetContent(res,to,from);
      mmTextActor?.writeText("${res}");
    }
    if(res!=null){
      res = await ollama.resMeetContent(res,from,to);
      mmTextActor?.writeText("${res}");
    }
    if(res!=null){
      res = await ollama.resMeetContent(res,to,from);
      mmTextActor?.writeText("${res}");
    }

  }

  Future<void> changeRolePlan(int hour) async{
    var random = Math.Random();
    for(int i=0;i<roleActors.length&&i<4;i++) {
      var user = roleActors[i].user;
      if (hour >= 0 && hour < user.plans.length) {
        print("changePlay=${user.name}");
        var plan = user.plans[hour];
        if (plan.pos == "家") {
          mmTextActor?.writeText("${user.name}准备回家了",systemData: true);
          roleActors[i].walk( roleActors[i].houseX,  roleActors[i].houseY);
        } else {
          var destPosition = ImageTexture.positionBean[plan.pos];
          if (destPosition != null) {
            mmTextActor?.writeText("${user.name}准备去${plan.pos}${plan.plan}",systemData: true);
            roleActors[i].walk(destPosition.x.toDouble()+random.nextInt(80) -40, destPosition.y.toDouble()+random.nextInt(80)-40);
          }
        }
      }
    }
  }

  BaseRoleActor? findClosestRole(BaseRoleActor actor) {
    double maxDis = 50;
    BaseRoleActor? closeRole;
    double x = actor.x + actor.width / 2;
    double y = actor.y + actor.height / 2;
    double currentDis = 10000;
    for (int i = 0; i < roleActors.length; i++) {
      double rx = roleActors[i].x + roleActors[i].width / 2;
      double ry = roleActors[i].y + roleActors[i].height / 2;
      double dis = Math.sqrt((x - rx) * (x - rx) + (y - ry) * (y - ry));
      if (dis < maxDis && dis < currentDis) {
        currentDis = dis;
        closeRole = roleActors[i];
      }
    }
    return closeRole;
  }

  void roleMove(RoleDirection direction, BaseRoleActor roleActor, double step) {
    if (checkCanGo(direction, roleActor, step)) {
      if (direction == RoleDirection.UP) {
        roleActor.y = roleActor.y - step;
      } else if (direction == RoleDirection.DOWN) {
        roleActor.y = roleActor.y + step;
      } else if (direction == RoleDirection.LEFT) {
        roleActor.x = roleActor.x - step;
      }
      if (direction == RoleDirection.RIGHT) {
        roleActor.x = roleActor.x + step;
      }
      roleActor.changeRoleDirection(direction);
    }
  }

  bool checkCanGo(RoleDirection direction, BaseRoleActor roleActor, double step) {
    if (direction == RoleDirection.UP) {
      if (roleActor.y - step > 0) {
        return true;
      }
    } else if (direction == RoleDirection.DOWN) {
      if (roleActor.y + roleActor.height + step < height) {
        return true;
      }
    } else if (direction == RoleDirection.LEFT) {
      if (roleActor.x - step > 0) {
        return true;
      }
    } else if (direction == RoleDirection.RIGHT) {
      if (roleActor.x + roleActor.width + step < width) {
        return true;
      }
    }
    return false;
  }
}
