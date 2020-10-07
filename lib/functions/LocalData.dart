import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> _localPath() async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> getCategoriesFile() async {
  final path = await _localPath();
  return File('$path/categories_user.json');
}

Future<bool> categoriesExist() async {
  try {
    final file = await getCategoriesFile();

    String contents = await file.readAsString();

    return contents.length > 2;
  } catch (e) {
    return false;
  }
}

Future<File> getTimersFile() async {
  final path = await _localPath();
  return File('$path/timers.json');
}

Future<bool> timersExist() async {
  try {
    final file = await getTimersFile();

    String contents = await file.readAsString();

    return contents.length > 2;
  } catch (e) {
    return false;
  }
}

Future saveTimers(List<String> ls) async {
  final file = await getTimersFile();
  file.writeAsString(jsonEncode(ls.toString()));

  print(await file.readAsString());
}
