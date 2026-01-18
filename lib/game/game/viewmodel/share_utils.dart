import 'package:shared_preferences/shared_preferences.dart';

class ShareUtils {

  static Future<String?> getStringData(String key) async{
     final  SharedPreferences prefs = await SharedPreferences.getInstance();
     return prefs.getString(key);
  }

  static Future putStringData(String key,String value) async{
    final  SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key,value);
  }
}