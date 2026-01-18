import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:mini_game/game/game/viewmodel/ollama_utils.dart';
import 'package:mini_game/game/game/viewmodel/share_utils.dart';

class ImageTexture {
  static late Image baseImage;
  static late Image blueImage;
  static late Image greenImage;
  static late Image purpleImage;
  static late Image redImage;
  static late Image yellowImage;
  static late Image imageBg;
  static late Image roleImage;
  static late Image houseImage;
  static late Image gardenImage;
  static late Image chitangImage;
  static List<Image> otherRoles = [];
  static  Map<String,PostionBean> positionBean = {};
  static  List<UserInfoBean> userInfos = [];
  static Map<String, ImageBean> images = HashMap();

  static Future<void> init() async {
    var data = await rootBundle.loadString("assets/files/popstar.txt");
    var list = data.split("\n");
    List<ImageBean> imageList = [];
    ImageBean bean;
    bool start = false;
    for (int i = 0; i < list.length; i++) {
      String line = list[i];
      if (line.contains("repeat: none")) {
        start = true;
      } else if (start && line.trim().length > 2) {
        bean = ImageBean();
        bean.name = line.toString().trim();
        line = list[++i];
        if (line.contains("rotate") && line.contains("true")) {
          bean.rotate = true;
        }
        line = list[++i];
        bean.x = getSpliteInt(line, "xy")[0];
        bean.y = getSpliteInt(line, "xy")[1];
        line = list[++i];
        bean.width = getSpliteInt(line, "size")[0];
        bean.height = getSpliteInt(line, "size")[1];
        line = list[++i];
        bean.origX = getSpliteInt(line, "orig")[0];
        bean.origY = getSpliteInt(line, "orig")[1];
        line = list[++i];
        bean.offsetX = getSpliteInt(line, "offset")[0];
        bean.offsetY = getSpliteInt(line, "offset")[1];
        images[bean.name!] = bean;
        list[++i];
        bean.destWidth = bean.width;
        bean.destHeight = bean.height;
      }
    }
    baseImage = await Flame.images.load('popstar.png');
    blueImage = await Flame.images.load('star_p_blue.png');
    greenImage = await Flame.images.load('star_p_green.png');
    purpleImage = await Flame.images.load('star_p_purple.png');
    redImage = await Flame.images.load('star_p_red.png');
    yellowImage = await Flame.images.load('star_p_yellow.png');
    imageBg = await Flame.images.load('newbg.png');
    roleImage = await Flame.images.load("mm_role.png");
    houseImage = await Flame.images.load("mm_house.png");
    gardenImage = await Flame.images.load("mm_garden.jpg");
    chitangImage = await Flame.images.load("mm_chitang.jpg");

    otherRoles.add(await Flame.images.load("texture1.png"));
    otherRoles.add(await Flame.images.load("texture2.png"));
    otherRoles.add(await Flame.images.load("texture3.png"));
    otherRoles.add(await Flame.images.load("texture4.png"));

    //loadAgent
  }

  static Future<void> loadUsers() async{
    var agentStr = await ShareUtils.getStringData("usersInfo");
    if(agentStr==null||agentStr.length<10){
       agentStr = await rootBundle.loadString("assets/files/agent.json");
    }
    print("agentStr=$agentStr");
    Map<String, dynamic> data = jsonDecode(agentStr);
    List<dynamic> users = data['users'];
    print('--- 开始遍历用户信息 ---');
    for (var user in users) {
      var userBean =UserInfoBean();
      userBean.name = user["name"];
      userBean.introduce = user["introduce"];
      userBean.life = user["life"];
      userInfos.add(userBean);
    }
  }

  static Future<void> loadPosition() async{
    var agentStr = await rootBundle.loadString("assets/files/position.json");
    Map<String, dynamic> data = jsonDecode(agentStr);
    List<dynamic> users = data['positions'];
    for (var user in users) {
      var userBean =PostionBean();
      userBean.name = user["name"];
      userBean.x = user["x"];
      userBean.y = user["y"];
      if(userBean.name!=null){
        positionBean[userBean.name!] = userBean;
      }
    }
  }

  static ImageBean getImageBean(String name) {
    return images[name]!;
  }
}

List<int> getSpliteInt(String line, String key) {
  List<int> pair = [];
  if (line.contains(key)) {
    var start = line.indexOf("$key:") + key.length + 1;
    List<String> str = line.substring(start).split(",");
    pair.add(int.parse(str[0].trim()));
    pair.add(int.parse(str[1].trim()));
  }
  return pair;
}

class ImageBean {
  String? name;
  bool rotate = false;
  int x = 0;
  int y = 0;
  int width = 0;
  int height = 0;
  int origX = 0;
  int origY = 0;
  int offsetX = 0;
  int offsetY = 0;
  int destWidth = 0;
  int destHeight = 0;

  static ImageBean createImageBean(int x,int y,int width,int height){
    ImageBean imageBean = new ImageBean();
    imageBean.x = x;
    imageBean.y = y;
    imageBean.width = width;
    imageBean.height = height;
    imageBean.destWidth = width;
    imageBean.destHeight = height;
    return imageBean;
  }
}

class PostionBean{
  String? name;
  int x = 0;
  int y = 0;
}
class UserPlan{
  int time =0;
  String? pos;
  String? plan;
}
class UserInfoBean{
  String? name;
  String? introduce;
  String? life;
  List<UserPlan> plans = [];

  OllamaUtils? ollamaUtils;
  void initAgent(){
    ollamaUtils = OllamaUtils();
  }
}


