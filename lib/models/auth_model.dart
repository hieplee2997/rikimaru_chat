import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:http/http.dart' as http;
import 'package:rikimaru_chat/models/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier {
  late PhoenixChannel _channel;
  late PhoenixSocket _socket;

  PhoenixChannel get channel => _channel;
  PhoenixSocket get socket => _socket;

  String _token = "";
  var _expire;
  String _userId = "";

  Future<void> connectSocket() async {
    _socket = PhoenixSocket('ws://127.0.0.1:4000/socket/websocket');
    await _socket.connect();
    _channel = _socket.channel('user:lobby');
    var channel = _channel;
    channel.join()?.receive("ok", (response) => {
      _channel = channel,
      log("Channel connected")
    }).receive("error", (response) => {
      log("Unable join channel")
    });
  }
  Future<void> loginWithPassword(String username, String password) async {

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
      log(resData['success'].toString());
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
          'expire': _expire.toIso8601String()
        }
      );
      preferrence.setString('userData', userData);
      notifyListeners();
      return true;
    } catch (e, trace) {
      log(e.toString());
      log(trace.toString());
      return false;
    }
  }
}