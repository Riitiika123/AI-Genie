import 'package:chatbot_gemini/Hive/boxes.dart';
import 'package:chatbot_gemini/Hive/chat_history.dart';
import 'package:chatbot_gemini/widgets/chat_history_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChathistoryScreen extends StatefulWidget {
  const ChathistoryScreen({super.key});

  @override
  State<ChathistoryScreen> createState() => _ChathistoryScreenState();
}

class _ChathistoryScreenState extends State<ChathistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Chat History'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: ValueListenableBuilder<Box<ChatHistory>>(
        valueListenable: Boxes.getChatHistory().listenable(),
        builder: (context, box, _) {
          final chatHistory = box.values.toList().cast<ChatHistory>().reversed.toList();
            // print('Chat history loaded: ${chatHistory.length} items');
          return chatHistory.isEmpty ?
          const Center(
             child: Text('No Chat History'),
          ):
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context,index){
                final chat= chatHistory[index];
                return chatHistoryWidget(chat: chat);
              }),
          );
        }
      ),
    );
  }
}

