import 'dart:developer';

import 'package:chat_gpt/services/api_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  late SpeechToText speechToText;
  late FlutterTts textToSpeech;
  bool isSpeeking = false;
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
    return result.recognizedWords;
  }
}
