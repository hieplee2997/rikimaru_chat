import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/models/conversation_model.dart';

import 'chat_item.dart';
import 'models/user_model.dart';

class ChatList extends StatefulWidget {
  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    final listConversation = Provider.of<Conversation>(context, listen: true).data;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(children: [
          const Expanded(child: Text("Recent chats", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w800),)),
          TextButton(onPressed: (){}, child: Row(children: const [
            Icon(Icons.add),
            Text("New message")
          ]))
        ]),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20)
        ),
        margin: const EdgeInsets.symmetric(horizontal: 70),
        padding: const EdgeInsets.all(5.0),
        child: Row(children: [
          Expanded(
            child: ClipRRect(
              child: TextButton(onPressed: (){}, child: const Text("Chats"), style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.white
              ),),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Expanded(
            child: Container(child: TextButton(onPressed: (){}, child: const Text("Groups")),
              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(15)),
              padding: EdgeInsets.zero,
            ),
          )
        ],),
      ),
      Expanded(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: listConversation.map<Widget>((conversation){
              return ChatItem(conversation: conversation);
            }).toList(),
          ),
        ),
      ),
    ]);
  }
}