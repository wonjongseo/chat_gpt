import 'dart:developer';

import 'package:chat_gpt/constants/constant.dart';
import 'package:chat_gpt/providers/chats_provider.dart';
import 'package:chat_gpt/providers/models_provider.dart';
import 'package:chat_gpt/screens/services.dart';
import 'package:chat_gpt/services/api_service.dart';
import 'package:chat_gpt/services/assets_manager.dart';
import 'package:chat_gpt/services/voice_service.dart';
import 'package:chat_gpt/widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ChatSceen extends StatefulWidget {
  const ChatSceen({super.key});

  @override
  State<ChatSceen> createState() => _ChatSceenState();
}

class _ChatSceenState extends State<ChatSceen> {
  bool _isTyping = false;
  bool _isLisitening = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  late VoiceService voiceService;
  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    voiceService = VoiceService();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.openAiLogo),
        ),
        title: const Text('Chat GPT'),
        actions: [
          IconButton(
            onPressed: () => Services.showModelSheet(context: context),
            icon: const Icon(
              Icons.more_vert_rounded,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.getChatList.length,
                itemBuilder: (context, index) {
                  return ChatWidget(
                    chatModel: chatProvider.getChatList[index],
                  );
                },
              ),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            const SizedBox(height: 15),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration.collapsed(
                          hintText: 'How can I help you',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        controller: textEditingController,
                        onSubmitted: (value) => sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider,
                            message: textEditingController.text),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider,
                              message: textEditingController.text),
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          //  _isLisitening 말하고 있다면
                          onPressed: () async {
                            if (_isTyping && !_isLisitening) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content:
                                    TextWidget(label: 'Please Wait a Minute.'),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }
                            if (voiceService.speechToText.isNotListening) {
                              setState(() {
                                _isLisitening = false;
                                return;
                              });
                            }
                            if (await voiceService.speechToText.hasPermission &&
                                voiceService.speechToText.isNotListening) {
                              setState(() {
                                _isLisitening = true;
                              });

                              await voiceService.startListening();
                            } else if (voiceService.speechToText.isListening) {
                              setState(() {
                                _isLisitening = false;
                              });
                              await voiceService.stopListening();

                              setState(() {
                                _isTyping = true;
                              });
                              print(
                                  'voiceService.lastWords: ${voiceService.lastWords}');

                              await chatProvider.sendMessageAndGetAnswer(
                                chosenModelId: '',
                                message: voiceService.lastWords,
                                isSpeak: true,
                              );
                              // await ApiService.isArtPromptApi(
                              //     message: voiceService.lastWords,
                              //     messages: chatProvider.getChatList);

                              setState(() {
                                _isTyping = false;
                              });
                            } else {
                              await voiceService.initSpeechToText();
                            }

                            setState(() {});
                          },
                          icon: _isLisitening
                              ? const Icon(
                                  Icons.stop,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.mic,
                                  color: Colors.white,
                                ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT({
    required ModelsProvider modelsProvider,
    required String message,
    required ChatProvider chatProvider,
  }) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: TextWidget(label: 'You Can not send multiple message.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: TextWidget(label: 'Please Type a message.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      setState(() {
        _isTyping = true;
        // chatProvider.addUserMessage(message: message);

        textEditingController.clear();
        focusNode.unfocus();
      });
      log('Request has been sent');

      await chatProvider.sendMessageAndGetAnswer(
        message: message,
        chosenModelId: modelsProvider.getCurrentModel,
      );

      setState(() {});
    } catch (error) {
      log('error: $error');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(label: error.toString()),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEND();
        _isTyping = false;
      });
    }
  }
}
