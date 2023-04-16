import 'dart:convert';

import 'package:ecjtu_library/constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateUtil extends GetxController {
  // 本地存储
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late Map loginForm;
  List likeSeat = [];
  String link = '';
  String cookie = '';
  String signLink = '';
  var hasLoginForm = false.obs;
  getLocalForm() async {
    var prefs = await _prefs;
    String? form = prefs.getString(USER_PATH);
    if (form == null) {
      return null;
    }
    Map loginForm = jsonDecode(form);
    this.loginForm = loginForm;
    return loginForm;
  }

  setLocalForm(String value) async {
    loginForm = jsonDecode(value);
    var prefs = await _prefs;
    prefs.setString(USER_PATH, value);
    hasLoginForm(true);
  }

  getLikeSeat() async {
    var prefs = await _prefs;
    // print(prefs.getString(LIKE_SEAT_PATH));
    likeSeat = jsonDecode(prefs.getString(LIKE_SEAT_PATH) ?? '');
  }

  setLikeSeat() async {
    var prefs = await _prefs;
    // print(jsonEncode(likeSeat));
    prefs.setString(LIKE_SEAT_PATH, jsonEncode(likeSeat));
  }

  @override
  void onInit() {
    getLocalForm().then((value) {
      if (value != null && value != {}) {
        hasLoginForm(true);
      }
      loginForm = value ?? {};
    });
    getLikeSeat();
    super.onInit();
  }
}
