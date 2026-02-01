import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:mini_game/game/game/image_texture.dart';
import 'package:mini_game/game/game/viewmodel/share_utils.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'dart:math' as Math;
import 'package:dio/dio.dart';

class MyOllamaClent extends OllamaClient {
  @override
  Future<http.BaseRequest> onRequest(http.BaseRequest request) {
    http.Request req = request as http.Request;
    req.body = req.body.substring(0, req.body.length - 1) + ",\"think\":false}";
    print(req.body);
    return super.onRequest(request);
  }
}

final dio = Dio();

class OllamaUtils {
  static var defaultModel = "qwen3:8b-q4_K_M";
  final client = MyOllamaClent();
  List<String> chatMessage = [];

  Future<String?> callOllama(String content, {bool remeber = false}) async {
    print("call $content");
    var messages = [
      Message(role: MessageRole.system, content: '不要推理，立刻返回结果'),
      Message(role: MessageRole.user, content: content),
    ];
    var startTime = DateTime.timestamp().millisecondsSinceEpoch;
    var request = GenerateChatCompletionRequest(
      model: defaultModel,
      messages: messages,
      keepAlive: 1,
      options: ollama.RequestOptions(
        // 降低随机性有时能让模型更直接，
        // 但注意：目前并没有直接的 'include_thinking' 布尔值
        temperature: remeber ? 0.4 : 0.1,
        numCtx: 8192,
        numGpu: 45,
        numThread: 8,
      ),
    );

    final result = await client.generateChatCompletion(request: request);
    var res = result.message.content;
    var endTime = DateTime.timestamp().millisecondsSinceEpoch;
    print("res" + res);
    if (chatMessage.length > 3) {
      chatMessage.removeAt(0);
    }
    if (remeber) {
      chatMessage.add(result.message.content);
    }
    print("usertime =${endTime - startTime}");
    return res;
  }

  Future<String?> callDioOllama(String content, {think=false,temperature=0.2}) async {
    var startTime = DateTime.timestamp().millisecondsSinceEpoch;
    var param = createRequestParam(content,think: think,temperature: temperature);
    var response = await dio.post(
      'http://localhost:11434/api/chat',
      options: Options(
        headers: {
          "Content-Type": "application/json",
        },
      ),
      data: param,
    );
    var endTime = DateTime.timestamp().millisecondsSinceEpoch;
    print("status =${response.statusCode}");
    var result = response.toString();
    Map<String, dynamic> resultMap = jsonDecode(result);
    var res = resultMap["message"]["content"];
    print("result=$res");
    print("usertime =${endTime - startTime}");
    if(res is String){
      return res;
    }
    return jsonEncode(res);
  }

  Map<String, dynamic> createRequestParam(String content,{think=true,temperature=0.5}) {
    Map<String, dynamic> map = {};
    map["model"] = defaultModel;
    map["stream"] = false;
    map["keep_alive"] = 1;
    map["think"] = false;
    var option = {};
    option["temperature"] =temperature;
    option["num_ctx"] = 8192;
    option["num_gpu"] = 45;
    option["num_thread"] = 8;
    map["options"] = option;
    map["think"] = think;
    var message = [];
    message.add({"role": "system", "content": "不要推理，立刻返回结果"});
    message.add({"role": "user", "content": content});
    map["messages"] = message;
    return map;
  }

  Future<String?> meetContent(UserInfoBean from, UserInfoBean to) async {
    chatMessage.clear();
    StringBuffer sb = StringBuffer();
    sb.write(from.name);
    sb.write("路过碰到了");
    sb.write(to.name);
    sb.write("准备打个招呼,");
    sb.write(to.name);
    sb.write("的个人简介");
    sb.write(to.introduce);
    sb.write(", 要求招呼文案不能超过30个字，最好能根据对方的兴取,返回语句带上自己姓名:, 回复内容里面不要带对方名字");
    return await callOllama(sb.toString(), remeber: true);
  }

  Future<String?> resMeetContent(
    String content,
    UserInfoBean from,
    UserInfoBean to,
  ) async {
    StringBuffer sb = StringBuffer();
    sb.write("你现在是${from.name},");
    sb.write(
      "请回复${to.name},要求内容不能超过30个字,返回语句带上自己姓名:(例如李四:XXX),回复内容里面不要带对方名字,之前对话内容(多条以|分割):",
    );
    var max = Math.min(chatMessage.length, 3);
    for (int i = 0; i < max; i++) {
      sb.write(chatMessage[i]);
      if (i < max - 1) sb.write("|");
    }
    return await callOllama(sb.toString(), remeber: true);
  }

  Future<String?> makePlan(String content) async {
    String tip =
        "${content},前面为需要处理的内容，"
        "帮我列出24个小时都在干嘛, 时间从0点到24点，一共24条数据，如果当前时间点没数据，就复用前面那个，"
        "前面也没数据，就复用后面第一个，没有地址显示家,例子如下:输入：早上7点起床,8点吃饭,9点到11点在公园写生,"
        "12点吃饭,13点到15点在房间1午睡,16点到18点在池塘边散步找灵感,19点吃饭,20点到22点在房间1整理画稿,"
        "然后睡觉[{\"time\":7,\"pos\":\"家\",\"plan\":\"睡觉\"}]";
    String? res = await callOllama(tip);
    return res;
  }

  Future<String?> createUsers() async {
    String tip ="帮忙创造6个角色，包含名字，个人介绍，还有日常作息，除了起床,吃饭，睡觉,其它都为几点去哪里干嘛,地点从下面几个中选择(公园,池塘,房间1，房间2，房间3,房间4，房间5) 生成json格式给我，格式如下： { \"users\": [ { \"name\": \"大卫\", \"introduce\":\"爱好打球，看书\", \"life\": \"早上8点起床,9点吃饭,10点到12点看书,12点吃饭,13点到6点睡午觉,7点吃饭,8点到10点看电视,然后睡觉\" }]";
    String? res = await callDioOllama(tip,think: true,temperature: 0.5);
    if(res!=null&&res.contains("[")){
      res = res.substring(res.indexOf("{"),res.lastIndexOf("}"));
      ShareUtils.putStringData("usersInfo", res.trim());
    }
    return res;
  }

  Future<List<String>> listModel() async {
    var response = await dio.get(
      'http://localhost:11434/api/tags',
      options: Options(
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );
    var result = response.toString();
    Map<String, dynamic> resultMap = jsonDecode(result);
    List<dynamic> list = resultMap["models"];
    List<String> models = [];
    for (var model in list) {
      models.add(model["name"]);
    }
    return models;
  }
}
