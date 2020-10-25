import 'package:flutter/material.dart';
import 'package:vk_papers/VK api/VKController.dart';
import 'package:vk_papers/functions/LocalData.dart';
import 'package:vk_papers/functions/swipe.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'LoginScreen.dart';
import 'package:vk_papers/functions/Token.dart' as Token;

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
  String avatar = "";

  void onLoad(BuildContext context) async {
    await vk.init();
    username = await vk.user.username();
    avatar = await vk.user.getProfilePic_100();

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
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: avatar == ""
                            ? AssetImage("assets/temp.png")
                            : NetworkImage(avatar),
                        fit: BoxFit.cover),
                  ),
                ),
                Container(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FlatButton(
                      child: Text("Редактировать избранные списки"),
                      onPressed: () {},
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                    FlatButton(
                      child: Text("Сбросить списки"),
                      onPressed: () async {
                        await clearCategories();
                      },
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                    FlatButton(
                      child: Text("Настроить напоминания"),
                      onPressed: () {},
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                    FlatButton(
                      child: Text("Настройка оформления"),
                      onPressed: () {},
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                    FlatButton(
                      child: Text("Связаться с разработчиком"),
                      onPressed: () {},
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                    FlatButton(
                      child: Text("Сделать отзыв"),
                      onPressed: () {},
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                    FlatButton(
                      child: Text("Выйти из аккаунта"),
                      onPressed: () async {
                        CookieManager cookie = new CookieManager();
                        cookie.clearCookies();
                        Token.clearToken();

                        await Navigator.of(context)
                            .push(GoTo(SettingsScreen(), left: true));
                      },
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                  ],
                ))
              ]))),
    );
  }
}
