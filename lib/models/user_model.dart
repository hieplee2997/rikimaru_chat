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
  Future<void> uploadAvatar(Map file, String token) async {
    const url = "https://chat.pancake.vn/api/business/contents?key=VewnQ1l0HPa3zYa4/QeCLIJUs5fxw3Ex26JgmnfIbCo=";
    try {
      final resp = await http.post(Uri.parse(url),
        headers: Utils.headers,
        body: json.encode(file)
      );
      final resData = json.decode(resp.body);
      _me["avatar_url"] = resData["content_url"];
      updateUserInfo(token);
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
  void changeUsername(String username, String token){
    _me["user_name"] = username;
    updateUserInfo(token);
    notifyListeners();
  }
  void changeDisplayName(String displayName, String token) {
    _me["full_name"] = displayName;
    updateUserInfo(token);
    notifyListeners();
  }
  Future<void> updateUserInfo(String token) async {
    final url = Utils.apiUrl + "/users/change_user_info?token=$token";
    try {
      final resp = await http.post(Uri.parse(url),
        headers: Utils.headers,
        body: json.encode(_me)
      );
      final resData = json.decode(resp.body);
      print(resData);
    } catch (e) {
      print(e.toString());
    }
  }
  void updateInfoFriend(Map data) {
    final idFriend = data["user_id"];
    final indexFriend = _friendList.indexWhere((element) => element["user_id"] == idFriend);
    if (indexFriend != -1) {
      _friendList[indexFriend]["full_name"] = data["full_name"];
      _friendList[indexFriend]["user_name"] = data["user_name"];
      _friendList[indexFriend]["avatar_url"] = data["avatar_url"];

      notifyListeners();
    }
  }
}