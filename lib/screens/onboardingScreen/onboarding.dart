import 'package:chatbot_gemini/constants.dart';
import 'package:chatbot_gemini/screens/home_screen.dart';
import 'package:chatbot_gemini/screens/onboardingScreen/content_model.dart';
import 'package:flutter/material.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return Padding(
                    padding:  EdgeInsets.fromLTRB(
                    screenWidth * 0.08, // 8% of screen width
                    screenHeight * 0.1, // 10% of screen height
                    screenWidth * 0.08,
                    screenHeight * 0.05,
                    ),
                    child: Column(
                      children: [
                        Text(
                          contents[i].title,
                          style: TextStyle(
                            fontSize: screenHeight* 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                         SizedBox(
                          height: screenHeight*0.02,
                        ),
                        Expanded(
                        child: Image.asset(
                          contents[i].image,
                          fit: BoxFit.contain,)),
                        SizedBox(
                          height:screenHeight*0.03
                        ),
                        Text(
                          contents[i].discription,
                          textAlign: TextAlign.center,
                          style:TextStyle(
                            fontSize: screenHeight*0.02,
                            color: Colors.black54
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
          //Dots Indicator
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  contents.length, (index) => buildDot(index, context))),

          //Button Section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // 5% of screen width
              vertical: screenHeight * 0.02, // 2% of screen height
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Skip Button
              children: [
                SizedBox(
                   width: screenWidth * 0.4, // 40% of screen width
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Pallete.buttonColor,
                ),
                onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              //Next button
             SizedBox(
                  width: screenWidth * 0.4, // 40% of screen width
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallete.buttonColor,
                    ),
                  child: Text(
                    currentIndex == contents.length - 1
                        ? 'Get Started'
                        : "Next",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16
                    ),
                  ),
                  onPressed: () {
                    if (currentIndex == contents.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    } else {
                      _controller.nextPage(
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.bounceIn);
                    }
                  },
                ),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenWidth * 0.02,
      width: currentIndex == index ? screenWidth * 0.06 : screenWidth * 0.03,
      margin:  EdgeInsets.only(right:screenWidth*0.01 ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Pallete.buttonColor,
      ),
    );
  }
}
