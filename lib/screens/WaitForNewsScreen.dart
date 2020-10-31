import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vk_papers/functions/Timers.dart';
import 'package:vk_papers/functions/swipe.dart';
import 'package:vk_papers/screens/SetTimersScreen.dart';
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
      FlatButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(GoTo(ShowCategoriesScreen()));
          },
          child: Text(
            "или можете почитать старое.",
            style: TextStyle(fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
          )),
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
    bool timersOK = await timersExist();
    if (!timersOK) {
      await Navigator.of(context).pushReplacement(GoTo(SetTimersScreen()));
    } else {
      ready = await getTimerToAccess() != null ? true : false;
      setState(() {});

      List<Timer> ts = await getAllTimers();

      ts.forEach((element) {
        print(element.accessedDate != null
            ? element.accessedDate.toString()
            : " not accessed");
        print(element.time.toString() + "\n");
      });
    }
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
