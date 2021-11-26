import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/models/auth_model.dart';
import 'package:rikimaru_chat/models/conversation_model.dart';
import 'package:rikimaru_chat/models/user_model.dart';

import 'cache_avatar.dart';
import 'conversation.dart';

class FriendItem extends StatefulWidget {
  const FriendItem({Key? key, required this.user}) : super(key: key);

  final user;

  @override
  State<FriendItem> createState() => _FriendItemState();
}

class _FriendItemState extends State<FriendItem> {

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

  void selectConversation(user) {
    final me = Provider.of<User>(context, listen: false).me;
    final users = [me] + [user];
    final conversation =  Provider.of<Conversation>(context, listen: false).selectConversation(users);
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, a1, a2) {
        return ConversationScreen(id: conversation["conversation_id"], name: getFieldNameConversation(conversation["users"]), avatarUrl: getFieldAvatarConversation(conversation["users"]));
      }
    ));
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => selectConversation(widget.user),
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
          CachedAvatar(widget.user["avatar_url"],name: widget.user['full_name'], height: 50, width: 50),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(children: [
              Text(widget.user['full_name'], style: const TextStyle(fontSize: 16.0,fontWeight: FontWeight.w800)),
              Text(widget.user['user_name'], style: const TextStyle(fontSize: 14.0, color: Colors.grey))
            ], crossAxisAlignment: CrossAxisAlignment.start),
          )
        ]),
      ),
    ); 
  }
}