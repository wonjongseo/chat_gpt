enum CHAT_INDEX { USER, AI }

class ChatModel {
  final String msg;
  final String chatIndex;

  ChatModel({required this.msg, required this.chatIndex});

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        msg: json['msg'],
        chatIndex: json['chatIndex'],
      );

  Map<String, String> objToJson() {
    return {'role': chatIndex.toString(), 'content': msg};
  }

  static List<Map<String, String>> listToJson(List<ChatModel> chatModelList) {
    return chatModelList.map((model) => model.objToJson()).toList();
  }

  @override
  String toString() {
    return 'ChatModel(msg: $msg, chatIndex: $chatIndex)';
  }
}
