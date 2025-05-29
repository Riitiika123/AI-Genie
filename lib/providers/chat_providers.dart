import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:chatbot_gemini/API/api_service.dart';
import 'package:chatbot_gemini/Hive/boxes.dart';
import 'package:chatbot_gemini/Hive/chat_history.dart';
import 'package:chatbot_gemini/Hive/settings.dart';
import 'package:chatbot_gemini/Hive/user_model.dart';
import 'package:chatbot_gemini/constants.dart';
import 'package:chatbot_gemini/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  //list of messages
  final List<Message> _inChatMessages = []; //private variable

 //page controller
  final PageController _pageController = PageController();

  //image file list
  List<XFile>? _imagesFileList = [];

  //index of current screen
  int _currentIndex = 0;

  //current chatId
  String _currentChatId = '';

  //Initialize generative model
  GenerativeModel? _model;

  //initialize text model
  GenerativeModel? _textModel;

  //initialize vision model
  GenerativeModel? _visionModel;

  //current model
  String _modelType = 'gemini-1.5-flash-latest';

  //loading bool
  bool _isLoading = false;

  //getters
  List<Message> get inChatMessages => _inChatMessages;

  PageController get pageController => _pageController;

  List<XFile>? get imagesFileList => _imagesFileList;

  int get currentIndex => _currentIndex;

  String get currentChatId => _currentChatId;

  GenerativeModel? get model => _model;

  GenerativeModel? get textModel => _textModel;

  GenerativeModel? get visionModel => _visionModel;

  String get modelType => _modelType;

  bool get isloading => _isLoading;

  //setters
  set inChatMessages(List<Message> value) {
    inChatMessages = value;
    notifyListeners();
  }

  //set inChatMessage
  Future<void> setinChatMessages({required String chatId}) async {
    //get message from hive DB
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);

    for (var message in messagesFromDB) {
      if (inChatMessages.contains(message)) {
        log('message already exists');
        continue;
      }
      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  //load messages from DB
  Future<List<Message>> loadMessagesFromDB({required chatId}) async {
    await Hive.openBox('${Constants.chatMessageBox}$chatId');

    final messagesBox = Hive.box('${Constants.chatMessageBox}$chatId');

    final newData = messagesBox.keys.map((e) {
      final message = messagesBox.get(e);
      final messageData = Message.fromMap(Map<String, dynamic>.from(message));
      return messageData;
    }).toList();
    notifyListeners();
    return newData;
  }

  //set file list
  void setImagesFileList({required List<XFile> listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

  //set the current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  //function to set the model based send text or not(image)
  Future<void> setModel({required bool isTextOnly}) async {
    try{
    if (isTextOnly) {
      _model = _textModel ??
          GenerativeModel(
              model: setCurrentModel(newModel: 'gemini-1.5-flash-latest'),
              apiKey: ApiService.aPIkey);
    } else {
      _model = _visionModel ??
          GenerativeModel(
              model:
                  setCurrentModel(newModel: 'gemini-1.5-flash-latest-vision'),
              apiKey: ApiService.aPIkey);
    }
    notifyListeners();
  }
  catch(e)
  {
    print('error settting the model:$e');
  }
  }
  
//set current page index
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  //set current chat id
  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  //set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  //delete chat from chathitory screen
Future<void> deleteChat({required String chatId}) async {
  final boxName = '${Constants.chatMessageBox}$chatId';

  try {
    // Open the box if it is not already open
    final chatBox = Hive.isBoxOpen(Constants.chatMessageBox)
        ? Hive.box(boxName)
        : await Hive.openBox(Constants.chatMessageBox);

    // Delete all messages in the box
    await chatBox.clear();

    // Close the box
    await chatBox.close();

    // Check if the current chat ID matches the deleted chat
    if (currentChatId.isNotEmpty && currentChatId == chatId) {
      // Reset the current chat ID and clear in-chat messages
      setCurrentChatId(newChatId: '');
      _inChatMessages.clear();
      notifyListeners();
    }
  } catch (e) {
    // Handle and log any errors
    print('Error deleting chat for chatId "$chatId": $e');
    throw Exception('Failed to delete chat. Please try again.');
  }
}
  //prepare chat
  Future<void> prepareChat({
    required bool isnewChat,
    required String chatId,
  })async{
    if (!isnewChat) {
      //load chat messages from the DB
      final chatHistory = await loadMessagesFromDB(chatId: chatId);

      //clear the inchatmessages
      _inChatMessages.clear();

      for(var message in chatHistory){
        _inChatMessages.add(message);
      }

      //set current chat id
      setCurrentChatId(newChatId: chatId);
    }else{
      //clear the in chat messages
      _inChatMessages.clear();

      //set the current chat id
      setCurrentChatId(newChatId: chatId);
    }
  }

  //send messgae to gemini and get the streamed response
  Future<void> SendMessages({
    required String message,
    required bool isTextOnly,
  }) async {
    //set the model
    await setModel(isTextOnly: isTextOnly);

    //set loading
    setLoading(value: true);

    //get the chatId
    String chatId = getChatId();

    //list of history messages
    List<Content> history = [];

    //get the chat history
    history = await getHistory(chatId: chatId);

    //get the image urls
    List<String> imageUrls = getImageUrls(isTextOnly: isTextOnly);

    // //user message Id
    // final userMessageId = const Uuid().v4();
    //open the messages box
    final messageBox = await Hive.openBox('${Constants.chatMessageBox}$chatId');

    log('messageslength: 4{messagesBox.keys.length}');

    //get the user last message Id
    final userMessageId = messageBox.keys.length;

    //model message Id
    final assistantMessageId = messageBox.keys.length +1 ;

    log('userMessageId:$userMessageId');

    log('Model: $assistantMessageId');

  
    //user message
    final userMessage = Message(
      messageid: userMessageId.toString(),
      chatid: chatId,
      role: Role.user,
      message: StringBuffer(message),
      imageUrls: imageUrls,
      timeSent: DateTime.now(),
    );

    // Debug Log
    log("User Message Created: ${userMessage.message.toString()}");

    //add this message to the list on inchatmessages
    _inChatMessages.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    //send the message to the model and wait for response
    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMessage: userMessage,
      modelMessageId: assistantMessageId.toString(),
      messageBox: messageBox,
    );
  }

  //send the message to the model and wait for response
  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMessage,
    required String modelMessageId,
     required Box messageBox,
  }) async {
    //start the chat session - only send the history of text
    final chatSession = _model!.startChat(
      history: history.isEmpty || isTextOnly ? null : history,
    );

    //get content
    final content = await getContent(message: message, isTextOnly: isTextOnly);

    //assistant message Id
    final assistantMessageId = const Uuid().v4();

    //assistant message
    final assistantMessage = userMessage.copywith(
      messageid: assistantMessageId,
      role: Role.assistant,
      message: StringBuffer(),
      timeSent: DateTime.now(),
    );

    //add this message to the list on inChatMessages
    _inChatMessages.add(assistantMessage);
    notifyListeners();

    //wait for stream response
    chatSession.sendMessageStream(content).asyncMap((event) {
      return event;
    }).listen((event) {
      _inChatMessages
          .firstWhere((element) =>
              element.messageid == assistantMessage.messageid &&
              element.role.name == Role.assistant.name)
          .message
          .write(event.text);

      // Debug Log
      log("Assistant Response Stream: ${assistantMessage.message.toString()}");
      notifyListeners();
    }, onDone: () async {
      //save message to hive DB
      await saveMessagesToDB(
          chatID: chatId,
          userMessage: userMessage,
          assistantMessage: assistantMessage,
          messageBox:messageBox,
          );
          

      //set loading to false
      setLoading(value: false);
    }).onError((erro, stackTrace) {
      //set loading
      setLoading(value: false);
    });
  }

  //save messages to hive DB
  Future<void> saveMessagesToDB({
    required String chatID,
    required Message userMessage,
    required Message assistantMessage, 
    required Box messageBox,
  }) async {
    // //open the messages box
    // final messageBox = await Hive.openBox('${Constants.chatMessageBox}$chatID');

    //save the user messages
    await messageBox.add(userMessage.toMap());

    //save the assistant messages
    await messageBox.add(assistantMessage.toMap());

    //save the chat History
    final chatHistoryBox = Boxes.getChatHistory();

    final chatHistory = ChatHistory(
        chatId: chatID,
        prompt: userMessage.message.toString(),
        response: assistantMessage.message.toString(),
        imagesUrls: userMessage.imageUrls,
        timestamp: DateTime.now(),
        role: Role.user);

    await chatHistoryBox.put(chatID, chatHistory);
    print('Chat history saved: ${chatHistory.prompt} - ${chatHistory.response}');

    //close the box
    await messageBox.close();
  }

  //get content method
  Future<Content> getContent(
      {required message, required bool isTextOnly}) async {
    if (isTextOnly) {
      //generate text from text-only input
      return Content.text(message);
    } else {
      //generate image from text and image input
      final imageFutures = _imagesFileList
          ?.map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);

      final imageBytes = await Future.wait(imageFutures!);

      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();

      return Content.multi([prompt, ...imageParts]);
    }
  }

  //List to get the image urls
  List<String> getImageUrls({required bool isTextOnly}) {
    List<String> imageUrls = [];
    if (!isTextOnly && imagesFileList != null) {
      for (var image in imagesFileList!) {
        imageUrls.add(image.path);
      }
    }
    return imageUrls;
  }

  //Method to get the chat history
  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];
    if (currentChatId.isNotEmpty) {
      await setinChatMessages(chatId: chatId);

      for (var message in inChatMessages) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }
    return history;
  }

  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

  //init hive box
  static initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    // Register the custom RoleAdapter
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(RoleAdapter());
    }
//register adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(RoleAdapter());
    }

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());

      //open chat histroy box
      //await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    final chatHistoryBox =await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    print('Chat history box opened: ${chatHistoryBox.isOpen}');

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      //await Hive.openBox<ChatHistory>(Constants.userBox);
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      //await Hive.openBox<Settings>(Constants.settingsBox);
    }
    // Open the boxes after registering adapters
    await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    await Hive.openBox<UserModel>(Constants.userBox); 
    await Hive.openBox<Settings>(Constants.settingsBox); // Assuming you have this box
  }
}
