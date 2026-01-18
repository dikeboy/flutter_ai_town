import 'dart:ui';
import 'dart:ui' as Painting;

import '../image_texture.dart';
import 'actor_all.dart';
enum RoleDirection { UP, DOWN, LEFT, RIGHT }

class BaseRoleActor extends BaseActor {
  final Painting.Image spriteImage;
  final ImageBean imageBean;
  var roleDirection = RoleDirection.UP;
  var user = UserInfoBean();
  bool isWalk = false;
  double houseX = 0;
  double houseY = 0;

  void createRoleImageGetPos() {
    if (roleDirection == RoleDirection.UP) {
      imageBean.x = 37;
      imageBean.y = 98;
    } else if (roleDirection == RoleDirection.DOWN) {
      imageBean.x = 37;
      imageBean.y = 2;
    } else if (roleDirection == RoleDirection.LEFT) {
      imageBean.x = 37;
      imageBean.y = 34;
    } else if (roleDirection == RoleDirection.RIGHT) {
      imageBean.x = 37;
      imageBean.y = 66;
    }
  }

  void setUserInfo(UserInfoBean user){
    this.user = user;
  }
  void initPos(double x,double y){
    this.x = x;
    this.y = y;
    this.houseX = x;
    this.houseY = y;
  }

  Future<void> changePlan(int hour) async{
      if(user.plans!=null){
         if(hour>=0&&hour<user.plans.length){
           print("changePlay=${user.name}");
           var plan = user.plans[hour];
           if(plan.pos=="家"){
             walk(houseX,houseY);
           }else{
             var destPosition = ImageTexture.positionBean[plan.pos];
             if(destPosition!=null){
               walk(destPosition.x.toDouble(), destPosition.y.toDouble());
             }
           }

         }
      }
  }

  BaseRoleActor(this.spriteImage, this.imageBean, callBack)
    : super(imageBean.destWidth.toDouble(), imageBean.destHeight.toDouble(), callBack);

  @override
  Future<void> onLoad() async {}

  void changeRoleDirection(RoleDirection roleDirection) {
    this.roleDirection = roleDirection;
    createRoleImageGetPos();
  }
  Future<void> walk(double destX,double destY) async{
    if(isWalk)
      return;
    isWalk = true;
    double otherStep = 2;
    print("walk to position x=$x y=$y");
     if(y<destY){
       while(y<destY){
         y=y+otherStep;
         changeRoleDirection(RoleDirection.DOWN);
         await Future.delayed(Duration(milliseconds:30));
       }
     }else{
       while(y>destY){
         y=y-otherStep;
         changeRoleDirection(RoleDirection.UP);
         await Future.delayed(Duration(milliseconds:30));
       }
     }

     if(x<destX){
       while(x<destX){
         x=x+otherStep;
         changeRoleDirection(RoleDirection.RIGHT);
         await Future.delayed(Duration(milliseconds:30));
       }
     }else{
       while(x>destX){
         x=x-otherStep;
         changeRoleDirection(RoleDirection.LEFT);
         await Future.delayed(Duration(milliseconds:30));
       }
     }
     x = destX;
     y = destY;
     changeRoleDirection(RoleDirection.DOWN);
     isWalk = false;
  }

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

class UserRoleActor extends BaseRoleActor {
  UserRoleActor(spriteImage, imageBean, callBack) : super(spriteImage, imageBean, callBack);
}
