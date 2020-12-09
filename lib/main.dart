import 'package:flutter/material.dart';

import 'functions/Timers.dart';
import 'functions/Token.dart' as Token;
import 'notifyTest.dart';
import 'screens/LoginScreen.dart';
import 'screens/ShowCategoriesScreen.dart';
import 'screens/WaitForNewsScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkLogin();
}

void checkLogin() async {
  runApp(MaterialApp(home: NotifyTest()));
  String token = await Token.getToken();

  // // DateTime dt1 = new DateTime(2020, 11, 30);
  // // DateTime dt2 = new DateTime(2020, 12, 1);

  // // print(dt2.difference(dt1).inDays);

  // print(token != null ? "successfully logged in" : "no token");

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
