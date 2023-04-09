import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_gpt/models/chat_model.dart';
import 'package:chat_gpt/models/models_model.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {'Authorization': 'Bearer $API_KEY'},
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      // print("jsonResponse $jsonResponse");
      List temp = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        // log("temp ${value["id"]}");
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  // Send Message using ChatGPT API
  static Future<String> sendMessageGPT({
    required List<ChatModel> messages,
    required String message,
    required String modelId,
  }) async {
    try {
      log("modelId - GPT $modelId");

      List<Map<String, String>> jsonMessages = ChatModel.listToJson(messages);

      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {"model": modelId, "messages": jsonMessages},
        ),
      );

      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }
      String content = jsonResponse['choices'][0]['message']['content'];

      content = content.trim();

      messages.add(ChatModel(msg: content, chatIndex: 'assistant'));
      return content;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  // Send Message fct
  static Future<String> sendMessage({
    required List<ChatModel> messages,
    required String message,
    required String modelId,
  }) async {
    try {
      log("modelId $modelId");

      var response = await http.post(
        Uri.parse("$BASE_URL/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "prompt": message,
            "max_tokens": 300,
          },
        ),
      );
      // Map jsonResponse = jsonDecode(response.body);

      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      if (jsonResponse["choices"].length > 0) {
        String content = jsonResponse["choices"][0]['text'];
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");

        content = content.trim();

        messages.add(ChatModel(msg: content, chatIndex: 'assistant'));
        return content;
      }

      return 'An Internal error occurred.';
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  // For the user's Voice

  Future<String> isArtPromptApi(
      {required List<ChatModel> messages, required String message}) async {
    print('message: ${message}');
    message = 'What is the Flutter ? ';
    print('message: ${message}');

    messages.add(ChatModel(msg: message, chatIndex: 'user'));
    try {
      final res = await http.post(Uri.parse('$BASE_URL/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $API_KEY'
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            'messages': [
              {
                'role': 'user',
                'content':
                    'Does this message want to generate an AI picture, image, art or anything similar? $message . Simply answer with a yes or no'
              }
            ]
          }));

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        print('content: ${content}');
        ;

        content = content.trim();

        switch (content) {
          // case 'Yes':
          // case 'yes':
          // case 'Yes.':
          // case 'yes.':
          //   // final res = await dallEApi(message);
          //   return res;

          default:
            final res = await sendMessageGPT(
                message: message, messages: messages, modelId: 'gpt-3.5-turbo');
            return res;
        }
      }

      return 'An Internal error occurred.';
    } catch (e) {
      return e.toString();
    }
  }

  // Future<String> chatGpiApi(String prompt) async {
  //   messages.add({
  //     'role': 'user',
  //     'content': prompt,
  //   });
  //   try {
  //     final res = await http.post(Uri.parse('$BASE_URL/chat/completions'),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $API_KEY'
  //         },
  //         body: jsonEncode({
  //           "model": "gpt-3.5-turbo",
  //           'messages': messages,
  //         }));

  //     if (res.statusCode == 200) {
  //       print('res.body: ${res.body}');

  //       String content =
  //           jsonDecode(res.body)['choices'][0]['message']['content'];

  //       content = content.trim();

  //       messages.add({
  //         'role': 'assistant',
  //         'content': content,
  //       });

  //       return content;
  //     }

  //     return 'An Internal error occurred.';
  //   } catch (e) {
  //     return e.toString();
  //   }
  // }

  // Future<String> dallEApi(String prompt) async {
  //   messages.add({
  //     'role': 'user',
  //     'content': prompt,
  //   });
  //   try {
  //     final res = await http.post(Uri.parse(_dallEUrl),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $secretApiKey'
  //         },
  //         body: jsonEncode({
  //           'prompt': prompt,
  //           'n': 1,
  //         }));

  //     if (res.statusCode == 200) {
  //       print('res.body: ${res.body}');

  //       String imageUrl = jsonDecode(res.body)['data'][0]['url'];

  //       imageUrl = imageUrl.trim();

  //       messages.add({
  //         'role': 'assistant',
  //         'content': imageUrl,
  //       });

  //       return imageUrl;
  //     }

  //     return 'An Internal error occurred.';
  //   } catch (e) {
  //     return e.toString();
  //   }
  // }
}
