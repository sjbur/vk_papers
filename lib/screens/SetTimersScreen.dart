import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vk_papers/screens/WaitForNewsScreen.dart';
import '../timepicker/flutter_datetime_picker.dart';

import '../functions/Timers.dart';
import '../functions/swipe.dart';

import 'FinishScreen.dart';

class SetTimersScreen extends StatefulWidget {
  final bool firstTime;

  const SetTimersScreen({Key key, @required this.firstTime}) : super(key: key);

  @override
  _SetTimersScreenState createState() => _SetTimersScreenState();
}

class _SetTimersScreenState extends State<SetTimersScreen> {
  List<String> timers = new List<String>();
  FlutterLocalNotificationsPlugin fltrNotification =
      new FlutterLocalNotificationsPlugin();
  bool allowToNotify = false;

  initializeNotifications() async {
    // super.initState();
    var androidInitilize = new AndroidInitializationSettings('app_icon');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings =
        new InitializationSettings(androidInitilize, iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initilizationsSettings,
        onSelectNotification: selected);
  }

  Future selected(String payload) async {
    await Navigator.of(context).pushReplacement(GoTo(WaitForNewsScreen()));
  }

  Future makeNotifications(String message, String subtext,
      {String sound}) async {
    var androidChannel = AndroidNotificationDetails(
      'channel-id',
      'channel-name',
      'channel-description',
      importance: Importance.Max,
      priority: Priority.Max,
    );

    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);

    List<Timer> savedTimers = await getAllTimers();

    await fltrNotification.cancelAll();

    savedTimers.forEach((element) {
      String textTime = element.time;
      textTime = textTime.trim();

      Time time = Time(int.parse(textTime.split(":")[0].toString()),
          int.parse(textTime.split(":")[1].toString()), 0);

      fltrNotification.showDailyAtTime(
          0, message, subtext, time, platformChannel,
          payload: "0");
    });
  }

  void load() async {
    if (await timersExist() && await checkLimitations()) {
      List<Timer> userTimers = await getAllTimers();

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
                                  "VK Papers", "Новые новости уже пришли!");

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
                        onPressed: () => setState(() {
                              initializeNotifications();
                              allowToNotify = true;
                            }),
                        child: Text("Разрешаю присылать мне уведомления")),
                  ],
                ),
              ));
  }
}
