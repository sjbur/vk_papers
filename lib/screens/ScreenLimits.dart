import 'package:flutter/material.dart';
import 'package:vk_papers/functions/Timers.dart';
import 'package:vk_papers/screens/ShowCategoriesScreen.dart';

import 'SetTimersScreen.dart';

class ScreenLimits extends StatefulWidget {
  @override
  _ScreenLimitsState createState() => _ScreenLimitsState();
}

class _ScreenLimitsState extends State<ScreenLimits> {
  bool limitations = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Режим контроля времени"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "По умолчанию Вам будет предложено включить функцию контроля времени, которая позволяет выставить ограничения по пребыванию в приложении, чтобы не отвлекаться на соц. сети.\nНо, если Вам это не нужно, то можете её выключить.",
            textAlign: TextAlign.center,
          ),
          SwitchListTile(
              contentPadding: EdgeInsets.all(15),
              title: Text(
                "Контроль времени ",
              ),
              value: limitations,
              onChanged: (val) => setState(() => limitations = val)),
          FlatButton(
            onPressed: () async {
              if (limitations) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SetTimersScreen(
                              firstTime: true,
                            )));
              } else {
                await noLimitationsSave();
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowCategoriesScreen()));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text("Продолжить"),
            ),
            textColor: Colors.white,
            color: Colors.lightBlue,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
          )
        ],
      ),
    );
  }
}
