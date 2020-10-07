import 'package:flutter/material.dart';
//import 'package:vk_papers/screens/FinishScreen.dart';

import 'package:vk_papers/screens/LoginScreen.dart';
// import 'package:vk_papers/screens/NewsScreen.dart';
import 'package:vk_papers/screens/SetTimersScreen.dart';
import 'package:vk_papers/screens/notify.dart';
// import 'package:vk_papers/screens/SetTimersScreen.dart';

import 'functions/Token.dart' as Token;
// import 'LocalData.dart' as LocalData;

void main() {
  checkLogin();
}

void checkLogin() async {
  WidgetsFlutterBinding.ensureInitialized();

  String token = await Token.getToken();

  if (token != null) {
    print("logged in");
    print(token);

    runApp(MaterialApp(
        home: SetTimersScreen(), debugShowCheckedModeBanner: false));
  } else {
    print("no token");
    runApp(MaterialApp(home: LoginScreen(), debugShowCheckedModeBanner: false));
  }
}
