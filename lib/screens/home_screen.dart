import 'package:chatbot_gemini/providers/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:chatbot_gemini/screens/chat_screen.dart';
import 'package:chatbot_gemini/screens/chat_history_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //list of Screens
  final List<Widget> _screens = [
    const Chatscreen(),
    const ChathistoryScreen(),
    //const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child)  {
       return Scaffold(
        body: PageView(
          controller: chatProvider.pageController,
          children: _screens,
          onPageChanged: (index){
          chatProvider.setCurrentIndex(newIndex: index);
          },
        ),
      
        //bottom navigation bar
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: chatProvider.currentIndex,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: (index){
            setState(() {
              chatProvider.setCurrentIndex(newIndex: index);
              chatProvider.pageController.jumpToPage(index);
            });
          },
          items: const[
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
      
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
      
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.person),
            //   label: 'Profile'),
          ],
        ),
      );
      }
      );
  }
}