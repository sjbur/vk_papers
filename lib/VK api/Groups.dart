import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../functions/Categories.dart' as LocalData;

class Group {
  String name;
  String mainActivity;
  String activity;
  String id;
  String avatarUrl;

  Group(this.name, this.id, this.mainActivity, this.activity, this.avatarUrl);
}

class VKGroups {
  int customCount;
  var restart;
  String vkVersion;
  String token;

  List<Group> all = new List<Group>();
  Map<String, List<Group>> mainActivities = new Map<String, List<Group>>();
  Map<String, List<Group>> newActivities = new Map<String, List<Group>>();

  VKGroups(this.vkVersion, this.token, {this.restart, this.customCount}) {
    print("init groups");
  }

  Future<void> init() async {
    if (restart != null ||
        restart == true ||
        await LocalData.categoriesExist() == false) {
      await loadFromWeb();
    } else {
      await loadFromLocal();
    }
  }

// Save / load/ reset

  Future loadFromWeb() async {
    var url = "https://api.vk.com/method/" +
        "groups.get?&extended=1&fields=activity&v=" +
        vkVersion +
        "&access_token=" +
        token;

    var response = await http.get(url);
    var json = jsonDecode(response.body);

    int count = json["response"]["count"];
    resetGr();
    for (int i = 0; i < count; i++) {
      var _name = json["response"]["items"][i]["name"];
      var _id = json["response"]["items"][i]["id"].toString();
      var _activity = json["response"]["items"][i]["activity"];
      var _mainActivity = await getGroupMainActivity(_activity);
      var _avatar = json["response"]["items"][i]["photo_100"];

      Group group = new Group(_name, _id, _mainActivity, _activity, _avatar);

      all.add(group);
      mainActivities = await makeCommonActivities();

      reset();

      await save();
    }
  }

  void resetGr() {
    all = new List<Group>();
    mainActivities = new Map<String, List<Group>>();
    newActivities = new Map<String, List<Group>>();
  }

  Future loadFromLocal() async {
    final file = await LocalData.getCategoriesFile();
    Map<String, dynamic> grs = jsonDecode(await file.readAsString());

    resetGr();

    grs.forEach((key, value) {
      try {
        Group newGr = new Group(key, value[2], value[3], value[0], value[1]);
        all.add(newGr);
      } catch (ex) {
        // new common activity but empty
        newActivities.putIfAbsent(key, () => []);

        print("new common: " + key);
      }
    });

    mainActivities = await makeCommonActivities();
  }

  Future<File> save() async {
    final file = await LocalData.getCategoriesFile();

    Map data = new Map();

    all.forEach((element) {
      if (newActivities.containsKey(element.mainActivity)) {
        if (newActivities[element.mainActivity] != null)
          newActivities.putIfAbsent(element.name, () => [element]);
        else
          newActivities[element.mainActivity].add(element);
      }
      data.putIfAbsent(
          element.name,
          () => [
                element.activity,
                element.avatarUrl,
                element.id,
                element.mainActivity
              ]);
    });

    var i = 0;
    if (newActivities.isNotEmpty) {
      print("new is not null");
      newActivities.forEach((key, value) {
        if (value.isNotEmpty) {
          print("value is not empty");
          data.putIfAbsent(
              value[i].name,
              () => [
                    value[i].activity,
                    value[i].avatarUrl,
                    value[i].id,
                    value[i].mainActivity
                  ]);
        } else {
          data.putIfAbsent(key, () => []);
          print("value is empty");
        }
      });
    }

    mainActivities = await makeCommonActivities();

    return file.writeAsString(jsonEncode(data));
  }

  Future reset() async {
    final file = await LocalData.getCategoriesFile();
    return file.writeAsString("");
  }

// Operations with groups

  void removeGroup(Group gr, String cat) async {
    moveFromToCategory(gr, cat, "Скрытые");
    await save();
  }

// Operations with categories
  Future addCategory(String name) async {
    newActivities.putIfAbsent(name, () => []);
    mainActivities = await makeCommonActivities();
    await save();
  }

  Future removeCategory(String name) async {
    await renameCategory(name, "Скрытые");
  }

  Future<void> renameCategory(String oldCat, String value) async {
    if (newActivities.containsKey(oldCat)) {
      newActivities.putIfAbsent(value, () => []);
      newActivities[oldCat].forEach((element) {
        element.mainActivity = value;
        newActivities[value].add(element);
      });
      newActivities.remove(oldCat);
    }

    all.forEach((element) {
      if (element.mainActivity == oldCat) element.mainActivity = value;
    });

    await save();
  }

  Future<void> moveFromToCategory(
      Group gr, String moveFrom, String moveTo) async {
    if (newActivities.containsKey(moveTo)) newActivities[moveTo].add(gr);

    gr.mainActivity = moveTo;
    save();
  }

  Future<void> moveFromToCategoryByIndex(
      int index, String moveFrom, String moveTo) async {
    all.forEach((element) {
      if (element == mainActivities[moveFrom][index]) {
        print(element.name + " was moved from ${element.mainActivity} to");

        if (newActivities.containsKey(moveTo))
          newActivities[moveTo].add(element);

        element.mainActivity = moveTo;
        print(element.mainActivity);
      }
    });

    mainActivities[moveFrom].removeAt(index);

    await save();
  }

// Common activity
  Future<String> getGroupMainActivity(String _activ) async {
    String genresJSON = await rootBundle.loadString('assets/genres3.json');
    Map<String, dynamic> map = json.decode(genresJSON);
    List<dynamic> keys = map.keys.toList();
    List<dynamic> ls;

    for (var i = 0; i < keys.length; i++) {
      ls = map[keys[i]];
      if (ls.contains(_activ)) return keys[i];
    }
    return "Другое";
  }

  Future<Map<String, List<Group>>> makeCommonActivities() async {
    Map<String, List<Group>> _res = new Map<String, List<Group>>();

    all.forEach((element) {
      if (_res.containsKey(element.mainActivity))
        _res[element.mainActivity] += [element];
      else
        _res.putIfAbsent(element.mainActivity, () => [element]);
    });

    var i = 0;
    newActivities.keys.forEach((element) {
      if (newActivities[element].isEmpty)
        _res.putIfAbsent(element, () => []);
      else
        newActivities[element].forEach((newGr) {
          if (i == 0)
            _res.putIfAbsent(element, () => [newGr]);
          else
            _res[element].add(newGr);
        });

      print(element);
    });

    _res.keys.toList().sort((a, b) => a.compareTo(b));

    return _res;
  }
}
