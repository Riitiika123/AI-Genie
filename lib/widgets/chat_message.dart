import 'package:chatbot_gemini/models/message.dart';
import 'package:chatbot_gemini/providers/chat_providers.dart';
import 'package:chatbot_gemini/widgets/assistant_message.dart';
import 'package:chatbot_gemini/widgets/my_message.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    super.key,
    required this.scrollController,
    required this.chatProvider,
  });

  final ScrollController scrollController;
  final ChatProvider chatProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
        itemCount: chatProvider.inChatMessages.length,
        itemBuilder: (context, index) {
          final message =
              chatProvider.inChatMessages[index];
          return message.role.name == Role.user.name ? 
          MyMessage(message: message) :
          AssistantMessage(message: message.toString());
        });
  }
}
