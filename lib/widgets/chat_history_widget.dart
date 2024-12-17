import 'package:chatbot_gemini/Hive/chat_history.dart';
import 'package:chatbot_gemini/providers/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class chatHistoryWidget extends StatelessWidget {
  const chatHistoryWidget({
    super.key,
    required this.chat,
  });

  final ChatHistory chat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.chat_outlined),
        title: Text(chat.prompt, maxLines: 1,),
        subtitle: Text(chat.response, maxLines: 1,),
        trailing: IconButton( 
          icon: const Icon(Icons.delete),
          onPressed: () async{
            //delete the chat using chat provider
            await context.read<ChatProvider>().deleteChat(chatId: chat.chatId);
             await chat.delete();
          }
        ),
    

        onTap:() async{
          //navigate to chat screen
          //read from chat provider
          final chatProvider = context.read<ChatProvider>();
          //prepare chat await
          await chatProvider.prepareChat(
            isnewChat: false,
             chatId: chat.chatId);
          chatProvider.setCurrentIndex(newIndex: 0);
          chatProvider.pageController.jumpToPage(0);
        },

        
      ),
    );
  }
}