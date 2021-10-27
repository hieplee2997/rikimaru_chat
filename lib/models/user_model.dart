import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rikimaru_chat/models/utils.dart';

import 'package:http/http.dart' as http;
class User extends ChangeNotifier {
  Map _me = {};
  Map? _otherUser;

  Map get me => _me;
  Map? get otherUser => _otherUser;
  
  Future<void> fetchMe(String token) async {
    final url = Utils.apiUrl + "/users/fetch_me?token=$token";
    try {
      final response = await http.get(Uri.parse(url));
      final resData = json.decode(response.body);

      if (resData['success'] == false) {
        throw HttpException(resData['message']);
      }
      _me = resData['user'];
      notifyListeners();

    } catch (e) {
      log(e.toString());
    }
  }
}