import 'dart:math';

import 'package:hive/hive.dart';

class Utils {
  static String? _deviceId;
  static const headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8'
  };
  static const apiUrl = "http://192.168.204.162:4000/api";
  
  static checkedTypeEmpty(data) {
    if (data == "" || data == null || data == false || data == 'false') {
      return false;
    } else {
      return true;
    }
  }

  static getDeviceId() async {
    if (Utils.checkedTypeEmpty(_deviceId)) return _deviceId;
    var box = await Hive.openBox('pairKey');
    _deviceId = await box.get("deviceId");
    return _deviceId;
  }

  static initPairKeyBox() async {
    var boxKey  = await Hive.openBox("pairKey");
    var deviceId = await boxKey.get('deviceId');
    // gen new Curve25519
    if (deviceId == null){
      var newId  = "v2_" + Utils.getRamdomString(50);
      await boxKey.put("deviceId", newId);
    }
  }

  static getRamdomString(int length){
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static getRamdomNumber(length){
    const _chars = '1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

}