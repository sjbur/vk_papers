import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vk_papers/functions/Timers.dart';
import 'package:vk_papers/functions/swipe.dart';
import 'package:vk_papers/screens/ShowCategoriesScreen.dart';
import 'package:vk_papers/screens/TestNewsScreen.dart';

import 'SettingsScreen.dart';

class WaitForNewsScreen extends StatefulWidget {
  @override
  _WaitForNewsScreenState createState() => _WaitForNewsScreenState();
}

class _WaitForNewsScreenState extends State<WaitForNewsScreen>
    with WidgetsBindingObserver {
  bool ready = false;

  List<Widget> readyChildren = new List<Widget>();
  List<Widget> notReadyChildren = new List<Widget>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    readyChildren.clear();
    notReadyChildren.clear();

    readyChildren.add(Center(
        child: Column(
      children: [
        Text("Пора!"),
        FlatButton(
            color: Colors.lightBlue,
            onPressed: () async {
              await accessTimer();
              await Navigator.of(context).push(GoTo(ShowCategoriesScreen()));
            },
            child: Text(
              "Приступить",
              style: TextStyle(color: Colors.white),
            ))
      ],
    )));
    notReadyChildren.addAll([
      Spacer(),
      Text(
        "Новости в пути! Когда время придет, вы увидите уведомление на своем экране телефона.",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      Spacer(),
      Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
            "Вы всегда можете настроить время для чтения, задав его в настройках.",
            textAlign: TextAlign.center),
      )
    ]);

    checkNews();
    super.initState();
  }

  checkNews() async {
    ready = await getTimerToAccess() != null ? true : false;

    // var accessedT = await getLastAccessedTimer();
    // accessedT.time.trim();
    // int h = int.parse(accessedT.time.split(":")[0]);
    // int m = int.parse(accessedT.time.split(":")[1]);
    // var curDate = new DateTime(accessedT.accessedDate.year,
    //     accessedT.accessedDate.month, accessedT.accessedDate.day, h, m);
    // print(curDate.millisecondsSinceEpoch.toString());
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await checkNews();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VK Papers"),
        actions: [
          IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () async {
                await Navigator.of(context).push(GoTo(SettingsScreen()));
              })
        ],
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ready ? readyChildren : notReadyChildren),
    );
  }
}
