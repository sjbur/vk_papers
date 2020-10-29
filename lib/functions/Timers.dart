import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Timer {
  String time;
  DateTime accessedDate;

  Timer(this.time, this.accessedDate);

  Map<String, dynamic> toJson() => {
        'time': time,
        'accessed':
            accessedDate != null ? accessedDate.toIso8601String() : null,
      };
}

Future saveTimers(List<String> ls, List<Timer> timLs) async {
  final file = await timersFile();

  List<Map> timersMap = new List<Map>();
  if (ls != null) {
    ls.forEach((element) {
      timersMap.add(new Timer(element, null).toJson());
    });

    print(timersMap);

    file.writeAsString(jsonEncode(timersMap));
  } else {
    timLs.forEach((element) {
      timersMap.add(element.toJson());
    });

    print(timersMap);

    file.writeAsString(jsonEncode(timersMap));
  }
}

Future<List<Timer>> getAllTimers() async {
  List<Timer> res = new List<Timer>();
  final file = await timersFile();
  List ls = jsonDecode(await file.readAsString());

  ls.forEach((element) {
    element["accessed"] == null
        ? res.add(new Timer(element["time"], null))
        : res.add(
            new Timer(element["time"], DateTime.parse(element["accessed"])));
  });

  return res;
}

Future<bool> timersExist() async {
  try {
    final file = await timersFile();

    String contents = await file.readAsString();

    return contents.length > 2;
  } catch (e) {
    return false;
  }
}

Future<File> timersFile() async {
  Directory directory = await getApplicationDocumentsDirectory();
  return File(directory.path + '/timers.json');
}

Future<Timer> getTimerToAccess() async {
  List<Timer> ls = await getAllTimers();
  List<Timer> lsAllowed = new List<Timer>();
  Timer res;

  for (var i = ls.length - 1; i >= 0; i--) {
    var element = ls[i];
    print(element.time);
    element.time.trim();

    DateTime now = DateTime.now();

    if (element.accessedDate != null) {
      if (now.difference(element.accessedDate).isNegative ||
          DateTime.now().day == element.accessedDate.day) {
        print("nope");
      } else {
        lsAllowed.add(element);
        print("ok not null");
        res = element;
        return element;
      }
    } else {
      int h = int.parse(element.time.split(":")[0]);
      int m = int.parse(element.time.split(":")[1]);

      Duration userTime = Duration(hours: h, minutes: m);
      Duration currentTime =
          Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute);

      if ((currentTime - userTime).isNegative) {
        print("nope");
      } else {
        lsAllowed.add(element);
        print("ok");
        res = element;
        return element;
      }
    }
  }

  return res;
}

Future<Timer> getLastAccessedTimer() async {
  List<Timer> ls = await getAllTimers();
  Timer res;

  for (var i = ls.length - 1; i >= 0; i--) {
    var element = ls[i];
    print(element.time);
    element.time.trim();

    if (element.accessedDate != null &&
        DateTime.now().day == element.accessedDate.day) res = element;
  }

  return res;
}

Future<void> accessTimer() async {
  List<Timer> timers = await getAllTimers();
  Timer timerToAccess = await getTimerToAccess();

  timers.forEach((element) {
    if (element.time == timerToAccess.time)
      element.accessedDate = DateTime.now();
  });

  //timers[timers.indexOf(timerToAccess)].accessedDate = DateTime.now();

  await saveTimers(null, timers);
}
