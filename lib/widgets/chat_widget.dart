import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_gpt/constants/constant.dart';
import 'package:chat_gpt/models/chat_model.dart';
import 'package:chat_gpt/services/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key, required this.chatModel});

  final ChatModel chatModel;
  // final String msg;
  // final String chatModel.chatIndex;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: chatModel.chatIndex == 'user'
              ? scaffoldBackgroundColor
              : cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  chatModel.chatIndex == 'user'
                      ? AssetsManager.userImage
                      : AssetsManager.openAiLogo,
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 8),
                if (chatModel.isImage != null)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(chatModel.msg!)),
                  )
                else
                  Expanded(
                    child: chatModel.chatIndex == 'user'
                        ? TextWidget(
                            label: chatModel.msg,
                          )
                        : DefaultTextStyle(
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                            child: AnimatedTextKit(
                                isRepeatingAnimation: false,
                                displayFullTextOnTap: true,
                                totalRepeatCount: 1,
                                animatedTexts: [
                                  TyperAnimatedText(chatModel.msg.trim()),
                                ]),
                          ),
                  ),
                chatModel.chatIndex == 'user'
                    ? const SizedBox.shrink()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.thumb_up_alt_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.thumb_down_alt_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget(
      {super.key,
      required this.label,
      this.fontSize = 18,
      this.color,
      this.fontWeight});

  final String label;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
          color: color ?? Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w500),
    );
  }
}
