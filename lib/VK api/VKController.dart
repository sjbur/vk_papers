import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vk_times/VK%20api/User.dart';
import 'package:vk_times/VK%20api/Wall.dart';

import 'Groups.dart';
import 'Newsfeed.dart';

class VKController {
  String vkVersion = "5.122";

  VKGroups groups;
  VKNewsfeed newsfeed;
  VKUser user;
  VKWall wall;

  bool inited = false;

  VKController() {
    if (getToken() == null) {
      throw Exception("no token");
    }
  }

  Future<void> init() async {
    groups = new VKGroups(vkVersion, await getToken());
    newsfeed = new VKNewsfeed();
    user = new VKUser();
    wall = new VKWall(await getToken(), vkVersion);

    await groups.init();

    inited = true;
  }

  Future<String> getToken() async {
    var _storage = new FlutterSecureStorage();
    var token = await _storage.read(key: "token");
    return token;
  }

  // VKNewsfeed newsfeed = new VKNewsfeed();
  // VKUser user = new VKUser();
}

VKController vk = new VKController();
