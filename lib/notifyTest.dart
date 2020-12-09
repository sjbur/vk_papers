import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vk_papers/screens/WaitForNewsScreen.dart';
import 'timepicker/flutter_datetime_picker.dart';

import 'functions/Timers.dart';
import 'functions/swipe.dart';

import 'screens/FinishScreen.dart';

class NotifyTest extends StatefulWidget {
  const NotifyTest({Key key}) : super(key: key);

  @override
  _NotifyTestState createState() => _NotifyTestState();
}

class _NotifyTestState extends State<NotifyTest> {
  // List<String> timers = new List<String>();
  // FlutterLocalNotificationsPlugin fltrNotification =
  //     new FlutterLocalNotificationsPlugin();
  // bool allowToNotify = false;

  // Future initNotifications() async {
  //   var androidInitilize = new AndroidInitializationSettings('app_icon');
  //   var iOSinitilize = new IOSInitializationSettings();
  //   var initilizationsSettings =
  //       new InitializationSettings(androidInitilize, iOSinitilize);
  //   fltrNotification = new FlutterLocalNotificationsPlugin();
  //   fltrNotification.initialize(initilizationsSettings,
  //       onSelectNotification: (payload) =>
  //           Navigator.of(context).pushReplacement(GoTo(WaitForNewsScreen())));
  // }

  // Future makeNotifications(String message, String subtext) async {
  //   var androidDetails = new AndroidNotificationDetails(
  //       "VK Papers", "Sj Bur", "news arrived",
  //       importance: Importance.Max);
  //   var iSODetails = new IOSNotificationDetails();
  //   var generalNotificationDetails =
  //       new NotificationDetails(androidDetails, iSODetails);

  //   List<Timer> savedTimers = await getAllTimers();

  //   await fltrNotification.cancelAll();

  //   savedTimers.forEach((element) {
  //     String textTime = element.time;
  //     textTime = textTime.trim();

  //     Time time = Time(int.parse(textTime.split(":")[0].toString()),
  //         int.parse(textTime.split(":")[1].toString()), 0);

  //     fltrNotification.showDailyAtTime(
  //         0, message, subtext, time, generalNotificationDetails);
  //   });
  // }

  void load() async {
    // if (await timersExist() && await checkLimitations()) {
    //   List<Timer> userTimers = await getAllTimers();

    //   await initNotifications();

    //   setState(() {
    //     allowToNotify = true;

    //     userTimers.forEach((element) {
    //       timers.add(element.time);

    //       timers.sort((a, b) => (int.parse(a.split(":")[0])
    //           .compareTo(int.parse(b.split(":")[0]))));
    //     });
    //   });
    // }
  }

  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Таймеры"),

        //   actions: allowToNotify
        //       ? [
        //           IconButton(
        //               icon: Icon(
        //                 Icons.add,
        //                 color: Colors.white,
        //               ),
        //               onPressed: () {
        //                 DatePicker.showTimePicker(context,
        //                     showSecondsColumn: false,
        //                     theme: DatePickerTheme(
        //                       containerHeight: 210.0,
        //                     ),
        //                     showTitleActions: true,
        //                     onConfirm: (time) => setState(() {
        //                           timers.add(time.hour.toString() +
        //                               ":" +
        //                               time.minute.toString());

        //                           timers.sort((a, b) =>
        //                               (int.parse(a.split(":")[0]).compareTo(
        //                                   int.parse(b.split(":")[0]))));
        //                         }),
        //                     currentTime: new DateTime(
        //                         DateTime.now().year,
        //                         DateTime.now().month,
        //                         DateTime.now().day,
        //                         DateTime.now().hour,
        //                         0,
        //                         0),
        //                     locale: LocaleType.ru);
        //               })
        //         ]
        //       : [],
        // ),
        // body: allowToNotify
        //     ? Stack(
        //         children: [
        //           Container(
        //             child: ListView.builder(
        //               itemCount: timers.length,
        //               itemBuilder: (context, index) {
        //                 return Card(
        //                   child: ListTile(
        //                     title: Text(timers[index]),
        //                     trailing: InkWell(
        //                         child: Icon(Icons.cancel),
        //                         onTap: () {
        //                           setState(() {
        //                             timers.removeAt(index);
        //                           });
        //                         }),
        //                   ),
        //                 );
        //               },
        //             ),
        //           ),
        //           if (timers.isEmpty)
        //             Align(
        //               alignment: Alignment.center,
        //               child: Text(
        //                 'Вам нужно добавить таймеры',
        //               ),
        //             )
        //           else
        //             Container(
        //               alignment: Alignment.bottomCenter,
        //               child: SizedBox(
        //                 width: MediaQuery.of(context).size.width,
        //                 child: FlatButton(
        //                     padding: EdgeInsets.all(16.0),
        //                     color: Colors.blue,
        //                     textColor: Colors.white,
        //                     child: Text("Сохранить"),
        //                     onPressed: () async {
        //                       await saveTimers(timers, null);
        //                       // await makeNotifications(
        //                       // "VK Papers", "Новые новости уже пришли!");

        //                       Navigator.of(context)
        //                           .popUntil((route) => route.isFirst);
        //                       Navigator.of(context)
        //                           .pushReplacement(GoTo(FinishScreen()));
        //                     }),
        //               ),
        //             )
        //         ],
        //       )
        //     : Center(
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Text(
        //               "Разрешите приложению присылать уведомления, чтобы настроить промежутки времени, в которых можно читать новости",
        //               textAlign: TextAlign.center,
        //             ),
        //             FlatButton(
        //                 onPressed: () async {
        //                   // await initNotifications();
        //                   setState(() {
        //                     allowToNotify = true;
        //                   });
        //                 },
        //                 child: Text("Разрешаю присылать мне уведомления")),
        //           ],
        // ),
      ),
      body: Column(
        children: [
          FlatButton(
              onPressed: () async {
                await initNotifications();
                await _showNotification();
              },
              child: Text("Click to set a notification every day in 2 sec"))
        ],
      ),
    );
  }

  FlutterLocalNotificationsPlugin fltrNotification;
  // String _selectedParam;
  String task;
  int val;

  Future<void> initNotifications() async {
    var androidInitilize = new AndroidInitializationSettings('app_icon');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings =
        new InitializationSettings(androidInitilize, iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initilizationsSettings,
        onSelectNotification: notificationSelected);
  }

  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "Desi programmer", "This is my channel",
        importance: Importance.Max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(androidDetails, iSODetails);

    fltrNotification.showDailyAtTime(
        0,
        "title",
        "body",
        Time(DateTime.now().hour, DateTime.now().minute,
            DateTime.now().second + 3),
        generalNotificationDetails);

    // fltrNotification.showDailyAtTime(
    //     0,
    //     "title",
    //     "body",
    //     Time(DateTime.now().hour, DateTime.now().minute,
    //         DateTime.now().second + 3),
    //     generalNotificationDetails);
  }

  Future notificationSelected(String payload) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Notification Clicked $payload"),
      ),
    );
  }
}
