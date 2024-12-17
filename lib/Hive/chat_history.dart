import 'package:chatbot_gemini/models/message.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'chat_history.g.dart';

@HiveType(typeId:0)
class ChatHistory extends HiveObject{
  @HiveField(0)
final String chatId;

  @HiveField(1)
final String prompt;

  @HiveField(2)
final String response;

  @HiveField(3)
final List<String> imagesUrls;

  @HiveField(4)
 final DateTime timestamp;

  @HiveField(5)
  final Role role;  // Add the Role field to model

 //constructor
 ChatHistory({
  required this.chatId,
  required this.prompt,
  required this.response,
  required this.imagesUrls,
  required this.timestamp,
  //nullable role
    this.role = Role.user,  // Pass the Role value here 

 });
}