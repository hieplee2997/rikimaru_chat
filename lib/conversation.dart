import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/cache_avatar.dart';
import 'package:rikimaru_chat/models/auth_model.dart';
import 'package:rikimaru_chat/models/conversation_model.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({Key? key, required this.id, this.name, this.avatarUrl}) : super(key: key);
  final id;
  final name;
  final avatarUrl;
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  String conversationId = "";
  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final token = Provider.of<Auth>(context, listen: false).token;
    conversationId = widget.id;
    final dataMessageLength = Provider.of<Conversation>(context, listen: false).messages.lastWhere((element) => element["conversation_id"] == conversationId, orElse: () => {'conversation_id': '', 'messages': []})["messages"].length;
    if (dataMessageLength == 0) Provider.of<Conversation>(context, listen: false).loadMessages(conversationId, token);
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.extentAfter < 20) {
      List dataMessages = Provider.of<Conversation>(context, listen: false).messages;
      final indexConversationMessage = dataMessages.indexWhere((element) => element["conversation_id"] == conversationId);
      List messagesConversation = dataMessages[indexConversationMessage]["messages"];
      final lastMessage = messagesConversation.last;
      final lastMessageId = lastMessage["id"];
      final token = Provider.of<Auth>(context, listen: false).token;
      Provider.of<Conversation>(context, listen: false).loadMoreMessage(conversationId, lastMessageId, token);
    }
  }

  void createMessage() async {
    String message = textEditingController.text.trim();
    final token = Provider.of<Auth>(context, listen: false).token;
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final conversation = Provider.of<Conversation>(context, listen: false).data.firstWhere((element) => element["conversation_id"] == conversationId);
    List users = conversation["users"];
    final friendId = users.firstWhere((element) => element["user_id"] != userId)["user_id"];
    conversationId = await Provider.of<Conversation>(context, listen: false).handleSendMessage(message, conversationId, friendId, token);
    textEditingController.clear();
    scrollController.animateTo(0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeOutCirc);
  }
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Conversation>(context, listen: true).messages.lastWhere((element) => element["conversation_id"] == conversationId, orElse: () => {'conversation_id': '', 'messages': []});
    // print(data);
    final messages = data["messages"];
    return Scaffold(
      body: SafeArea(
        maintainBottomViewPadding: true,
        top: false,
        bottom: false,
        child: Material(
          child: Padding(
            padding: EdgeInsets.only(top: Platform.isIOS ? 70.0 : 20),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    // color: Colors.blueAccent
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.keyboard_arrow_left, size: 30,),
                        ),
                      ),
                      CachedAvatar(widget.avatarUrl, name: widget.name, height: 50, width: 50),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.name, style: const TextStyle(fontSize: 20, color: Colors.black)),
                            const SizedBox(height: 5),
                            const Text("Status", style: TextStyle(color: Colors.grey))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white
                    ),
                    child: ListView.builder(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      controller: scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final userId = Provider.of<Auth>(context, listen: false).userId;
                        final isMe = userId == messages[index]["user_id"];
                        bool checkIsBounded = false;
                        bool checkIsFirst = false;
                        bool checkIsLast = false;
                        bool checkIsSingle = false;
                        if (index == 0) checkIsLast = true;
                        if (index == messages.length - 1) checkIsFirst = true;
                        if (index >= 1 && index < messages.length - 1) {
                          if (messages[index - 1]["user_id"] == messages[index]["user_id"] && messages[index]["user_id"] == messages[index + 1]["user_id"]) checkIsBounded = true;
                          if (messages[index - 1]["user_id"] != messages[index]["user_id"] && messages[index]["user_id"] != messages[index + 1]["user_id"]) checkIsSingle = true;
                          if ( messages[index]["user_id"] == messages[index - 1]["user_id"]) checkIsFirst = true;
                          if (messages[index + 1]["user_id"] == messages[index]["user_id"]) checkIsLast = true;
                        }
                        return Row(
                          children: [
                            if (isMe) Expanded(child: Container()),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width / 2,
                                minWidth: 0
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[100],
                                borderRadius: checkIsSingle ? BorderRadius.circular(20) 
                                : checkIsBounded ? BorderRadius.only(topLeft: Radius.circular(isMe ? 20 : 2), topRight: Radius.circular(isMe ? 2 : 20), bottomRight: Radius.circular( isMe ? 2 : 20), bottomLeft: Radius.circular(isMe ? 20 : 2))
                                : checkIsFirst ? BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomRight: Radius.circular( isMe ? 2 : 20), bottomLeft: Radius.circular(isMe ? 20 : 2)) 
                                : checkIsLast ? BorderRadius.only(topLeft: Radius.circular(isMe ? 20 : 2), topRight: Radius.circular(isMe ? 2 : 20), bottomRight: const Radius.circular(20), bottomLeft: const Radius.circular(20)) : BorderRadius.circular(20)
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("${messages[index]["message"]}", 
                                  style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 17)
                                ),
                              )
                            ),
                            if (!isMe) Expanded(child: Container())
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.grey
                  ),
                  constraints: const BoxConstraints(
                    maxHeight: 100
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Center(child: TextFormField(
                    autocorrect: false,
                    controller: textEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30)
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      suffixIcon: TextButton(child: const Icon(Icons.arrow_forward_outlined), style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)))),
                        onPressed: createMessage
                      )
                    ),
                  )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}