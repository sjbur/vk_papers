import 'package:flutter/material.dart';
import 'package:vk_papers/functions/Timers.dart';

import 'package:vk_papers/screens/LoginScreen.dart';
import 'package:vk_papers/screens/ShowCategoriesScreen.dart';
import 'package:vk_papers/screens/WaitForNewsScreen.dart';
import 'functions/Token.dart' as Token;

void main() {
  checkLogin();
}

void checkLogin() async {
  WidgetsFlutterBinding.ensureInitialized();

  String token = await Token.getToken();

  // DateTime dt1 = new DateTime(2020, 11, 30);
  // DateTime dt2 = new DateTime(2020, 12, 1);

  // print(dt2.difference(dt1).inDays);

  print(token != null ? "successfully logged in" : "no token");

  if (token != null && await timersExist()) {
    print("limitations: " + (await checkLimitations()).toString());
    runApp(MaterialApp(
        home: await checkLimitations()
            ? WaitForNewsScreen()
            : ShowCategoriesScreen(),
        debugShowCheckedModeBanner: false));
  } else {
    runApp(MaterialApp(home: LoginScreen()));
  }
}
