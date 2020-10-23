import 'package:flutter/material.dart';
import 'package:vk_papers/VK%20api/Newsfeed.dart';
import 'package:vk_papers/VK%20api/VKController.dart';
import 'package:vk_papers/functions/swipe.dart';
import 'package:vk_papers/widgets/Poll.dart';

import 'LoginScreen.dart';

class TESTpoll extends StatefulWidget {
  @override
  _TESTpollState createState() => _TESTpollState();
}

class _TESTpollState extends State<TESTpoll> {
  VKController vk = new VKController();
  String _vkToken;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    List<Post> news;
    await vk.init();
    news = await vk.newsfeed
        .getNews("?filters=post&count=1&source_ids=-140820686");

    // make check in vk class
    if (news == null)
      await Navigator.of(context)
          .pushReplacement(GoTo(LoginScreen(), left: true));

    _vkToken = await vk.getToken();

    if (news != null) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: _vkToken != null
          ? Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Poll(
                    ownerID: "-140820686",
                    ownerName: "Name",
                    pollID: "432558419",
                    vkToken: _vkToken,
                    vkVersion: vk.vkVersion,
                  ),
                ),
              ),
            )
          : Text("Пусто"),
    );
  }
}
