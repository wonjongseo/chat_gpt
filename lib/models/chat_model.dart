enum CHAT_INDEX { USER, AI }

class ChatModel {
  final String msg;
  final String chatIndex;
  bool? isImage = false;
  ChatModel({required this.msg, required this.chatIndex, this.isImage});

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
    return 'ChatModel(msg: $msg, isImage: $isImage, chatIndex: $chatIndex)';
  }
}
