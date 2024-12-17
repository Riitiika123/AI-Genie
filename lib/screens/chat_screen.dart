import 'package:chatbot_gemini/constants.dart';
import 'package:chatbot_gemini/models/utility/animated_dialog.dart';
import 'package:chatbot_gemini/providers/chat_providers.dart';
import 'package:chatbot_gemini/screens/onboardingScreen/onboarding.dart';
import 'package:chatbot_gemini/widgets/bottom_chat_field.dart';
import 'package:chatbot_gemini/widgets/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  //Scroll controller
 final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom(){
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0.0){
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
         curve: Curves.easeOut,
         );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {

      if(chatProvider.inChatMessages.isNotEmpty){
        _scrollToBottom();
      }

      //auto scroll to bottom on new message
      chatProvider.addListener((){
        if(chatProvider.inChatMessages.isNotEmpty){
          _scrollToBottom();
        }
      });

      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset('assets/images/AI Genie.png',height: 55,),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          leading: IconButton(
             icon: const Icon(Icons.arrow_back),
             onPressed: (){
              Navigator.pushReplacement(context,
               MaterialPageRoute(builder: (context) => const OnBoarding(),
               )
              );
             },),
          actions: [
            if(chatProvider.inChatMessages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor:Pallete.buttonColor,
                  child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async{
                    //show my animated dialog to start a new chat
                    showAnimatedDialog(
                      context: context,
                      title: 'Start new Chat',
                      content: 'Are you sure you want to start new chat? ',
                      actionText: 'Yes', 
                      onActionPressed: (value) async{
                        if(value){
                          //prepare chat
                          await chatProvider.prepareChat(
                            isnewChat: true,
                            chatId: '');
                        }
                      });
                  },
                  ),
                ),
              )
            
          ],
        ),

        //body of chat screen
        body: SafeArea(
            child: Padding(
                padding:const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Expanded(
                        child: chatProvider.inChatMessages.isEmpty
                            ? const Center(
                                child: Text('How Can I Help You Today?',
                                style: TextStyle(
                                  fontSize: 35,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600
                                ),),
                              )
                            : ChatMessages(scrollController: _scrollController,chatProvider: chatProvider,)),
                    //input field
                    BottomChatField(
                      chatProvider: chatProvider,
                    )
                  ],
                ))),
      );
    });
  }
}

