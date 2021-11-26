import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/friend_item.dart';
import 'package:rikimaru_chat/models/auth_model.dart';
import 'package:rikimaru_chat/models/user_model.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({Key? key}) : super(key: key);

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  TextEditingController textEditingController = TextEditingController();
  Future<void> addFriend() async {
    final token = Provider.of<Auth>(context, listen: false).token;
    String userName = textEditingController.text;
    String result = await Provider.of<User>(context, listen: false).addFriend(userName, token);

    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text("Message"),
        content: Text(result),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    final friendList = Provider.of<User>(context, listen: true).friendList;
    return Material(
      child: Column(
          children: [
            Center(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        constraints: const BoxConstraints(maxHeight: 60),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      controller: textEditingController,
                    ),
                  ),
                  IconButton(onPressed: addFriend, icon: const Icon(Icons.add))
                ],
              ),
            ),
            Expanded(child: SingleChildScrollView(child: Column(children: friendList.map<Widget>((e) => FriendItem(user: e)).toList()),))
          ],
        ),
    );
  }
}