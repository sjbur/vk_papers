import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../timepicker/flutter_datetime_picker.dart';
import '../functions/Timers.dart';
import '../functions/swipe.dart';

import 'package:vk_times/screens/WaitForNewsScreen.dart';
import 'FinishScreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class SetTimersScreen extends StatefulWidget {
  final bool firstTime;

  const SetTimersScreen({Key key, @required this.firstTime}) : super(key: key);

  @override
  _SetTimersScreenState createState() => _SetTimersScreenState();
}

class _SetTimersScreenState extends State<SetTimersScreen> {
  List<String> timers = new List<String>();
  bool allowToNotify = false;

  FlutterLocalNotificationsPlugin fltrNotification =
      new FlutterLocalNotificationsPlugin();

  void _requestPermissions() async {
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
      didReceiveLocalNotificationSubject.add(ReceivedNotification(
          id: id, title: title, body: body, payload: payload));
    });
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectNotificationSubject.add(payload);

      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => WaitForNewsScreen()));
    });

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

//   void _configureDidReceiveLocalNotificationSubject() {
//     didReceiveLocalNotificationSubject.stream
//         .listen((ReceivedNotification receivedNotification) async {
//       await showDialog(
//         context: context,
//         builder: (BuildContext context) => CupertinoAlertDialog(
//           title: receivedNotification.title != null
//               ? Text(receivedNotification.title)
//               : null,
//           content: receivedNotification.body != null
//               ? Text(receivedNotification.body)
//               : null,
//           actions: <Widget>[
//             CupertinoDialogAction(
//               isDefaultAction: true,
//               onPressed: () async {
//                 debugPrint('''
// configureDidReceive:${receivedNotification.payload}''');
//               },
//               child: const Text('Ok'),
//             )
//           ],
//         ),
//       );
//     });
//   }

//   void _configureSelectNotificationSubject() {
//     selectNotificationSubject.stream.listen((String payload) async {
//       debugPrint('__configureSelectNotification:$payload');
//     });
//   }

  Future initNotifications() async {
    _requestPermissions();
    //_configureDidReceiveLocalNotificationSubject();
    //_configureSelectNotificationSubject();
  }

  Future makeNotifications(String message, String subtext) async {
    List<Timer> savedTimers = await getAllTimers();

    await fltrNotification.cancelAll();

    savedTimers.forEach((element) async {
      String textTime = element.time;
      textTime = textTime.trim();

      int minute = int.parse(textTime.split(":")[1].toString());
      int hour = int.parse(textTime.split(":")[0].toString());

      await _scheduleDailyNotification(hour, minute);
    });
  }

  void load() async {
    if (await timersExist() && await checkLimitations()) {
      List<Timer> userTimers = await getAllTimers();

      await initNotifications();

      setState(() {
        allowToNotify = true;

        userTimers.forEach((element) {
          timers.add(element.time);

          timers.sort((a, b) => (int.parse(a.split(":")[0])
              .compareTo(int.parse(b.split(":")[0]))));
        });
      });
    }
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
          actions: allowToNotify
              ? [
                  IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        DatePicker.showTimePicker(context,
                            showSecondsColumn: false,
                            theme: DatePickerTheme(
                              containerHeight: 210.0,
                            ),
                            showTitleActions: true,
                            onConfirm: (time) => setState(() {
                                  timers.add(time.hour.toString() +
                                      ":" +
                                      time.minute.toString());

                                  timers.sort((a, b) =>
                                      (int.parse(a.split(":")[0]).compareTo(
                                          int.parse(b.split(":")[0]))));
                                }),
                            currentTime: new DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                DateTime.now().hour,
                                0,
                                0),
                            locale: LocaleType.ru);
                      })
                ]
              : [],
        ),
        body: allowToNotify
            ? Stack(
                children: [
                  Container(
                    child: ListView.builder(
                      itemCount: timers.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(timers[index]),
                            trailing: InkWell(
                                child: Icon(Icons.cancel),
                                onTap: () {
                                  setState(() {
                                    timers.removeAt(index);
                                  });
                                }),
                          ),
                        );
                      },
                    ),
                  ),
                  if (timers.isEmpty)
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Вам нужно добавить таймеры',
                      ),
                    )
                  else
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: FlatButton(
                            padding: EdgeInsets.all(16.0),
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: Text("Сохранить"),
                            onPressed: () async {
                              await saveTimers(timers, null);
                              await makeNotifications(
                                  "VK Times", "Новые новости уже пришли!");

                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                              Navigator.of(context)
                                  .pushReplacement(GoTo(FinishScreen()));
                            }),
                      ),
                    )
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Разрешите приложению присылать уведомления, чтобы настроить промежутки времени, в которых можно читать новости",
                      textAlign: TextAlign.center,
                    ),
                    FlatButton(
                        onPressed: () async {
                          await initNotifications();
                          setState(() {
                            allowToNotify = true;
                          });
                        },
                        child: Text("Разрешаю присылать мне уведомления")),
                  ],
                ),
              ));
  }
}

Future<void> _scheduleDailyNotification(int hour, int minute) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'VK Times',
      'Новости уже пришли!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android:
            AndroidNotificationDetails("0", 'VK Times', 'Новости уже пришли!'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time);
}

tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}
