import 'package:chat_gpt/models/chat_model.dart';
import 'package:chat_gpt/services/api_service.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatModel> chatList = [];

  List<ChatModel> get getChatList => chatList;

  void addUserMessage({required String message}) {
    ChatModel userChatModel = ChatModel(msg: message, chatIndex: 'user');
    chatList.add(userChatModel);
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswer({
    required String message,
    required String chosenModelId,
    bool isSpeak = false,
  }) async {
    if (isSpeak) {
      await ApiService.isArtPromptApi(messages: chatList, message: message);
    } else if (chosenModelId.toLowerCase().startsWith("gpt")) {
      await ApiService.sendMessageGPT(
        messages: chatList,
        message: message,
        modelId: chosenModelId,
      );
    } else {
      await ApiService.sendMessage(
        messages: chatList,
        message: message,
        modelId: chosenModelId,
      );
    }

    notifyListeners();
  }
}
