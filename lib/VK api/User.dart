import 'dart:convert';
import 'package:http/http.dart' as http;

import 'VKController.dart';

class VKUser {
  Future<String> getProfilePic_100() async {
    var url =
        "https://api.vk.com/method/users.get?fields=photo_100,photo_200&" +
            "&access_token=" +
            await VKController().getToken() +
            "&v=" +
            VKController().vkVersion;

    var response = await http.get(url);
    Map<String, dynamic> js = await jsonDecode(response.body);

    if (js.containsKey("error")) {
      throw Exception(js["error"]);
    } else {
      js = js["response"][0];

      if (js["photo_200"] != null) return js["photo_200"];

      if (js["photo_100"] != null) return js["photo_100"];

      return null;
    }
  }

  Future<String> username() async {
    var url = "https://api.vk.com/method/users.get?" +
        "&access_token=" +
        await VKController().getToken() +
        "&v=" +
        VKController().vkVersion;

    var response = await http.get(url);
    Map<String, dynamic> js = await jsonDecode(response.body);

    if (js.containsKey("error")) {
      throw Exception(js["error"]);
    } else {
      print(js);
      js = js["response"][0];

      return js["first_name"] + " " + js["last_name"];
    }
  }
}
