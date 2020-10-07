import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vk_papers/functions/LocalData.dart';
import 'package:vk_papers/screens/FinishScreen.dart';
import 'package:vk_papers/timepicker/flutter_datetime_picker.dart';

class SetTimersScreen extends StatefulWidget {
  @override
  _SetTimersScreenState createState() => _SetTimersScreenState();
}

class _SetTimersScreenState extends State<SetTimersScreen> {
  List<String> timers = new List<String>();

  FlutterLocalNotificationsPlugin fltrNotification;

  initializeNotifications() async {
    super.initState();
    var androidInitilize = new AndroidInitializationSettings('app_icon');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings =
        new InitializationSettings(androidInitilize, iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initilizationsSettings,
        onSelectNotification: selected);
  }

  Future selected(String payload) async {
    print("aue");
    await Navigator.pushReplacement(
      context,
      new MaterialPageRoute(builder: (context) => new FinishScreen()),
    );
  }

  Future singleNotification(String message, String subtext, int hashcode,
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
    // localNotificationsPlugin.schedule(
    //     hashcode, message, subtext, datetime, platformChannel,
    //     payload: hashcode.toString());

    Time time = new Time(20, 35, 0);

    fltrNotification.showDailyAtTime(
        hashcode, message, subtext, time, platformChannel,
        payload: hashcode.toString());
  }

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Таймеры"),
          actions: [
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
                      showTitleActions: true, onConfirm: (time) {
                    print('confirm $time');

                    setState(() {
                      timers.add(time.hour.toString() +
                          " : " +
                          time.minute.toString());
                    });
                  }, currentTime: DateTime.now(), locale: LocaleType.ru);
                  setState(
                    () {},
                  );
                })
          ],
        ),
        body: Stack(
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
            timers.isEmpty
                ? Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Вам нужно добавить таймеры',
                    ),
                  )
                : Text(""),
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
                      saveTimers(timers);
                      await singleNotification(
                        "Notification",
                        "This is a notification",
                        98123871,
                      );
                    }),
              ),
            )
          ],
        ));
  }
}
