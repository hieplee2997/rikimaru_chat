import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/models/call_modal.dart';
import 'package:rikimaru_chat/models/conversation_model.dart';
import 'package:rikimaru_chat/models/user_model.dart';
import 'package:rikimaru_chat/models/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier {
  late PhoenixChannel _channel;
  late PhoenixSocket _socket;

  PhoenixChannel get channel => _channel;
  PhoenixSocket get socket => _socket;

  String _token = "";
  DateTime? _expire;
  String _userId = "";

  String get token => _token;
  String get userId => _userId;

  bool get isAuth {
    bool isExpire = _expire != null && _expire!.isBefore(DateTime.now()) && _token != "";
    if (_token == "" || isExpire) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> connectSocket(BuildContext context) async {
    _socket = PhoenixSocket('ws://192.168.204.162:4000/socket/websocket');
    await _socket.connect();
    _channel = _socket.channel('user:$_userId');
    var channel = _channel;
    channel.join()?.receive("ok", (response) => {
      _channel = channel,
      log("Channel connected"),
      Provider.of<Conversation>(context, listen: false).getDataConversation(_token),
      Provider.of<User>(context, listen: false).fetchMe(token),
    }).receive("error", (response) => {
      log("Unable join channel")
    });
    channel.on("create_conversation", (data, ref, joinRef) {
      // print(data);
      Provider.of<Conversation>(context, listen: false).getDataConversation(token);
    });
    channel.on("broadcast_new_message", (data, ref, joinRef) {
      // print(data);
      Provider.of<Conversation>(context, listen: false).onMessage(data!["data"]);
    });
    channel.on("update_info_friend", (data, ref, joinRef) {
      Provider.of<User>(context, listen: false).updateInfoFriend(data!);
      Provider.of<Conversation>(context, listen: false).updateConversation(data);
    });
    channel.on("call", (data, ref, joinRef) {
      Provider.of<Calls>(context, listen: false).onMessage(data, context);
    });
  }
  Future<bool> loginWithPassword(String userName, String password) async {
    final url = Uri.parse("${Utils.apiUrl}/users/login");

    try {
      final response = await http.post(url,
        headers: Utils.headers,
        body: json.encode({
          'userName': userName,
          'password': password
        })
      );

      final resData = json.decode(response.body);
      log(resData['message'].toString());

      if (resData['success'] == false) {
        throw HttpException(resData['message']);
      }
      _token = resData['access_token'];
      _userId = resData['data']['id'].toString();
      _expire = DateTime.fromMillisecondsSinceEpoch(
        resData['expire_in'] * 1000
      );

      final preferrence = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'user_id': _userId,
        'expire': _expire!.toIso8601String()
      });

      preferrence.setString('userData', userData);
      notifyListeners();
      return true;
      
    } catch (e) {
      print(e.toString());
      // log(trace.toString());
      return false;
    }
  }
 
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    log("Try auto login");
    // await Future.delayed(const Duration(seconds: 2));
    final userData = json.decode(prefs.getString('userData')!);
    _token = userData['token'].toString();
    _userId = userData['user_id'].toString();
    _expire = DateTime.parse(userData['expire'].toString());
    notifyListeners();
    return true;
  }

  Future<Map<String, dynamic>> createAccount(String displayName, String username, String password) async {
    final url = Uri.parse("${Utils.apiUrl}/users/register");

    try {
      final response = await http.post(url,
        headers: Utils.headers,
        body: json.encode(
          {
            'displayName': displayName,
            'userName': username,
            'password': password
          }
        )
      );

      final resData = json.decode(response.body);
      if (resData['success'] == false) {
        throw resData['message'];
      }
      return {'ok': true, 'message': resData['message']};
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
      return {'ok': false, 'message': e.toString()};
    }
  }
  Future<void> logout() async {
    try {
      try {
        _socket.disconnect();
        _channel.leave();
      } catch (e) {
        log(e.toString());
      }
      _token = "";
      _expire = null;
      _userId = "";
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
    } catch (e) {
      log(e.toString());
    }
  }
}