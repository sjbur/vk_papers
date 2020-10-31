import 'package:flutter/material.dart';

import 'package:vk_papers/screens/LoginScreen.dart';
import 'package:vk_papers/screens/WaitForNewsScreen.dart';
import 'functions/Token.dart' as Token;

void main() {
  checkLogin();
}

void checkLogin() async {
  WidgetsFlutterBinding.ensureInitialized();

  String token = await Token.getToken();

  print(token != null ? "successfully logged in" : "no token");
  runApp(MaterialApp(
      home: token != null ? WaitForNewsScreen() : LoginScreen(),
      debugShowCheckedModeBanner: false));
}
