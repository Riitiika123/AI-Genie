import 'package:chatbot_gemini/providers/chat_providers.dart';
import 'package:chatbot_gemini/screens/onboardingScreen/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await ChatProvider.initHive();

  runApp(MultiProvider(providers:[
    ChangeNotifierProvider(create: (context) => ChatProvider()),
  ],
  child: const MyApp(),
  ));  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 4,
        )
      ),
      debugShowCheckedModeBanner: false,
      home: const OnBoarding(),
    );
  }
}

