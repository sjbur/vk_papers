import 'package:flutter/material.dart';
import 'package:vk_papers/VK%20api/Newsfeed.dart';
import 'package:vk_papers/VK%20api/VKController.dart';
import 'package:vk_papers/widgets/Post.dart';
import 'package:vk_papers/functions/swipe.dart';
import 'package:vk_papers/screens/SettingsScreen.dart';

import 'LoginScreen.dart';

class TestNewsScreen extends StatefulWidget {
  @override
  _TestNewsScreenState createState() => _TestNewsScreenState();
}

class _TestNewsScreenState extends State<TestNewsScreen> {
  VKController vk = new VKController();
  List<Post> posts;
  String vkToken;

  ScrollController scroll;

  Future<void> load({String date}) async {
    await vk.init();
    vkToken = await vk.getToken();

    if (date == null)
      posts = await vk.newsfeed.getNews("?count=20&filters=post");
    else
      posts = await vk.newsfeed
          .getNews("?count=20&filters=post&start_time=" + date);

    // make check in vk class
    if (posts == null)
      await Navigator.of(context)
          .pushReplacement(GoTo(LoginScreen(), left: true));

    setState(() {
      isRefreshing = false;
    });
  }

  @override
  void initState() {
    super.initState();

    scroll = new ScrollController()..addListener(_scrollListener);

    load();
  }

  bool isRefreshing = false;
  void _scrollListener() async {
    if (scroll.position.extentAfter < 700) {
      if (!isRefreshing) {
        isRefreshing = true;

        List<Post> newPosts = await vk.newsfeed.getNews(
            "?count=20&filters=post&start_from=" + vk.newsfeed.startFrom);

        setState(() {
          posts.addAll(newPosts);
          isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (posts != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.grid_on),
            onPressed: () {},
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await Navigator.of(context).push(GoTo(SettingsScreen()));
                })
          ],
          title: Text("Новости"),
        ),
        body: RefreshIndicator(
          onRefresh: load,
          child: ListView.builder(
              shrinkWrap: true,
              controller: scroll,
              itemCount: posts.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return PostCard(
                    ctxt,
                    posts[index].properties["ownerName"],
                    posts[index].properties["ownerAvatar"],
                    posts[index].properties["postDate"],
                    posts[index].properties["text"],
                    posts[index].attachments,
                    posts[index].properties["likes"],
                    posts[index].properties["comments"],
                    posts[index].properties["reposts"],
                    posts[index].properties["views"],
                    vkToken,
                    vk.vkVersion);
              }),
        ),
      );
    }
    return Text("");
  }
}
