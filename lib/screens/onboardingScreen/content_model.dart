class OnboardingContent{
  String image;
  String title;
  String discription;

 OnboardingContent({
  required this.image,
  required this.title,
  required this.discription}
 );
}
List <OnboardingContent> contents =[
    OnboardingContent(
    title: 'AI Genie',
    image: 'assets/images/AI-bot1.jpg',
    discription: ('Welcome to AI Genie Assistant! Your intelligent virtual assistant powered by Google’s Gemini AI')),

   OnboardingContent(
    title: 'Get Quick Answer',
    image: 'assets/images/response1.jpg',
    discription: ('Ask anything, and Genie will instantly provide accurate, intelligent, and helpful responses')),

    OnboardingContent(
    title: 'Upload Images for Analysis',
    image: 'assets/images/image1.jpg',
    discription: ('Upload your photos or documents, and Genie will analyze and give you insightful details with precision')),

     OnboardingContent(
    title: 'Chat History',
    image: 'assets/images/chatHistory.jpg',
    discription: ('Revisit your previous conversations anytime! All your chat history is securely stored, making it easy to pick up where you left off')),

    OnboardingContent(
    title: 'Start New Chat',
    image: 'assets/images/newchat.jpg',
    discription: ('Begin a fresh conversation anytime! Tap the "ADD" Icon button and let Genie assist you with new questions, challenges, or ideas')),

];