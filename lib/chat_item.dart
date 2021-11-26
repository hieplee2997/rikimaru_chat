import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/cache_avatar.dart';
import 'package:rikimaru_chat/models/auth_model.dart';
import 'package:rikimaru_chat/conversation.dart';

class ChatItem extends StatefulWidget{
  const ChatItem({Key? key, required this.conversation}) : super(key: key);

  final dynamic conversation;
  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {

  String getFieldNameConversation(List user) {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    var result = "";
    result = user.lastWhere((user) => user["user_id"] != userId)["full_name"].toString();
    return result;
  }

  String getFieldAvatarConversation(List user) {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    var result = "";
    result = user.lastWhere((user) => user["user_id"] != userId)["avatar_url"] ?? "";
    return result;
  }

  getFriendConversation(List user) {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    var result = user.lastWhere((user) => user["user_id"] != userId);
    return result;
  }

  selectConversation(dynamic conversation) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, a1, a2) {
        return ConversationScreen(id: conversation["conversation_id"], name: getFieldNameConversation(conversation["users"]), avatarUrl: getFieldAvatarConversation(conversation["users"]));
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => selectConversation(widget.conversation),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 2.2, offset: const Offset(2.0, 2.0), color: Colors.grey[200]!)],
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 0.5, color: Colors.grey)
        ),
        child: Row(children: [
          CachedAvatar(getFieldAvatarConversation(widget.conversation["users"]),name: getFieldNameConversation(widget.conversation["users"]), height: 50, width: 50),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(children: [
              Text(getFieldNameConversation(widget.conversation["users"]), style: const TextStyle(fontSize: 16.0,fontWeight: FontWeight.w800)),
              const Text('last message')
            ], crossAxisAlignment: CrossAxisAlignment.start),
          )
        ]),
      ),
    ); 
  }
}