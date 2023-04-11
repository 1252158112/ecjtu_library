import 'dart:convert';

import 'package:ecjtu_library/constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateUtil extends GetxController {
  // 本地存储
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late Map loginForm;
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

  @override
  void onInit() {
    getLocalForm().then((value) {
      if (value != null && value != {}) {
        hasLoginForm(true);
      }
      loginForm = value ?? {};
    });

    super.onInit();
  }
}
