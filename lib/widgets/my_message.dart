import 'package:chatbot_gemini/models/message.dart';
import 'package:chatbot_gemini/widgets/preview_images_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MyMessage extends StatelessWidget {
  const MyMessage({super.key,required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width*0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            if(message.imageUrls.isNotEmpty)
            PreviewImagesWidget(message: message),
            MarkdownBody(
              selectable: true,
              data: message.message.toString(),),
          ],
        ),
      ),
    );
  }
}