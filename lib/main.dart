import 'package:flutter/material.dart';

import 'package:vk_papers/screens/LoginScreen.dart';
// import 'package:vk_papers/screens/NewsScreen2.dart';
import 'package:vk_papers/screens/TESTpoll.dart';

import 'functions/Token.dart' as Token;

void main() {
  checkLogin();
}

void checkLogin() async {
  WidgetsFlutterBinding.ensureInitialized();

  String token = await Token.getToken();

  if (token != null) {
    print("logged in");
    print(token);

    runApp(MaterialApp(home: TESTpoll(), debugShowCheckedModeBanner: false));
  } else {
    print("no token");
    runApp(MaterialApp(home: LoginScreen(), debugShowCheckedModeBanner: false));
  }
}
