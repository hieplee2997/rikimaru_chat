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
    return SafeArea(
      maintainBottomViewPadding: true,
      top: false,
      bottom: false,
      child: Material(
        child: Padding(
          padding: const EdgeInsets.only(top: 70.0),
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
                    CachedAvatar(widget.avatarUrl,name: widget.name, height: 50, width: 50),
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
                    key: const PageStorageKey<String>('controllerA'),
                    controller: scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final userId = Provider.of<Auth>(context, listen: false).userId;
                      final isMe = userId == messages[index]["user_id"];
                      return Row(
                        children: [
                          if (isMe) Expanded(child: Container()),
                          Container(color: Colors.green[100], margin: const EdgeInsets.symmetric(horizontal: 5), height: 40, child: Text("$index ${messages[index]["message"]}", style: TextStyle(color: !isMe ? Colors.red : Colors.blue))),
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
    );
  }
}