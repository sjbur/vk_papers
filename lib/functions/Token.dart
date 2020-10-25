import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = new FlutterSecureStorage();

Future<String> getToken() async {
  String token = "";
  token = await _storage.read(key: "token");

  if (token != null && token != "")
    return token;
  else
    return null;
}

Future<void> saveToken(String value) async {
  _storage.write(key: "token", value: value);
}

Future<void> clearToken() async {
  _storage.deleteAll();
}
