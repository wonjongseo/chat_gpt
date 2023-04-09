import 'dart:developer';

import 'package:chat_gpt/models/chat_model.dart';
import 'package:chat_gpt/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService extends ChangeNotifier {
  late SpeechToText speechToText;
  late FlutterTts textToSpeech;
  late ApiService apiService;

  String lastWords = '';
  String? generatedContent;
  String? generatedImageUrl;

  VoiceService() {
    initTextToSpeech();
    initSpeechToText();
    apiService = ApiService();
  }

  Future<void> initTextToSpeech() async {
    // await textToSpeech.setSharedInstance(true);
  }

  Future<void> systemSpeak(String content) async {
    log('systemSpeak');
    textToSpeech = FlutterTts();
    await textToSpeech.speak(content);
  }

  Future<void> onMicPress(
      {required List<ChatModel> messages, required bool isLisitening}) async {
    if (!isLisitening) {
      // if (await speechToText.hasPermission && speechToText.isNotListening) {
      await startListening();
      // } else if (speechToText.isListening) {
    } else if (isLisitening) {
      final speech = await apiService.isArtPromptApi(
          messages: messages, message: lastWords);
      print('speech: ${speech}');
      if (speech.contains('http')) {
        generatedImageUrl = speech;
        generatedContent = null;
      } else {
        generatedContent = speech;
        generatedImageUrl = null;

        // await systemSpeak(speech);
      }
      await stopListening();
    } else {
      await initSpeechToText();
    }
  }

  Future<void> initSpeechToText() async {
    log('initSpeechToText');
    speechToText = SpeechToText();
    await speechToText.initialize();
  }

  Future<void> startListening() async {
    log('startListening');
    await speechToText.listen(onResult: onSpeechResult);
  }

  Future<void> stopListening() async {
    log('stopListening');
    await speechToText.stop();
  }

  String onSpeechResult(SpeechRecognitionResult result) {
    log('onSpeechResult');
    print('result.recognizedWords: ${result.recognizedWords}');
    return result.recognizedWords;
  }
}
