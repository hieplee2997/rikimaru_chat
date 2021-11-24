import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rikimaru_chat/models/message_conversation_services.dart';
import 'package:rikimaru_chat/models/utils.dart';


class Conversation extends ChangeNotifier {
  List _data = [];
  List _messages = [];

  List get data => _data;
  List get messages => _messages;

  set data(data) => _data = data;
  set messages(messages) => _messages = messages;

  Future<void> getDataConversation(String token) async {
    final url = Utils.apiUrl + "/users/conversation?token=$token";
    try {
      final resp = await http.get(Uri.parse(url));
      final resData = json.decode(resp.body);
      if (resData["success"]) {
        _data = resData["data"];
        for (var element in _data) {
          if (_messages.indexWhere((e) => e["conversation_id"] == element["conversation_id"]) == -1) {
            _messages.add({
              'conversation_id': element["conversation_id"],
              'messages': [],
              'status': ConversationStatus.created,
              'queue': Scheduler()
            });
          }
        }
      } else {
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<String> createConversation(String friendId, String conversationIdDummy, String token) async {
    final url = Utils.apiUrl + "/users/conversation/create_conversation?token=$token";
    try {
      final response = await http.post(Uri.parse(url), 
        headers: Utils.headers,
        body: json.encode({
          'friend_id': friendId
        })
      );
      final resData = json.decode(response.body);
      if (resData["success"]) {
        _messages.removeWhere((element) => element["conversation_id"] == conversationIdDummy);
        final conversationId = resData["conversation_id"];
        _messages.add({
          'conversation_id': conversationId,
          'messages': [],
          'status': ConversationStatus.created,
          'queue': Scheduler()
        });
        return conversationId;
      }
    } catch (e) {
      log(e.toString());
    }
    return "";
  }

  Map selectConversation(List users) {
    String idConversationDummy = MessageConversationServices.shaString(users.map((e) => e["user_id"]).toList());
    int indexConversation;
    indexConversation = _data.indexWhere((element) {
      // print(MessageConversationServices.shaString((element["users"] as List).map((e) => e["user_id"]).toList()));
      // print(idConversationDummy);
      return MessageConversationServices.shaString((element["users"] as List).map((e) => e["user_id"]).toList()) == idConversationDummy;
    });
    if (indexConversation == -1) {
      // print("fdsfdsfdsf");
      var conversationDummy = {
        "conversation_id": idConversationDummy,
        "type": "direct",
        "inserted_at": DateTime.now().toString(),
        "update_by_message": DateTime.now().toString(),
        "users": users,
        "seen": true
      };
      _data = [conversationDummy as dynamic] + _data;
      var messageConversationDummy = {
        "conversation_id": idConversationDummy,
        "messages": [],
        "status": ConversationStatus.init,
        "queue": Scheduler()
      };
      _messages = [messageConversationDummy as dynamic] + _messages;
      return conversationDummy;
    }
    return _data[indexConversation];
  }

  Future<void> loadMessages(String conversationId, String token) async {
    final indexConversationMessage = _messages.indexWhere((element) => element["conversation_id"] == conversationId);
    // print(_messages);
    // print(conversationId);
    if (indexConversationMessage == -1) return;
    if (_messages[indexConversationMessage]["status"] == ConversationStatus.init) return;
    final url = Utils.apiUrl + "/users/conversation/load_messages?token=$token&conversation_id=$conversationId";
    try {
      final resp = await http.get(Uri.parse(url));
      final resData = json.decode(resp.body);

      if (resData["success"]) {
        final messageLoaded = {
          'conversation_id': conversationId,
          'messages': resData["data"]["messages"]
        };
        if (indexConversationMessage != -1) {
          _messages[indexConversationMessage]= messageLoaded;
        } else {
          _messages.add(messageLoaded);
        }
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> handleSendMessage(String message, String conversationId, String friendId, String token) async {
    final conversationMessage = _messages.firstWhere((element) => element["conversation_id"] == conversationId);
    if (conversationMessage["status"] == ConversationStatus.init) {
      var conversationIdDummy = conversationId;
      conversationId = await createConversation(friendId, conversationIdDummy, token);
    }
    createMessage(message, conversationId, token);
    return conversationId;
  }

  Future<void> createMessage(String message, String conversationId, String token) async {
    final url = Utils.apiUrl + "/users/conversation/create_message?token=$token";
    try {
      final resp = await http.post(Uri.parse(url),
        headers: Utils.headers,
        body: json.encode({
          'messages': [message],
          'conversation_id': conversationId
        })
      );
      // final resData = json.decode(resp.body);
      // if (resData["success"]) {
      //   final indexConversation = _messages.indexWhere((element) => element["conversation_id"] == conversationId);
      //   if (indexConversation != -1) {
      //     final _conversation = _messages[indexConversation];
      //     final indexMessage = (_conversation["messages"] as List).indexWhere((element) => element["id"] == resData["data"]["id"]);
      //     if (indexMessage == -1) {
      //       final messageAdd = {
      //         'user_id': userId,
      //         'message': message,
      //         'id': resData['id'],
      //         'time': resData['current_time']
      //       };
      //       _conversation["messages"] = [messageAdd as dynamic] + _conversation["messages"];
      //       _messages[indexConversation] = _conversation;
      //       notifyListeners();
      //     }
      //   }
      //   else {
      //     // ignore: avoid_print
      //     print("Conversation không tồn tạisss");
      //   }
      // }
      notifyListeners();
    } catch (e, trace) {
      // ignore: avoid_print
      print(e.toString());
      print(trace.toString());
    }
  }

  Future<void> onMessage(List data) async {
    for (var dataIndex in data) {
      final indexConversationMessage = _messages.indexWhere((element) => element["conversation_id"] == dataIndex["conversation_id"]);
      
      if (indexConversationMessage != -1) {
        final _conversation = _messages[indexConversationMessage];
        final indexMessage = (_conversation["messages"] as List).indexWhere((element) => element["id"] == dataIndex["id"]);
        if (indexMessage == -1) {
          final messageAdd = {
            'user_id': dataIndex["user_id"],
            'message': dataIndex["message"],
            'id': dataIndex['id'],
            'current_time': dataIndex['current_time']
          };
          _conversation["messages"] = [messageAdd as dynamic] + _conversation["messages"];
          _messages[indexConversationMessage] = _conversation;
          notifyListeners();
        }
      }
    }
  }

}

enum ConversationStatus {
  init,
  creating,
  created
}