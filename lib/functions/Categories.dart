import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> getCategoriesFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
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

Future clearCategories() async {
  final file = await getCategoriesFile();
  file.delete();
}
