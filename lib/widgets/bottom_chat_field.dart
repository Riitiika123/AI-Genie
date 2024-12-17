import 'package:chatbot_gemini/constants.dart';
import 'package:chatbot_gemini/models/utility/animated_dialog.dart';
import 'package:chatbot_gemini/providers/chat_providers.dart';
import 'package:chatbot_gemini/widgets/preview_images_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({super.key, required this.chatProvider});
  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  //controller for input field
  final TextEditingController textController = TextEditingController();

  //focus node for the input field
  final FocusNode textFieldFocus = FocusNode();

  //initialize image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    try {
      await chatProvider.SendMessages(message: message, isTextOnly: isTextOnly);
    } catch (e) {
      print('error: $e');
    } finally {
      textController.clear();
      widget.chatProvider.setImagesFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

  //pick an image
  void pickImage() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        imageQuality: 95,
        maxWidth: 800,
        maxHeight: 800,
      );
      widget.chatProvider.setImagesFileList(listValue: pickedImages);
    } catch (e) {
      print('error:$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).textTheme.titleLarge!.color!,
        ),
      ),
      child: Column(
        children: [
          if (hasImages)
            const PreviewImagesWidget(
              message: null,
            ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    if (hasImages) {
                      //show the delete dialog
                      showAnimatedDialog(
                          context: context,
                          title: 'Delete Images',
                          content: 'Are you sure to delete images?',
                          actionText: 'Delete',
                          onActionPressed: (value) {
                            if (value) {
                              widget.chatProvider
                                  .setImagesFileList(listValue: []);
                            }
                          });
                    } else {
                      pickImage();
                    }
                  },
                  icon: Icon(
                      hasImages ? Icons.delete_forever : Icons.image_rounded)),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: TextField(
                  focusNode: textFieldFocus,
                  controller: textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (String value) {
                    if (value.isNotEmpty) {
                      //send the message
                      sendChatMessage(
                          message: textController.text,
                          chatProvider: widget.chatProvider,
                          isTextOnly: hasImages ? false : true);
                    }
                  },
                  decoration: InputDecoration.collapsed(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      )),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (textController.text.isNotEmpty) {
                    //send the message
                    sendChatMessage(
                        message: textController.text,
                        chatProvider: widget.chatProvider,
                        isTextOnly: hasImages ? false : true);
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                      color:Pallete.buttonColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(5.0),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.send_rounded),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}
