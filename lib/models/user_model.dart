import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rikimaru_chat/models/utils.dart';

import 'package:http/http.dart' as http;
class User extends ChangeNotifier {
  Map _me = {'full_name': '', 'user_name': '', 'user_id': ''};
  Map? _otherUser;
  List _friendList = [];

  Map get me => _me;
  Map? get otherUser => _otherUser;
  List get friendList => _friendList;
  
  Future<void> fetchMe(String token) async {
    final url = Utils.apiUrl + "/users/fetch_me?token=$token";
    try {
      final response = await http.get(Uri.parse(url));
      final resData = json.decode(response.body);

      if (resData['success'] == false) {
        throw HttpException(resData['message']);
      }
      _me = resData['user'];
      _friendList = resData['friends'];
      log(resData.toString());
      notifyListeners();

    } catch (e) {
      log(e.toString());
    }
  }
  Future<String> addFriend(String userName, String token) async {
    final url = Utils.apiUrl + "/users/add_friend?token=$token";
    try {
      final response = await http.post(Uri.parse(url),
        headers: Utils.headers,
        body: json.encode({
          'user_name': userName
        })
      );
      final resData = json.decode(response.body);
      if (resData['success'] == false) {
        throw resData['message'];
      }
      
      Map _friend = resData['friend'];
      if (!_friendList.contains(_friend)) {
        _friendList.add(_friend);
        notifyListeners();
        return "Kết bạn thành công";
      } else {
        return "Người này đã là bạn bè";
      }
      
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }
}