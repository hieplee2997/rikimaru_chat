import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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

  bool get isAuth {
    bool isExpire = _expire != null && _expire!.isBefore(DateTime.now()) && _token != "";
    if (_token == "" || isExpire) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> connectSocket(BuildContext context) async {
    _socket = PhoenixSocket('ws://127.0.0.1:4000/socket/websocket');
    await _socket.connect();
    _channel = _socket.channel('user:lobby');
    var channel = _channel;
    channel.join()?.receive("ok", (response) => {
      _channel = channel,
      log("Channel connected"),
      Provider.of<User>(context, listen: false).fetchMe(token),
    }).receive("error", (response) => {
      log("Unable join channel")
    });
  }
  Future<bool> loginWithPassword(String userName, String password) async {
    final url = Uri.parse("http://127.0.0.1:4000/api/users/login");

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
        'userId': _userId,
        'expire': _expire!.toIso8601String()
      });

      preferrence.setString('userData', userData);
      notifyListeners();
      return true;
      
    } catch (e) {
      log(e.toString());
      // log(trace.toString());
      return false;
    }
  }
 
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final userData = json.decode(prefs.getString('userData')!);
    _token = userData['token'].toString();
    _userId = userData['userId'].toString();
    _expire = DateTime.parse(userData['expire'].toString());
    print("try auto login");
    notifyListeners();
    return true;
  }

  Future<bool> createAccount(String displayName, String username, String password) async {
    final url = Uri.parse("http://127.0.0.1:4000/api/users/register");

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
        throw HttpException(resData['message']);
      }

      _token = resData['access_token'];
      _userId = resData['data']['id'].toString();
      _expire = DateTime.fromMillisecondsSinceEpoch(
        resData['expire_in'] * 1000
      );
      final preferrence = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expire': _expire!.toIso8601String()
        }
      );
      preferrence.setString('userData', userData);
      logout();
      notifyListeners();
      return true;
    } catch (e, trace) {
      log(e.toString());
      log(trace.toString());
      return false;
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
      print("logout");
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
    } catch (e) {
      log(e.toString());
    }
  }
}