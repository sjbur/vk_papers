import 'package:flutter/material.dart';
import 'package:vk_papers/VK%20api/Newsfeed.dart';
import 'package:vk_papers/VK%20api/VKController.dart';
import 'package:vk_papers/widgets/Post.dart';
import 'package:vk_papers/functions/swipe.dart';
import 'package:vk_papers/screens/SettingsScreen.dart';

import 'package:vk_papers/functions/Timers.dart';

import 'LoginScreen.dart';

class TestNewsScreen extends StatefulWidget {
  final String title;
  final String sources;

  const TestNewsScreen({Key key, this.sources, this.title}) : super(key: key);
  @override
  _TestNewsScreenState createState() => _TestNewsScreenState();
}

class _TestNewsScreenState extends State<TestNewsScreen> {
  VKController vk = new VKController();
  List<Post> posts;
  String vkToken;

  ScrollController scroll;

  Future<void> load() async {
    await vk.init();
    vkToken = await vk.getToken();

    var accessedT = await getLastAccessedTimer();
    accessedT.time.trim();
    int h = int.parse(accessedT.time.split(":")[0]);
    int m = int.parse(accessedT.time.split(":")[1]);
    var curDate = new DateTime(accessedT.accessedDate.year,
        accessedT.accessedDate.month, accessedT.accessedDate.day, h, m);

    posts = await vk.newsfeed.getNews("?count=20&filters=post&source_ids=" +
        widget.sources +
        "&end_time=" +
        (curDate.millisecondsSinceEpoch / 1000).toString());

    print(widget.sources);

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
            "?count=20&filters=post&start_from=" +
                vk.newsfeed.startFrom +
                "&source_ids=" +
                widget.sources);

        setState(() {
          posts.addAll(newPosts);
          isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.grid_on),
          onPressed: () {
            Navigator.pop(context);
          },
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
        title: Text(widget.title),
      ),
      body: posts != null
          ? BuildPostCard(
              scroll: scroll, posts: posts, vkToken: vkToken, vk: vk)
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class BuildPostCard extends StatefulWidget {
  const BuildPostCard({
    Key key,
    @required this.scroll,
    @required this.posts,
    @required this.vkToken,
    @required this.vk,
  }) : super(key: key);

  final ScrollController scroll;
  final List<Post> posts;
  final String vkToken;
  final VKController vk;

  @override
  _BuildPostCardState createState() => _BuildPostCardState();
}

class _BuildPostCardState extends State<BuildPostCard>
    with TickerProviderStateMixin {
  AnimationController _controller;

  Animation<double> _animation;

  initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
        value: 0,
        lowerBound: 0,
        upperBound: 1);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.length == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Text("Пусто. Здесь ничего нет! ")),
          Center(child: Text("Во всяком случае, пока что."))
        ],
      );
    }
    return ListView.builder(
        shrinkWrap: true,
        controller: widget.scroll,
        itemCount: widget.posts.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return FadeTransition(
            opacity: _animation,
            child: PostCard(
                ctxt,
                widget.posts[index].properties["ownerName"],
                widget.posts[index].properties["ownerAvatar"],
                widget.posts[index].properties["postDate"],
                widget.posts[index].properties["text"],
                widget.posts[index].attachments,
                widget.posts[index].properties["likes"],
                widget.posts[index].properties["comments"],
                widget.posts[index].properties["reposts"],
                widget.posts[index].properties["views"],
                widget.vkToken,
                widget.vk.vkVersion),
          );
        });
  }
}
