import 'package:chatbot_gemini/Hive/chat_history.dart';
import 'package:chatbot_gemini/Hive/settings.dart';
import 'package:chatbot_gemini/Hive/user_model.dart';
import 'package:chatbot_gemini/constants.dart';
import 'package:hive/hive.dart';

class Boxes
{
  //get the chat histoy boxes

  static Box<ChatHistory> getChatHistory(){
  return Hive.box<ChatHistory>(Constants.chatHistoryBox);
  }

  //get the user box
  static Box<UserModel> getUser() => Hive.box<UserModel>(Constants.userBox);

  //get the setting box
  static Box<Settings> getSetting() => Hive.box<Settings>(Constants.settingsBox);
}