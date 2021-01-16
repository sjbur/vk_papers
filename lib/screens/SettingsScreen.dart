import 'package:flutter/material.dart';
import 'package:vk_times/functions/Timers.dart';
import 'package:vk_times/screens/ScreenLimits.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../VK api/VKController.dart';
import '../functions/swipe.dart';
import '../functions/Token.dart' as Token;

import 'LoginScreen.dart';
import 'SetTimersScreen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Настройки"),
        centerTitle: true,
      ),
      body: SettingsView(),
    );
  }
}

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  VKController vk = new VKController();
  String username = "";
  String avatar;
  bool limitsOn = false;

  List<Widget> menu = [Text("")];

  void onLoad(BuildContext context) async {
    await vk.init();
    username = await vk.user.username();

    if (username == null) {
      await Token.clearToken();
      await Navigator.of(context).pushReplacement(GoTo(LoginScreen()));
    } else {
      avatar = await vk.user.getProfilePic_100();
    }

    limitsOn = await checkLimitations();

    if (limitsOn)
      menu = [
        FlatButton(
          child: Text("Настроить напоминания"),
          onPressed: () {
            Navigator.of(context).push(GoTo(SetTimersScreen(
              firstTime: false,
            )));
          },
          color: Colors.blue,
          textColor: Colors.white,
        ),
        FlatButton(
          child: Text("Контроль времени"),
          onPressed: () {
            Navigator.of(context).push(GoTo(ScreenLimits()));
          },
          color: Colors.blue,
          textColor: Colors.white,
        ),
        FlatButton(
          child: Text("Выйти из аккаунта"),
          onPressed: () async {
            CookieManager cookie = new CookieManager();
            cookie.clearCookies();
            Token.clearToken();

            Navigator.of(context).popUntil((route) => route.isFirst);
            await Navigator.of(context).pushReplacement(GoTo(LoginScreen()));
          },
          color: Colors.blue,
          textColor: Colors.white,
        ),
      ];
    else
      menu = menu = [
        FlatButton(
          child: Text("Контроль времени"),
          onPressed: () {
            Navigator.of(context).push(GoTo(ScreenLimits()));
          },
          color: Colors.blue,
          textColor: Colors.white,
        ),
        FlatButton(
          child: Text("Выйти из аккаунта"),
          onPressed: () async {
            CookieManager cookie = new CookieManager();
            cookie.clearCookies();
            Token.clearToken();

            Navigator.of(context).popUntil((route) => route.isFirst);

            await Navigator.of(context)
                .pushReplacement(GoTo(LoginScreen(), left: true));
          },
          color: Colors.blue,
          textColor: Colors.white,
        ),
      ];

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad(context));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        int sensitivity = 3;
        if (details.delta.dx > sensitivity) {
          print("right");
          Navigator.pop(context);
          // Right Swipe
        }
      },
      child: SingleChildScrollView(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(username == "" ? "" : username,
                      style: TextStyle(
                          fontSize: 30.0, fontWeight: FontWeight.bold)),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(128),
                  child: FadeInImage(
                      fit: BoxFit.fill,
                      width: 128,
                      height: 128,
                      placeholder: AssetImage("assets/temp.png"),
                      image: avatar == null
                          ? AssetImage("assets/temp.png")
                          : NetworkImage(avatar)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 0),
                  child: Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: menu)),
                )
              ]))),
    );
  }
}
